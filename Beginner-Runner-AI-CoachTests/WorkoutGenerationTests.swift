import XCTest
@testable import Beginner_Runner_AI_Coach

final class WorkoutGenerationTests: XCTestCase {
    
    var mockService: MockWorkoutKitService!
    var store: WorkoutPreviewStore!
    
    override func setUp() {
        super.setUp()
        mockService = MockWorkoutKitService()
        store = WorkoutPreviewStore(workoutKitService: mockService)
    }
    
    func testSetWorkoutChangesStateToPreview() {
        // Given
        let workout = createSampleWorkout()
        
        // When
        store.setWorkout(workout)
        
        // Then
        if case .preview(let receivedWorkout) = store.state {
            XCTAssertEqual(receivedWorkout.warmup.durationInMinutes, 5)
            XCTAssertEqual(receivedWorkout.blocks.count, 2)
        } else {
            XCTFail("Expected .preview state")
        }
    }
    
    func testSyncToWatchSuccess() async {
        // Given
        let workout = createSampleWorkout()
        store.setWorkout(workout)
        mockService.requestAuthorizationResult = true
        
        // When
        await store.syncToWatch()
        
        // Then
        if case .synced = store.state {
            XCTAssertNotNil(mockService.lastScheduledWorkout)
            XCTAssertEqual(mockService.lastScheduledWorkout?.warmup.durationInMinutes, 5)
        } else {
            XCTFail("Expected .synced state, got \(store.state)")
        }
    }
    
    func testSyncToWatchAuthorizationDenied() async {
        // Given
        let workout = createSampleWorkout()
        store.setWorkout(workout)
        mockService.requestAuthorizationResult = false
        
        // When
        await store.syncToWatch()
        
        // Then
        if case .error(let message) = store.state {
            XCTAssertTrue(message.contains("Permission denied"))
        } else {
            XCTFail("Expected .error state due to denied authorization")
        }
    }
    
    func testSyncToWatchFailure() async {
        // Given
        let workout = createSampleWorkout()
        store.setWorkout(workout)
        mockService.scheduleWorkoutError = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "System Error"])
        
        // When
        await store.syncToWatch()
        
        // Then
        if case .error(let message) = store.state {
            XCTAssertTrue(message.contains("System Error"))
        } else {
            XCTFail("Expected .error state due to schedule failure")
        }
    }
    
    // MARK: - Helpers
    
    private func createSampleWorkout() -> CustomWorkoutComposition {
        return CustomWorkoutComposition(
            warmup: .init(durationInMinutes: 5, intensityLevel: .low),
            blocks: [
                .init(work: .init(durationInMinutes: 3, intensityLevel: .moderate),
                      recovery: .init(durationInMinutes: 2, intensityLevel: .low)),
                .init(work: .init(durationInMinutes: 3, intensityLevel: .moderate),
                      recovery: .init(durationInMinutes: 2, intensityLevel: .low))
            ],
            cooldown: .init(durationInMinutes: 5, intensityLevel: .low)
        )
    }
}
