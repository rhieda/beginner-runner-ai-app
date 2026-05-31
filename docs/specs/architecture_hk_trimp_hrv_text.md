# Architecture: HealthKit & TRIMP/HRV (Text Alternative)

This document provides a text-based representation of the system architecture for users or environments where Mermaid diagrams are not rendered.

## Layer 1: Features (UI)
- **SwiftUI View**: Observes the Store and triggers updates.
- **Store/ViewModel (@Observable)**: Coordinates the data flow between UI and Domain Agents.
  - *Depends on*: RecoveryAgentService, LoadAgentService.

## Layer 2: Domain (Business Logic)
- **RecoveryAgentService**: 
  - Responsibility: Calculates 7-day and 30-day HRV moving averages.
  - Data Source: `HealthKitTimeSeriesRequestable`.
- **LoadAgentService**:
  - Responsibility: Calculates Training Impulse (TRIMP) using the Banister formula.
  - Data Source: `WorkoutDataRequestable`, `HealthKitTimeSeriesRequestable` (for RHR).
- **Interfaces**:
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
[ DOMAIN LAYER (Agents) ] <--- [ INTERFACES ]
      |                             ^
      v                             |
[ DATA LAYER (Repository) ] --------|
      |
      +---> [ CACHE (SwiftData) ]
      |
      +---> [ SOURCE (HealthKit) ]
