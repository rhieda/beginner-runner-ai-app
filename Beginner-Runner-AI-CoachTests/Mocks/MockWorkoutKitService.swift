import Foundation
@testable import Beginner_Runner_AI_Coach

final class MockWorkoutKitService: WorkoutKitServiceProtocol {
    var requestAuthorizationResult: Bool = true
    var requestAuthorizationError: Error?
    var scheduleWorkoutError: Error?
    
    var lastScheduledWorkout: CustomWorkoutComposition?
    
    func requestAuthorization() async throws -> Bool {
        if let error = requestAuthorizationError {
            throw error
        }
        return requestAuthorizationResult
    }
    
    func scheduleWorkout(_ workout: CustomWorkoutComposition) async throws {
        if let error = scheduleWorkoutError {
            throw error
        }
        lastScheduledWorkout = workout
    }
}
