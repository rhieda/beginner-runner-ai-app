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
- **Real-Data Execution**: When a specific model other than mock is selected (e.g., GPT-4o, Gemini 3.5 Flash, Claude 3.5 Sonnet) and simulated data is disabled, the sandbox collects real biometric and workout data from HealthKit (30-day HRV, 7-day RHR, and recent workouts) to dynamically calculate TRIMP and moving averages before feeding them to the Orchestrator.
- **Workout Preview Integration**: Once a workout is generated, a "Preview Generated Workout" button appears, allowing the developer to view the structure in the `WorkoutPreviewView` and test the synchronization flow.
- **Enhanced Logging**: Utilizes the Orchestrator's logging callback to display granular execution steps in the UI.

### 1.4 Simulated Biometrics (Dev Tools)
- **Interactive Controls**: Allows manual configuration of physiological metrics (TRIMP, 7d HRV, 30d HRV) and user goals via Sliders and TextFields.
- **Simulation Override**: A Toggle option "Use Simulated Data" overrides real HealthKit data with simulated parameters. This allows testing live LLM models using simulated metrics directly on simulator devices.
- **Auto-Mock Enforcement**: Toggling the selected provider to `.mock` implicitly forces "Use Simulated Data" to enabled.

---

## 2. Technical Components

### 2.1 `SandboxLLMProvider`
A local implementation of `LLMProviderProtocol` used specifically in the sandbox. It allows testing without external API calls and provides predictable results for debugging the UI and orchestration logic.

### 2.2 `SandboxStore`
An `@Observable` store that encapsulates the testing logic. It acts as the "Controller" for the sandbox, managing logs and orchestrating the different test scenarios.
- Mapped variables: `useSimulatedMetrics`, `simulatedTrimp`, `simulatedSevenDayHRV`, `simulatedThirtyDayHRV`, `simulatedUserGoal`.
- In `testAIAgents`, it evaluates `useSimulatedMetrics || selectedProvider == .mock`.
- If true, it runs the pipeline using the slider-configured parameters.
- If false, it fetches active HealthKit time-series for HRV, Resting Heart Rate, and workouts, calculates the physiological load/recovery metrics, and forwards them to the selected AI model provider.
- It stores the `generatedWorkout` to enable cross-feature navigation.

---

## 3. Usage for Developers
1. Open the app and navigate to **Settings > Developer Sandbox** (or through a direct button if available).
2. Tap **Request Permissions** if running for the first time.
3. In **Simulated Biometrics**, toggle **Use Simulated Data** to customize parameters:
   - Slide **Simulated 7d HRV** to `20 ms` to test the fatigue safety guardrail.
   - Slide **Simulated TRIMP** to `150` to test the overreaching safety guardrail.
4. Tap **Run Multi-Agent Pipeline** to verify the AI logic and parsing.
5. Review the **Logs** section at the bottom to see detailed execution timestamps and agent-specific statuses.
