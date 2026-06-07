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
        
        let safeWorkout = guardrail.validate(workout: unsafeWorkout, recoveryStatus: "fatigued", loadStatus: "adapting")
        
        XCTAssertEqual(safeWorkout.warmup.durationInMinutes, 10)
        XCTAssertEqual(safeWorkout.warmup.intensityLevel, .low)
        XCTAssertEqual(safeWorkout.blocks[0].work.intensityLevel, .low)
        XCTAssertEqual(safeWorkout.blocks[0].work.durationInMinutes, 5)
    }
    
    func testSafetyGuardrailOverreaching() {
        let guardrail = PhysiologicalSafetyGuardrail()
        let unsafeWorkout = CustomWorkoutComposition(
            warmup: .init(durationInMinutes: 10, intensityLevel: .moderate),
            blocks: [
                .init(
                    work: .init(durationInMinutes: 10, intensityLevel: .high),
                    recovery: .init(durationInMinutes: 2, intensityLevel: .low)
                )
            ],
            cooldown: .init(durationInMinutes: 10, intensityLevel: .moderate)
        )
        
        let safeWorkout = guardrail.validate(workout: unsafeWorkout, recoveryStatus: "recovered", loadStatus: "overreaching")
        
        // High intensity work block should be downgraded to moderate and duration capped at 8 mins
        XCTAssertEqual(safeWorkout.blocks[0].work.intensityLevel, .moderate)
        XCTAssertEqual(safeWorkout.blocks[0].work.durationInMinutes, 8)
    }
    
    func testSafetyGuardrailDurationCap() {
        let guardrail = PhysiologicalSafetyGuardrail()
        let longWorkout = CustomWorkoutComposition(
            warmup: .init(durationInMinutes: 15, intensityLevel: .moderate),
            blocks: [
                .init(
                    work: .init(durationInMinutes: 20, intensityLevel: .moderate),
                    recovery: .init(durationInMinutes: 5, intensityLevel: .low)
                ),
                .init(
                    work: .init(durationInMinutes: 20, intensityLevel: .moderate),
                    recovery: .init(durationInMinutes: 5, intensityLevel: .low)
                )
            ],
            cooldown: .init(durationInMinutes: 15, intensityLevel: .moderate)
        )
        // Total duration is 15 + 25 + 25 + 15 = 80 minutes
        
        let safeWorkout = guardrail.validate(workout: longWorkout, recoveryStatus: "recovered", loadStatus: "adapting")
        
        let totalDuration = safeWorkout.warmup.durationInMinutes +
                           safeWorkout.blocks.reduce(0) { $0 + $1.work.durationInMinutes + $1.recovery.durationInMinutes } +
                           safeWorkout.cooldown.durationInMinutes
        
        XCTAssertLessThanOrEqual(totalDuration, 60)
    }
}
