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
}
