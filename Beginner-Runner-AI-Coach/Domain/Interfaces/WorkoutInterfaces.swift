import Foundation

protocol WorkoutKitServiceProtocol {
    func requestAuthorization() async throws -> Bool
    func scheduleWorkout(_ workout: CustomWorkoutComposition) async throws
}
