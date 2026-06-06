import Foundation
import Observation

@Observable
final class WorkoutPreviewStore {
    enum State {
        case idle
        case preview(CustomWorkoutComposition)
        case syncing
        case synced
        case error(String)
    }
    
    var state: State = .idle
    private let workoutKitService: WorkoutKitServiceProtocol
    
    init(workoutKitService: WorkoutKitServiceProtocol = WorkoutKitService()) {
        self.workoutKitService = workoutKitService
    }
    
    func setWorkout(_ workout: CustomWorkoutComposition) {
        self.state = .preview(workout)
    }
    
    func syncToWatch() async {
        guard case .preview(let workout) = state else { return }
        
        state = .syncing
        
        do {
            let authorized = try await workoutKitService.requestAuthorization()
            guard authorized else {
                state = .error("Permission denied for WorkoutKit.")
                return
            }
            
            try await workoutKitService.scheduleWorkout(workout)
            state = .synced
        } catch {
            state = .error("Failed to sync: \(error.localizedDescription)")
        }
    }
}
