import Foundation
import Observation
import HealthKit

@Observable
final class SandboxStore {
    var logs: [String] = []
    
    private let healthStore = HKHealthStore()
    private let hrvProvider = HRVDataProvider()
    private let rhrProvider = RHRDataProvider()
    private let workoutProvider = WorkoutDataProvider()
    private let loadAgent = LoadAgentService()
    private let recoveryAgent = RecoveryAgentService()
    
    func log(_ message: String) {
        Task { @MainActor in
            logs.insert("\(Date().formatted(date: .omitted, time: .standard)): \(message)", at: 0)
        }
    }
    
    func authorize() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            log("HealthKit not available on this device.")
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.workoutType()
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            log("HealthKit Authorization Granted")
        } catch {
            log("Auth Failed: \(error.localizedDescription)")
        }
    }
    
    func testHRV() async {
        log("Fetching HRV (last 30 days)...")
        do {
            let end = Date()
            let start = Calendar.current.date(byAdding: .day, value: -30, to: end)!
            let samples = try await hrvProvider.requestTimeSeries(from: start, to: end)
            log("Fetched \(samples.count) daily HRV averages.")
            
            let trends = recoveryAgent.calculateMovingAverages(from: samples)
            let sevenDayStr = trends.sevenDay != nil ? String(format: "%.1f", trends.sevenDay!) : "N/A"
            let thirtyDayStr = trends.thirtyDay != nil ? String(format: "%.1f", trends.thirtyDay!) : "N/A"
            
            log("Readiness (7-day): \(sevenDayStr) ms | Baseline (30-day): \(thirtyDayStr) ms")
        } catch {
            log("HRV Fetch Error: \(error.localizedDescription)")
        }
    }
    
    func testRHR() async {
        log("Fetching RHR (last 7 days)...")
        do {
            let end = Date()
            let start = Calendar.current.date(byAdding: .day, value: -7, to: end)!
            let samples = try await rhrProvider.requestTimeSeries(from: start, to: end)
            log("Fetched \(samples.count) daily RHR averages.")
            
            if let first = samples.first {
                log("Most recent RHR: \(String(format: "%.1f", first.value)) bpm")
            }
        } catch {
            log("RHR Fetch Error: \(error.localizedDescription)")
        }
    }
    
    func testWorkouts() async {
        log("Fetching Workouts (last 7 days)...")
        do {
            let end = Date()
            let start = Calendar.current.date(byAdding: .day, value: -7, to: end)!
            let workouts = try await workoutProvider.requestWorkouts(from: start, to: end)
            log("Fetched \(workouts.count) workouts.")
            
            if let first = workouts.first {
                let durationMin = first.duration / 60.0
                let avgHR = first.averageHeartRate ?? 150.0
                let maxHR = first.maxHeartRate ?? 190.0
                
                // For TRIMP we also need RHR. We'll try to get it.
                let rhrSamples = try await rhrProvider.requestTimeSeries(from: start, to: end)
                let rhr = rhrSamples.first?.value ?? 60.0
                
                let trimp = loadAgent.calculateTRIMP(
                    durationInMinutes: durationMin,
                    avgHeartRate: avgHR,
                    maxHeartRate: maxHR,
                    restingHeartRate: rhr,
                    isMale: true // Testing as male
                )
                log("Last Workout: \(String(format: "%.0f", durationMin))m, Avg HR: \(String(format: "%.0f", avgHR))")
                log("Using RHR: \(String(format: "%.0f", rhr)) -> TRIMP: \(String(format: "%.1f", trimp))")
            }
        } catch {
            log("Workout Fetch Error: \(error.localizedDescription)")
        }
    }
}
