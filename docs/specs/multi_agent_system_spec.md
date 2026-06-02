# Specification: Multi-Agent AI Orchestration System

## Overview
This document specifies the architecture and implementation details of the Multi-Agent AI system used to transform biometric data into personalized training plans. The system is designed to be LLM-agnostic, modular, and safe by design.

## 1. Architectural Components

### 1.1 Core Protocols (`Core/AI/`)
- **`LLMProviderProtocol`**: Abstract interface for executing model requests. Decouples the system from specific providers (OpenAI, Anthropic, local models).
- **`AIAgentProtocol`**: Generic protocol defining the contract for any AI agent. Handles automated JSON encoding of inputs and decoding of outputs.

### 1.2 Agents (`Domain/Agents/`)
- **`LoadAgent`**: Analyzes chronic physical stress.
  - *Input*: TRIMP score and workout history.
  - *Output*: Physiological status (undertraining, adapting, overreaching) and qualitative evaluation.
- **`RecoveryAgent`**: Analyzes biological readiness.
  - *Input*: 7-day and 30-day HRV moving averages.
  - *Output*: Recovery status (recovered, fatigued) and qualitative evaluation.
- **`CoachAgent`**: Synthesizes reports into a workout plan.
  - *Input*: Load and Recovery reports + User goals.
  - *Output*: `CustomWorkoutComposition` (warmup, blocks, cooldown).

### 1.3 Orchestration (`Domain/Agents/AgentOrchestrator.swift`)
The `AgentOrchestrator` manages the pipeline:
1. Receives deterministic calculations from Domain Services.
2. Executes `LoadAgent` and `RecoveryAgent` in parallel.
3. Feeds results into `CoachAgent`.
4. Passes the final workout through the `PhysiologicalSafetyGuardrail`.

## 2. Communication Schemas (JSON)

### Load Analysis
**Input:** `{ "trimpScore": Double, "workoutHistory": [ { "date": String, "duration": Int, "intensity": String } ] }`
**Output:** `{ "status": String, "physiologicalEvaluation": String }`

### Recovery Analysis
**Input:** `{ "sevenDayHRVAvg": Double, "thirtyDayHRVAvg": Double }`
**Output:** `{ "status": String, "physiologicalEvaluation": String }`

### Workout Composition
**Output Schema:**
```json
{
  "warmup": { "durationInMinutes": Int },
  "blocks": [
    {
      "work": { "durationInMinutes": Int, "intensityLevel": "low|medium|high" },
      "recovery": { "durationInMinutes": Int, "intensityLevel": "low" }
    }
  ],
  "cooldown": { "durationInMinutes": Int }
}
```

## 3. Physiological Safety Guardrails
To prevent "AI hallucinations" in health contexts, a hard-coded guardrail layer is applied:
- **Fatigue Interception**: If `RecoveryAgent` signals "fatigued", the guardrail overrides the workout to "low intensity" and caps durations, regardless of what the LLM suggested.
- **Duration Caps**: Ensures total workout time stays within safe limits for beginners (default: 60 minutes).

## 4. Verification Strategy
- **MockLLMProvider**: Used for unit testing the logic without API costs.
- **Pipeline Tests**: Ensures that data flows correctly from input through all agents to the final validated workout.
