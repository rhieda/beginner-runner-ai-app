import XCTest
@testable import Beginner_Runner_AI_Coach

final class MultiAgentTests: XCTestCase {
    
    func testAgentOrchestratorPipeline() async throws {
        let mockProvider = MockLLMProvider()
        let orchestrator = AgentOrchestrator(provider: mockProvider)
        
        let workout = try await orchestrator.generateWorkout(
            trimpScore: 45.0,
            recentWorkouts: [],
            sevenDayHRV: 65.0,
            thirtyDayHRV: 60.0,
            userGoal: "Run 5km"
        )
        
        XCTAssertEqual(workout.warmup.durationInMinutes, 10)
        XCTAssertEqual(workout.blocks.count, 1)
        XCTAssertEqual(workout.blocks[0].work.intensityLevel, .moderate)
    }
    
    func testSafetyGuardrailFatigue() {
        let guardrail = PhysiologicalSafetyGuardrail()
        let unsafeWorkout = CustomWorkoutComposition(
            warmup: .init(durationInMinutes: 15, intensityLevel: .moderate),
            blocks: [
                .init(
                    work: .init(durationInMinutes: 30, intensityLevel: .high),
                    recovery: .init(durationInMinutes: 1, intensityLevel: .low)
                )
            ],
            cooldown: .init(durationInMinutes: 15, intensityLevel: .moderate)
        )
        
        let safeWorkout = guardrail.validate(workout: unsafeWorkout, recoveryStatus: "fatigued")
        
        XCTAssertEqual(safeWorkout.warmup.durationInMinutes, 10)
        XCTAssertEqual(safeWorkout.warmup.intensityLevel, .low)
        XCTAssertEqual(safeWorkout.blocks[0].work.intensityLevel, .low)
        XCTAssertEqual(safeWorkout.blocks[0].work.durationInMinutes, 5)
    }
}
