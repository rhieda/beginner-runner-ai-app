import Foundation
import Observation
import HealthKit

@Observable
final class VitalsDashboardStore {
    enum State {
        case checkingPermissions
        case notAuthorized
        case loadingData
        case emptyData
        case loaded(VitalsDashboardData)
        case error(String)
        case generatingWorkout(logs: [String])
    }
    
    var state: State = .checkingPermissions
    var selectedLLMProvider: LLMProviderType = .gemini35Flash
    var logs: [String] = []
    var generatedWorkout: CustomWorkoutComposition?
    var showWorkoutPreview: Bool = false
    
    private let healthStore = HKHealthStore()
    private let hrvProvider = HRVDataProvider()
    private let rhrProvider = RHRDataProvider()
    private let workoutProvider = WorkoutDataProvider()
    private let localLoadAgent = LoadTrimpService()
    private let localRecoveryAgent = RecoveryCalculationService()
    
    init() {}
    
    func log(_ message: String) {
        Task { @MainActor in
            logs.insert("\(Date().formatted(date: .omitted, time: .standard)): \(message)", at: 0)
        }
    }
    
    func checkPermissionsAndLoadData() async {
        await MainActor.run {
            self.state = .checkingPermissions
        }
        
        guard HKHealthStore.isHealthDataAvailable() else {
            await MainActor.run {
                self.state = .notAuthorized
            }
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
            // Fetch permissions are requested or authorized, proceed to load
            await loadData()
        } catch {
            await MainActor.run {
                self.state = .notAuthorized
            }
        }
    }
    
