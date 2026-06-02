# Architecture: HealthKit & TRIMP/HRV (Text Alternative)

This document provides a text-based representation of the system architecture for users or environments where Mermaid diagrams are not rendered.

## Layer 1: Features (UI)
- **SwiftUI View**: Observes the Store and triggers updates.
- **Store/ViewModel (@Observable)**: Coordinates the data flow between UI and Domain Agents.
  - *Depends on*: AgentOrchestrator, RecoveryAgentService, LoadAgentService.

## Layer 2: Domain (Business Logic & AI)
- **AgentOrchestrator**: 
  - Responsibility: Orchestrates the parallel execution of AI agents and applies safety guardrails.
- **AI Agents (LLM-Agnostic)**:
  - `LoadAgent`: Analyzes TRIMP and stress.
  - `RecoveryAgent`: Analyzes HRV trends and readiness.
  - `CoachAgent`: Synthesizes reports into a structured `CustomWorkoutComposition`.
- **Deterministic Services**:
  - `RecoveryAgentService`: Calculates 7-day and 30-day HRV moving averages.
  - `LoadAgentService`: Calculates Training Impulse (TRIMP) using the Banister formula.
- **PhysiologicalSafetyGuardrail**: Validates AI output against hard-coded safety rules.
- **Interfaces**:
  - `LLMProviderProtocol`: For AI communication abstraction.
  - `HealthKitTimeSeriesRequestable`: Protocol for fetching historical daily averages.
  - `WorkoutDataRequestable`: Protocol for fetching detailed workout metrics.

## Layer 3: Data (Implementation)
- **HRVRepository**: Orchestrates between cache and live data.
  - *Logic*: Check SwiftData -> if empty -> Fetch from HealthKit -> Store in SwiftData -> Return results.
- **Providers (HealthKit Implementation)**:
  - `HRVDataProvider`: Fetches SDNN series via `HKStatisticsCollectionQuery`.
  - `RHRDataProvider`: Fetches Resting Heart Rate series.
  - `WorkoutDataProvider`: Fetches `HKWorkout` and extracts intensity metrics.
- **Cache Implementation**:
  - `HRVCachedProvider`: SwiftData implementation for persisting `HealthDataBaseLocalSample`.

## Layer 4: Infrastructure
- **HealthKit (Apple)**: Source of truth for raw physiological data.
- **SwiftData (Apple)**: Local persistence for calculated "Intelligence Cache".

---

## Data Flow Diagram (ASCII)

[ FEATURES LAYER ]
      |
      v
[ DOMAIN LAYER (Orchestrator) ] <--- [ AI AGENTS (Load, Recovery, Coach) ]
      |                                     ^
      |                                     |
      +---> [ DETERMINISTIC SERVICES ] <----+
      |             (TRIMP, HRV)
      v
[ DATA LAYER (Repository) ] <--- [ INTERFACES ]
      |                             ^
      v                             |
[ DATA LAYER (Repository) ] --------|
      |
      +---> [ CACHE (SwiftData) ]
      |
      +---> [ SOURCE (HealthKit) ]
