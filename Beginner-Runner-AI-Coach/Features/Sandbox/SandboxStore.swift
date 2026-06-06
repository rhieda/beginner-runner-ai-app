import Foundation
import Observation
import HealthKit

@Observable
final class SandboxStore {
    var logs: [String] = []
    var generatedWorkout: CustomWorkoutComposition? = nil
    
    var selectedProvider: LLMProviderType = .mock
    
    private let healthStore = HKHealthStore()
    private let hrvProvider = HRVDataProvider()
    private let rhrProvider = RHRDataProvider()
    private let workoutProvider = WorkoutDataProvider()
    private let loadAgent = LoadAgentService()
    private let recoveryAgent = RecoveryAgentService()
    
    // Compute Orchestrator based on selected provider
    private var aiOrchestrator: AgentOrchestrator {
        AgentOrchestrator(provider: LLMProviderFactory.create(type: selectedProvider))
    }
    
    func log(_ message: String) {
        Task { @MainActor in
            logs.insert("\(Date().formatted(date: .omitted, time: .standard)): \(message)", at: 0)
        }
    }
    
    func clearLogs() {
        logs.removeAll()
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
            
            // Log each day
            for sample in samples.sorted(by: { $0.beginDate > $1.beginDate }) {
                let dateStr = sample.beginDate.formatted(date: .numeric, time: .omitted)
                log("  [\(dateStr)]: \(String(format: "%.1f", sample.value)) ms")
            }
            
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
            
            // Log each day
            for sample in samples.sorted(by: { $0.beginDate > $1.beginDate }) {
                let dateStr = sample.beginDate.formatted(date: .numeric, time: .omitted)
                log("  [\(dateStr)]: \(String(format: "%.1f", sample.value)) bpm")
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

    func testAIAgents() async {
        log("Executing AI Multi-Agent Orchestrator...")
        do {
            let start = CFAbsoluteTimeGetCurrent()
            
            // In a real scenario, these values would come from the specific data providers.
            // Using mocked biometrics for the sandbox demonstration.
            let workout = try await aiOrchestrator.generateWorkout(
                trimpScore: 65.4,
                recentWorkouts: [],
                sevenDayHRV: 55.2,
                thirtyDayHRV: 56.1,
                userGoal: "Build endurance without injury",
                logger: { [weak self] message in
                    self?.log(message)
                }
            )
            
            await MainActor.run {
                self.generatedWorkout = workout
            }
            
            let duration = CFAbsoluteTimeGetCurrent() - start
            
            log("✅ Pipeline completed in \(String(format: "%.2f", duration))s")
            log("🏋️ Generated Workout:")
            log("Warmup: \(workout.warmup.durationInMinutes)m")
            for (index, block) in workout.blocks.enumerated() {
                let intensity = block.work.intensityLevel?.rawValue ?? "Moderate"
                log("Block \(index + 1): \(block.work.durationInMinutes)m (\(intensity)) | Rec: \(block.recovery.durationInMinutes)m")
            }
            log("Cooldown: \(workout.cooldown.durationInMinutes)m")
            
        } catch {
            log("❌ AI Agent Pipeline Error: \(error.localizedDescription)")
        }
    }
}
