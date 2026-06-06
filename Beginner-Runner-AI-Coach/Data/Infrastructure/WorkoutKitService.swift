import Foundation
import WorkoutKit
import HealthKit

final class WorkoutKitService: WorkoutKitServiceProtocol {
    
    /// Requests authorization to schedule workouts.
    func requestAuthorization() async throws -> Bool {
        if #available(iOS 17.0, *) {
            // Note: In iOS 17+, requestAuthorization() returns an AuthorizationStatus directly
            // or we use the status property. Based on documentation, we can just request.
            let status = await WorkoutScheduler.shared.requestAuthorization()
            return status == .authorized
        } else {
            // WorkoutKit is iOS 17+
            return false
        }
    }
    
    /// Maps our domain `CustomWorkoutComposition` to a native `WorkoutKit.CustomWorkout` and schedules it.
    func scheduleWorkout(_ composition: CustomWorkoutComposition) async throws {
        guard #available(iOS 17.0, *) else {
            throw WorkoutKitError.unsupportedOSVersion
        }
        
        // 1. Map Warmup
        let warmupStep = WorkoutStep(goal: .time(Double(composition.warmup.durationInMinutes), .minutes))
        
        // 2. Map Blocks
        let blocks = composition.blocks.map { block in
            let workStep = IntervalStep(
                .work,
                goal: .time(Double(block.work.durationInMinutes), .minutes),
                alert: intensityToAlert(block.work.intensityLevel)
            )
            let recoveryStep = IntervalStep(
                .recovery,
                goal: .time(Double(block.recovery.durationInMinutes), .minutes),
                alert: intensityToAlert(block.recovery.intensityLevel)
            )
            return IntervalBlock(steps: [workStep, recoveryStep], iterations: 1)
        }
        
        // 3. Map Cooldown
        let cooldownStep = WorkoutStep(goal: .time(Double(composition.cooldown.durationInMinutes), .minutes))
        
        // 4. Create CustomWorkout
        let customWorkout = CustomWorkout(
            activity: .running,
            location: .outdoor,
            displayName: "AI Coach: \(Date().formatted(date: .abbreviated, time: .omitted))",
            warmup: warmupStep,
            blocks: blocks,
            cooldown: cooldownStep
        )
        
        // 5. Schedule
        let plan = WorkoutPlan(.custom(customWorkout))
        
        // Schedule for today
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        
        try await WorkoutScheduler.shared.schedule(plan, at: components)
    }
    
    private func intensityToAlert(_ level: WorkoutIntensity?) -> (any WorkoutAlert)? {
        // Simple mapping from our intensity levels to Heart Rate zones or speed if needed.
        // For now, we'll keep it simple as WorkoutKit alerts are complex to setup without specific user HR zones.
        // We could potentially add .heartRate zone alerts here.
        return nil
    }
}

enum WorkoutKitError: Error {
    case unsupportedOSVersion
}
