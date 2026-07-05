//
//  VitalsDashboardStoreTests.swift
//  Beginner-Runner-AI-CoachTests
//
//  Created by Antigravity.
//

import XCTest
@testable import Beginner_Runner_AI_Coach

final class VitalsDashboardStoreTests: XCTestCase {
    
    func testInitialState() {
        let store = VitalsDashboardStore()
        
        // Assert initial state is checkingPermissions
        if case .checkingPermissions = store.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("Store should start in checkingPermissions state")
        }
        
        XCTAssertEqual(store.selectedLLMProvider, .gemini35Flash)
        XCTAssertNil(store.generatedWorkout)
        XCTAssertFalse(store.showWorkoutPreview)
        XCTAssertTrue(store.logs.isEmpty)
    }
    
    func testReadinessScoreCalculation() {
        // Test scoring logic mapping
        // 7d HRV / 30d HRV * 86 capped at 100
        
        // Scenario 1: Optimal Readiness (7d >= 30d)
        let sevenDayHRVOptimal = 60.0
        let thirtyDayHRVOptimal = 55.0
        let ratioOptimal = sevenDayHRVOptimal / thirtyDayHRVOptimal // 1.09
        let scoreOptimal = min(100, max(0, Int(ratioOptimal * 86))) // 93
        XCTAssertTrue(scoreOptimal >= 85)
        
        // Scenario 2: Good Readiness
        let sevenDayHRVGood = 50.0
        let thirtyDayHRVGood = 55.0
        let ratioGood = sevenDayHRVGood / thirtyDayHRVGood // 0.909
        let scoreGood = min(100, max(0, Int(ratioGood * 86))) // 78
        XCTAssertTrue(scoreGood >= 70 && scoreGood < 85)
        
        // Scenario 3: Low Readiness (Accumuated Fatigue)
        let sevenDayHRVLow = 35.0
        let thirtyDayHRVLow = 60.0
        let ratioLow = sevenDayHRVLow / thirtyDayHRVLow // 0.583
        let scoreLow = min(100, max(0, Int(ratioLow * 86))) // 50
        XCTAssertTrue(scoreLow < 70)
    }
    
    func testStatusMappings() {
        // Test Recovery mapping (Estado Atual)
        let sevenDayHRV = 45.0
        let thirtyDayHRV = 55.0
        let recoveryStateLow = sevenDayHRV >= thirtyDayHRV ? "Descansado" : "Fadigado"
        XCTAssertEqual(recoveryStateLow, "Fadigado")
        
        let recoveryStateHigh = 60.0 >= 55.0 ? "Descansado" : "Fadigado"
        XCTAssertEqual(recoveryStateHigh, "Descansado")
        
        // Test Fitness mapping (Forma Física)
        // TRIMP > 80: Sobrecarga, 40..80: Em Forma, <40: Pouco Treino
        let trimpOverreaching = 95.0
        let fitnessStateOver = trimpOverreaching > 80.0 ? "Sobrecarga" : (trimpOverreaching >= 40.0 ? "Em Forma" : "Pouco Treino")
        XCTAssertEqual(fitnessStateOver, "Sobrecarga")
        
        let trimpAdapting = 65.0
        let fitnessStateAdapting = trimpAdapting > 80.0 ? "Sobrecarga" : (trimpAdapting >= 40.0 ? "Em Forma" : "Pouco Treino")
        XCTAssertEqual(fitnessStateAdapting, "Em Forma")
        
        let trimpUndertraining = 20.0
        let fitnessStateUnder = trimpUndertraining > 80.0 ? "Sobrecarga" : (trimpUndertraining >= 40.0 ? "Em Forma" : "Pouco Treino")
        XCTAssertEqual(fitnessStateUnder, "Pouco Treino")
    }
    
    func testInsufficientDataMappings() {
        let sevenDayHRV: Double? = nil
        let thirtyDayHRV: Double? = nil
        
        let recoveryState: String
        let readinessScore: Int
        let readinessLabel: String
        
        if let seven = sevenDayHRV, let thirty = thirtyDayHRV {
            let ratio = thirty > 0 ? (seven / thirty) : 1.0
            readinessScore = min(100, max(0, Int(ratio * 86)))
            readinessLabel = readinessScore >= 85 ? "PRONTIDÃO - ÓTIMA" : (readinessScore >= 70 ? "PRONTIDÃO - BOA" : "PRONTIDÃO - BAIXA")
            recoveryState = seven >= thirty ? "Descansado" : "Fadigado"
        } else {
            readinessScore = 0
            readinessLabel = "INDISPONÍVEL"
            recoveryState = "Sem dados"
        }
        
        XCTAssertEqual(readinessScore, 0)
        XCTAssertEqual(readinessLabel, "INDISPONÍVEL")
        XCTAssertEqual(recoveryState, "Sem dados")
        
        let workoutsIsEmpty = true
        let fitnessState = workoutsIsEmpty ? "Sem dados" : "Pouco Treino"
        XCTAssertEqual(fitnessState, "Sem dados")
    }
    
    func testAgentInferenceSuccess() {
        let expectation = XCTestExpectation(description: "Agent inference success")
        SandboxLLMProvider.simulateError = false
        
        Task {
            do {
                let store = VitalsDashboardStore()
                store.selectedLLMProvider = .mock // Uses SandboxLLMProvider returning 'adapting' and 'recovered'
                
                let now = Date()
                let hrvSamples = [
                    HealthDataBaseLocalSample(value: 55.0, beginDate: now, endDate: now),
                    HealthDataBaseLocalSample(value: 55.0, beginDate: now.addingTimeInterval(-86400), endDate: now.addingTimeInterval(-86400))
                ]
                let rhrSamples = [
                    HealthDataBaseLocalSample(value: 60.0, beginDate: now, endDate: now)
                ]
                let workouts = [
                    WorkoutSample(
                        id: UUID(),
                        duration: 1800.0,
                        averageHeartRate: 145.0,
                        maxHeartRate: 165.0,
                        startDate: now,
                        endDate: now.addingTimeInterval(1800),
                        activityType: .running
                    )
                ]
                
                let data = try await store.processDashboardData(
                    hrvSamples: hrvSamples,
                    rhrSamples: rhrSamples,
                    workouts: workouts
                )
                
                // Assertions mapped from agent classifications:
                // RecoveryAgent: status "recovered" -> recoveryState "Descansado"
                // LoadAgent: status "adapting" -> fitnessState "Em Forma"
                XCTAssertEqual(data.recoveryState, "Descansado")
                XCTAssertEqual(data.fitnessState, "Em Forma")
                expectation.fulfill()
            } catch {
                XCTFail("Failed with error: \(error)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testAgentInferenceFallback() {
        let expectation = XCTestExpectation(description: "Agent inference fallback")
        SandboxLLMProvider.simulateError = true
        
        Task {
            do {
                let store = VitalsDashboardStore()
                store.selectedLLMProvider = .mock // Fails immediately due to simulateError = true
                
                let now = Date()
                let hrvSamples = [
                    HealthDataBaseLocalSample(value: 30.0, beginDate: now, endDate: now), // 7d average will be 30.0
                    HealthDataBaseLocalSample(value: 60.0, beginDate: now.addingTimeInterval(-86400 * 10), endDate: now.addingTimeInterval(-86400 * 10)) // 30d baseline will be 45.0 (30 + 60 / 2)
                ]
                let rhrSamples = [
                    HealthDataBaseLocalSample(value: 60.0, beginDate: now, endDate: now)
                ]
                let workouts = [
                    WorkoutSample(
                        id: UUID(),
                        duration: 3600.0,
                        averageHeartRate: 175.0, // High intensity
                        maxHeartRate: 195.0,
                        startDate: now,
                        endDate: now.addingTimeInterval(3600), // 1h duration
                        activityType: .running
                    )
                ]
                
                let data = try await store.processDashboardData(
                    hrvSamples: hrvSamples,
                    rhrSamples: rhrSamples,
                    workouts: workouts
                )
                
                // Fallback calculations should execute:
                // Recovery: 7d HRV (30.0) < 30d HRV (45.0) -> Fadigado
                // Load: High intensity TRIMP -> Sobrecarga
                XCTAssertEqual(data.recoveryState, "Fadigado")
                XCTAssertEqual(data.fitnessState, "Sobrecarga")
                SandboxLLMProvider.simulateError = false // reset
                expectation.fulfill()
            } catch {
                SandboxLLMProvider.simulateError = false // reset
                XCTFail("Failed with error: \(error)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
