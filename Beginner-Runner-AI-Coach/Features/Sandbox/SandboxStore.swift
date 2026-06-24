import Foundation
import Observation
import HealthKit

@Observable
final class SandboxStore {
    var logs: [String] = []
    var generatedWorkout: CustomWorkoutComposition? = nil
    
    var selectedLLMProvider: LLMProviderType = .mock {
        didSet {
            if selectedLLMProvider == .mock {
                useSimulatedMetrics = true
            }
        }
    }
    
    var useSimulatedMetrics: Bool = true
    var simulatedTrimp: Double = 65.4
    var simulatedSevenDayHRV: Double = 55.2
    var simulatedThirtyDayHRV: Double = 56.1
    var simulatedUserGoal: String = "Build endurance without injury"
    
    private let healthStore = HKHealthStore()
    private let hrvProvider = HRVDataProvider()
    private let rhrProvider = RHRDataProvider()
    private let workoutProvider = WorkoutDataProvider()
    private let localLoadAgent = LoadAgentService()
    private let localRecoveryAgent = RecoveryAgentService()
    
    // Compute Orchestrator based on selected provider
    private var aiOrchestrator: AgentOrchestrator {
        AgentOrchestrator(provider: LLMProviderFactory.create(type: selectedLLMProvider))
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
            
            let trends = localRecoveryAgent.calculateMovingAverages(from: samples)
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
                
                let trimp = localLoadAgent.calculateTRIMP(
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
    
    // MARK: - Real integration

    struct RealBiometrics {
        let sevenDayHRV: Double
        let thirtyDayHRV: Double
        let recentWorkouts: [LoadAgentInput.WorkoutEntry]
        let trimpScore: Double
    }

    private func fetchAndCalculateHRV(end: Date) async -> (sevenDay: Double, thirtyDay: Double) {
        let start30 = Calendar.current.date(byAdding: .day, value: -30, to: end)!
        var sevenDayHRV: Double = simulatedSevenDayHRV
        var thirtyDayHRV: Double = simulatedThirtyDayHRV
        
        do {
            let hrvSamples = try await hrvProvider.requestTimeSeries(from: start30, to: end)
            let trends = localRecoveryAgent.calculateMovingAverages(from: hrvSamples)
            if let seven = trends.sevenDay {
                sevenDayHRV = seven
            } else {
                log("⚠️ No 7-day HRV average calculated. Using default: \(sevenDayHRV)")
            }
            if let thirty = trends.thirtyDay {
                thirtyDayHRV = thirty
            } else {
                log("⚠️ No 30-day HRV average calculated. Using default: \(thirtyDayHRV)")
            }
        } catch {
            log("⚠️ HRV fetch error: \(error.localizedDescription). Using default values.")
        }
        return (sevenDayHRV, thirtyDayHRV)
    }

    private func fetchAndMapWorkouts(end: Date) async -> ([WorkoutSample], [LoadAgentInput.WorkoutEntry]) {
        let start7 = Calendar.current.date(byAdding: .day, value: -7, to: end)!
        var workouts: [WorkoutSample] = []
        do {
            workouts = try await workoutProvider.requestWorkouts(from: start7, to: end)
            log("Fetched \(workouts.count) real workouts from last 7 days.")
        } catch {
            log("⚠️ Workouts fetch error: \(error.localizedDescription).")
        }
        
        let mapped = workouts.map { sample -> LoadAgentInput.WorkoutEntry in
            let avgHR = sample.averageHeartRate ?? 150.0
            let maxHR = sample.maxHeartRate ?? 190.0
            let ratio = avgHR / maxHR
            let intensityStr = ratio < 0.65 ? "low" : (ratio < 0.85 ? "moderate" : "high")
            
            return LoadAgentInput.WorkoutEntry(
                date: sample.startDate.formatted(date: .numeric, time: .omitted),
                duration: Int(sample.duration / 60.0),
                intensity: intensityStr
            )
        }
        return (workouts, mapped)
    }

    private func calculateLastWorkoutTRIMP(lastWorkout: WorkoutSample?, end: Date) async -> Double {
        guard let first = lastWorkout else {
            log("No workouts in the last 7 days. TRIMP: 0.0")
            return 0.0
        }
        
        let durationMin = first.duration / 60.0
        let avgHR = first.averageHeartRate ?? 150.0
        let maxHR = first.maxHeartRate ?? 190.0
        
        var rhr = 60.0
        do {
            let start7 = Calendar.current.date(byAdding: .day, value: -7, to: end)!
            let rhrSamples = try await rhrProvider.requestTimeSeries(from: start7, to: end)
            rhr = rhrSamples.first?.value ?? 60.0
        } catch {
            log("⚠️ RHR fetch error: \(error.localizedDescription). Using baseline: 60.0 bpm.")
        }
        
        let trimp = localLoadAgent.calculateTRIMP(
            durationInMinutes: durationMin,
            avgHeartRate: avgHR,
            maxHeartRate: maxHR,
            restingHeartRate: rhr,
            isMale: true // Testing as male
        )
        log("Calculated TRIMP for last workout: \(String(format: "%.1f", trimp))")
        return trimp
    }

    private func collectRealBiometrics(end: Date) async -> RealBiometrics {
        log("Collecting real HealthKit metrics for AI Orchestrator...")
        let hrv = await fetchAndCalculateHRV(end: end)
        let workoutsData = await fetchAndMapWorkouts(end: end)
        let trimp = await calculateLastWorkoutTRIMP(lastWorkout: workoutsData.0.first, end: end)
        
        return RealBiometrics(
            sevenDayHRV: hrv.sevenDay,
            thirtyDayHRV: hrv.thirtyDay,
            recentWorkouts: workoutsData.1,
            trimpScore: trimp
        )
    }

    func testAIAgents() async {
        log("Executing AI Multi-Agent Orchestrator...")
        do {
            let start = CFAbsoluteTimeGetCurrent()
            let workout: CustomWorkoutComposition
            
            if selectedLLMProvider == .mock || useSimulatedMetrics {
                log("Using simulated metrics for the sandbox execution.")
                log("Parameters simulated: HRV 7d=\(String(format: "%.1f", simulatedSevenDayHRV)) | 30d=\(String(format: "%.1f", simulatedThirtyDayHRV)) | TRIMP=\(String(format: "%.1f", simulatedTrimp))")
                
                workout = try await aiOrchestrator.generateWorkout(
                    trimpScore: simulatedTrimp,
                    recentWorkouts: [],
                    sevenDayHRV: simulatedSevenDayHRV,
                    thirtyDayHRV: simulatedThirtyDayHRV,
                    userGoal: simulatedUserGoal,
                    logger: { [weak self] message in
                        self?.log(message)
                    }
                )
            } else {
                let metrics = await collectRealBiometrics(end: Date())
                log("Parameters collected: HRV 7d=\(String(format: "%.1f", metrics.sevenDayHRV)) | 30d=\(String(format: "%.1f", metrics.thirtyDayHRV)) | TRIMP=\(String(format: "%.1f", metrics.trimpScore))")
                
                workout = try await aiOrchestrator.generateWorkout(
                    trimpScore: metrics.trimpScore,
                    recentWorkouts: metrics.recentWorkouts,
                    sevenDayHRV: metrics.sevenDayHRV,
                    thirtyDayHRV: metrics.thirtyDayHRV,
                    userGoal: simulatedUserGoal,
                    logger: { [weak self] message in
                        self?.log(message)
                    }
                )
            }
            
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
