# Specification: Provider Sandbox

## Overview
The **Provider Sandbox** is a development-only interface designed to test HealthKit data extraction, physiological calculations (TRIMP, HRV averages), and AI Multi-Agent orchestration in isolation before they are integrated into the main training features.

## 1. Features

### 1.1 HealthKit Authorization
- Allows manual triggering of the HealthKit permission sheet.
- Displays logs for successful authorization or specific error codes.

### 1.2 Data Provider Tests
- **HRV (30 days)**: Fetches and displays daily HRV averages, calculating the 7-day (readiness) and 30-day (baseline) moving averages.
- **RHR (7 days)**: Fetches daily Resting Heart Rate data.
- **Workouts & TRIMP**: Retrieves recent workouts and calculates the Training Impulse (TRIMP) score for the most recent session.

### 1.3 AI Multi-Agent Testing
- **Orchestration Pipeline**: Executes the full `AgentOrchestrator` flow using the selected LLM provider.
- **Mocking**: Simulates responses for `LoadAgent`, `RecoveryAgent`, and `CoachAgent` with realistic JSON payloads and network latency when `.mock` is selected.
- **Real-Data Execution**: When a specific model other than mock is selected (e.g., GPT-4o, Gemini 3.5 Flash, Claude 3.5 Sonnet), the sandbox collects real biometric and workout data from HealthKit (30-day HRV, 7-day RHR, and recent workouts) to dynamically calculate TRIMP and moving averages before feeding them to the Orchestrator.
- **Workout Preview Integration**: Once a workout is generated, a "Preview Generated Workout" button appears, allowing the developer to view the structure in the `WorkoutPreviewView` and test the synchronization flow.
- **Enhanced Logging**: Utilizes the Orchestrator's logging callback to display granular execution steps in the UI, including:
  - Parallel start of agents.
  - Individual agent results and statuses.
  - Guardrail application steps.
  - Final parsed workout structure with type-safe intensity levels (`WorkoutIntensity`).

## 2. Technical Components

### 2.1 `SandboxLLMProvider`
A local implementation of `LLMProviderProtocol` used specifically in the sandbox. It allows testing without external API calls and provides predictable results for debugging the UI and orchestration logic.

### 2.2 `SandboxStore`
An `@Observable` store that encapsulates the testing logic. It acts as the "Controller" for the sandbox, managing logs and orchestrating the different test scenarios.
- In `testAIAgents`, it evaluates `selectedProvider`.
- If `selectedProvider != .mock` (representing a specific external model), it fetches active HealthKit time-series for HRV, Resting Heart Rate, and workouts, calculates the physiological load/recovery metrics, and forwards them to the selected AI model provider initialized with the designated model name.
- If `selectedProvider == .mock`, it continues to use static simulated inputs (TRIMP: 65.4, HRV 7d: 55.2, 30d: 56.1, empty workouts) and the `SandboxLLMProvider`.
- It stores the `generatedWorkout` to enable cross-feature navigation.

## 3. Usage for Developers
1. Open the app and navigate to **Settings > Developer Sandbox** (or through a direct button if available).
2. Tap **Request Permissions** if running for the first time.
3. Tap **Run Multi-Agent Pipeline** to verify the AI logic and parsing.
4. Review the **Logs** section at the bottom to see detailed execution timestamps and agent-specific statuses.
