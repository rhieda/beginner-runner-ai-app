import Foundation

struct AgentOrchestrator {
    let loadAgent: LoadAgent
    let recoveryAgent: RecoveryAgent
    let coachAgent: CoachAgent
    let guardrail: PhysiologicalSafetyGuardrail
    
    init(provider: LLMProviderProtocol) {
        self.loadAgent = LoadAgent(provider: provider)
        self.recoveryAgent = RecoveryAgent(provider: provider)
        self.coachAgent = CoachAgent(provider: provider)
        self.guardrail = PhysiologicalSafetyGuardrail()
    }
    
    /// Orchestrates the full pipeline from raw biometric data to a safe, personalized workout.
    func generateWorkout(
        trimpScore: Double,
        recentWorkouts: [LoadAgentInput.WorkoutEntry],
        sevenDayHRV: Double,
        thirtyDayHRV: Double,
        userGoal: String
    ) async throws -> CustomWorkoutComposition {
        
        // 1. Parallel execution of Load and Recovery analysis
        async let loadReportTask = loadAgent.execute(input: LoadAgentInput(
            trimpScore: trimpScore,
            workoutHistory: recentWorkouts
        ))
        
        async let recoveryReportTask = recoveryAgent.execute(input: RecoveryAgentInput(
            sevenDayHRVAvg: sevenDayHRV,
            thirtyDayHRVAvg: thirtyDayHRV
        ))
        
        let loadReport = try await loadReportTask
        let recoveryReport = try await recoveryReportTask
        
        // 2. Coach Agent synthesis
        let rawWorkout = try await coachAgent.execute(input: CoachAgentInput(
            loadReport: loadReport,
            recoveryReport: recoveryReport,
            userGoal: userGoal
        ))
        
        // 3. Safety Guardrail validation
        return guardrail.validate(workout: rawWorkout, recoveryStatus: recoveryReport.status)
    }
}
