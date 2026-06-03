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
    /// - Parameter logger: Optional closure to receive granular execution logs.
    func generateWorkout(
        trimpScore: Double,
        recentWorkouts: [LoadAgentInput.WorkoutEntry],
        sevenDayHRV: Double,
        thirtyDayHRV: Double,
        userGoal: String,
        logger: ((String) -> Void)? = nil
    ) async throws -> CustomWorkoutComposition {
        
        logger?("🤖 Starting Multi-Agent Pipeline...")
        
        // 1. Parallel execution of Load and Recovery analysis
        logger?("🤖 [LoadAgent] Starting TRIMP analysis (Score: \(String(format: "%.1f", trimpScore)))...")
        async let loadReportTask = loadAgent.execute(input: LoadAgentInput(
            trimpScore: trimpScore,
            workoutHistory: recentWorkouts
        ))
        
        logger?("🤖 [RecoveryAgent] Starting HRV analysis (7d: \(String(format: "%.1f", sevenDayHRV)) | 30d: \(String(format: "%.1f", thirtyDayHRV)))...")
        async let recoveryReportTask = recoveryAgent.execute(input: RecoveryAgentInput(
            sevenDayHRVAvg: sevenDayHRV,
            thirtyDayHRVAvg: thirtyDayHRV
        ))
        
        let loadReport = try await loadReportTask
        logger?("✅ [LoadAgent] Status: \(loadReport.status.uppercased())")
        
        let recoveryReport = try await recoveryReportTask
        logger?("✅ [RecoveryAgent] Status: \(recoveryReport.status.uppercased())")
        
        // 2. Coach Agent synthesis
        logger?("🤖 [CoachAgent] Synthesizing reports and creating workout plan...")
        let rawWorkout = try await coachAgent.execute(input: CoachAgentInput(
            loadReport: loadReport,
            recoveryReport: recoveryReport,
            userGoal: userGoal
        ))
        
        // 3. Safety Guardrail validation
        logger?("🛡️ [Guardrail] Applying physiological safety checks...")
        let safeWorkout = guardrail.validate(workout: rawWorkout, recoveryStatus: recoveryReport.status)
        
        logger?("🏁 Pipeline finished successfully.")
        return safeWorkout
    }
}