    func loadData() async {
        await MainActor.run {
            self.state = .loadingData
        }
        
        let end = Date()
        let start30 = Calendar.current.date(byAdding: .day, value: -30, to: end)!
        let start7 = Calendar.current.date(byAdding: .day, value: -7, to: end)!
        
        do {
            let (hrvSamples, rhrSamples, workouts) = try await fetchRawData(
                start30: start30,
                start7: start7,
                end: end
            )
            
            // Check if there is absolutely no data
            if hrvSamples.isEmpty && rhrSamples.isEmpty {
                await MainActor.run {
                    self.state = .emptyData
                }
                return
            }
            
            let dashboardData = processDashboardData(
                hrvSamples: hrvSamples,
                rhrSamples: rhrSamples,
                workouts: workouts
            )
            
            await MainActor.run {
                self.state = .loaded(dashboardData)
            }
        } catch {
            await MainActor.run {
                self.state = .error("Erro ao carregar dados: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchRawData(
        start30: Date,
        start7: Date,
        end: Date
    ) async throws -> (
        hrv: [HealthDataBaseLocalSample],
        rhr: [HealthDataBaseLocalSample],
        workouts: [WorkoutSample]
    ) {
        let hrvSamples = try await hrvProvider.requestTimeSeries(from: start30, to: end)
        let rhrSamples = try await rhrProvider.requestTimeSeries(from: start30, to: end)
        let workouts = try await workoutProvider.requestWorkouts(from: start7, to: end)
        return (hrvSamples, rhrSamples, workouts)
    }
    
    private func processDashboardData(
        hrvSamples: [HealthDataBaseLocalSample],
        rhrSamples: [HealthDataBaseLocalSample],
        workouts: [WorkoutSample]
    ) -> VitalsDashboardData {
        // Perform recovery calculations
        let hrvTrends = localRecoveryAgent.calculateMovingAverages(from: hrvSamples)
        
        let readinessScore: Int
        let readinessLabel: String
        let recoveryState: String
        let hrvCurrent = hrvSamples.sorted { $0.beginDate > $1.beginDate }.first?.value ?? 0.0
        
        if let sevenDayHRV = hrvTrends.sevenDay, let thirtyDayHRV = hrvTrends.thirtyDay {
            // Calculate Readiness Score
            let ratio = thirtyDayHRV > 0 ? (sevenDayHRV / thirtyDayHRV) : 1.0
            readinessScore = min(100, max(0, Int(ratio * 86)))
            
            if readinessScore >= 85 {
                readinessLabel = "PRONTIDÃO - ÓTIMA"
            } else if readinessScore >= 70 {
                readinessLabel = "PRONTIDÃO - BOA"
            } else {
                readinessLabel = "PRONTIDÃO - BAIXA"
            }
            
            recoveryState = sevenDayHRV >= thirtyDayHRV ? "Descansado" : "Fadigado"
        } else {
            readinessScore = 0
            readinessLabel = "INDISPONÍVEL"
            recoveryState = "Sem dados"
        }
        
        // HRV metrics
        let hrvTrend = hrvSamples.sorted { $0.beginDate < $1.beginDate }.suffix(7).map { $0.value }
        let hrvAverage = hrvTrend.isEmpty ? 0.0 : hrvTrend.reduce(0.0, +) / Double(hrvTrend.count)
        let hrvMax = hrvTrend.max() ?? 0.0
        let hrvMin = hrvTrend.min() ?? 0.0
        
        // Calculate change percentage vs yesterday
        let hrvChangePercentage: Double
        if hrvSamples.count >= 2 {
            let sortedHrv = hrvSamples.sorted { $0.beginDate > $1.beginDate }
            let todayVal = sortedHrv[0].value
            let yesterdayVal = sortedHrv[1].value
            hrvChangePercentage = yesterdayVal > 0 ? ((todayVal - yesterdayVal) / yesterdayVal) * 100 : 0.0
        } else {
            hrvChangePercentage = 0.0
        }
        
        // RHR metrics
        let rhrTrend = rhrSamples.sorted { $0.beginDate < $1.beginDate }.suffix(7).map { $0.value }
        let rhrCurrent = rhrSamples.sorted { $0.beginDate > $1.beginDate }.first?.value ?? 0.0
        let rhrAverage = rhrTrend.isEmpty ? 0.0 : rhrTrend.reduce(0.0, +) / Double(rhrTrend.count)
        let rhrMax = rhrTrend.max() ?? 0.0
        let rhrMin = rhrTrend.min() ?? 0.0
        
        // Determine RHR status/trend
        let rhrStatus: String
        if rhrTrend.count >= 2 {
            let firstHalf = rhrTrend.prefix(rhrTrend.count / 2)
            let secondHalf = rhrTrend.suffix(rhrTrend.count / 2)
            let firstHalfAvg = firstHalf.reduce(0.0, +) / Double(firstHalf.count)
            let secondHalfAvg = secondHalf.reduce(0.0, +) / Double(secondHalf.count)
            let change = secondHalfAvg - firstHalfAvg
            if change > 2.0 {
                rhrStatus = "ELEVADO"
            } else if change < -2.0 {
                rhrStatus = "EM QUEDA"
            } else {
                rhrStatus = "ESTÁVEL"
            }
        } else {
            rhrStatus = "ESTÁVEL"
        }
        
        // Calculate last workout TRIMP
        var lastWorkoutTRIMP = 0.0
        if let lastWorkout = workouts.first {
            let durationMin = lastWorkout.duration / 60.0
            let avgHR = lastWorkout.averageHeartRate ?? 150.0
            let maxHR = lastWorkout.maxHeartRate ?? 190.0
            let trimpRHR = rhrCurrent > 0 ? rhrCurrent : 60.0
            lastWorkoutTRIMP = localLoadAgent.calculateTRIMP(
                durationInMinutes: durationMin,
                avgHeartRate: avgHR,
                maxHeartRate: maxHR,
                restingHeartRate: trimpRHR,
                isMale: true
            )
        }
        
        // Fitness state mapping
        // TODO: rever limites de TRIMP após validação científica (proposição arbitrária)
        let fitnessState: String
        if workouts.isEmpty {
            fitnessState = "Sem dados"
        } else if lastWorkoutTRIMP > 80.0 {
            fitnessState = "Sobrecarga"
        } else if lastWorkoutTRIMP >= 40.0 {
            fitnessState = "Em Forma"
        } else {
            fitnessState = "Pouco Treino"
        }
        
        return VitalsDashboardData(
            readinessScore: readinessScore,
            readinessLabel: readinessLabel,
            hrvCurrent: hrvCurrent,
            hrvTrend: hrvTrend,
            hrvChangePercentage: hrvChangePercentage,
            hrvAverage: hrvAverage,
            hrvMax: hrvMax,
            hrvMin: hrvMin,
            rhrCurrent: rhrCurrent,
            rhrTrend: rhrTrend,
            rhrAverage: rhrAverage,
            rhrMax: rhrMax,
            rhrMin: rhrMin,
            rhrStatus: rhrStatus,
            fitnessState: fitnessState,
            recoveryState: recoveryState
        )
    }
    
    func generateWorkout(data: VitalsDashboardData) async {
        await MainActor.run {
            self.state = .generatingWorkout(logs: [])
        }
        
        log("Iniciando Pipeline de Multiagentes...")
        
        let provider = LLMProviderFactory.create(type: selectedLLMProvider)
        let orchestrator = AgentOrchestrator(provider: provider)
        
        let end = Date()
        let start7 = Calendar.current.date(byAdding: .day, value: -7, to: end)!
        
        var recentWorkouts: [LoadAgentInput.WorkoutEntry] = []
        var trimpScore = 0.0
        
        do {
            let workouts = try await workoutProvider.requestWorkouts(from: start7, to: end)
            recentWorkouts = workouts.map { sample -> LoadAgentInput.WorkoutEntry in
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
            
            if let first = workouts.first {
                let durationMin = first.duration / 60.0
                let avgHR = first.averageHeartRate ?? 150.0
                let maxHR = first.maxHeartRate ?? 190.0
                trimpScore = localLoadAgent.calculateTRIMP(
                    durationInMinutes: durationMin,
                    avgHeartRate: avgHR,
                    maxHeartRate: maxHR,
                    restingHeartRate: data.rhrCurrent,
                    isMale: true
                )
            }
        } catch {
            log("Aviso: Falha ao carregar histórico de treinos. Usando padrão.")
        }
        
        // Calculate moving averages from HRV averages
        let start30 = Calendar.current.date(byAdding: .day, value: -30, to: end)!
        var sevenDayHRV = 55.2
        var thirtyDayHRV = 56.1
        do {
            let hrvSamples = try await hrvProvider.requestTimeSeries(from: start30, to: end)
            let trends = localRecoveryAgent.calculateMovingAverages(from: hrvSamples)
            sevenDayHRV = trends.sevenDay ?? sevenDayHRV
            thirtyDayHRV = trends.thirtyDay ?? thirtyDayHRV
        } catch {
            log("Aviso: Falha ao carregar HRV histórico. Usando padrão.")
        }
        
        do {
            let workout = try await orchestrator.generateWorkout(
                trimpScore: trimpScore,
                recentWorkouts: recentWorkouts,
                sevenDayHRV: sevenDayHRV,
                thirtyDayHRV: thirtyDayHRV,
                userGoal: "Build endurance without injury",
                logger: { [weak self] message in
                    self?.log(message)
                }
            )
            
            await MainActor.run {
                self.generatedWorkout = workout
                self.showWorkoutPreview = true
                self.state = .loaded(data)
            }
        } catch {
            log("Erro na geração: \(error.localizedDescription)")
            await MainActor.run {
                self.state = .loaded(data)
            }
        }
    }
}

// MARK: - Dashboard Data Object
struct VitalsDashboardData {
    let readinessScore: Int
    let readinessLabel: String
    
    // HRV
    let hrvCurrent: Double
    let hrvTrend: [Double]
    let hrvChangePercentage: Double
    let hrvAverage: Double
    let hrvMax: Double
    let hrvMin: Double
    
    // RHR
    let rhrCurrent: Double
    let rhrTrend: [Double]
    let rhrAverage: Double
    let rhrMax: Double
    let rhrMin: Double
    let rhrStatus: String
    
    // Status
    let fitnessState: String
    let recoveryState: String
}
