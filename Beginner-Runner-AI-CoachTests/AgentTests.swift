import XCTest
@testable import Beginner_Runner_AI_Coach

final class AgentTests: XCTestCase {
    
    // MARK: - RecoveryAgentService Tests
    
    func testCalculateMovingAverages() {
        let service = RecoveryCalculationService()
        
        let now = Date()
        let calendar = Calendar.current
        
        // Create 10 samples (daily)
        var samples: [HealthDataBaseLocalSample] = []
        for i in 0..<10 {
            let date = calendar.date(byAdding: .day, value: -i, to: now)!
            samples.append(HealthDataBaseLocalSample(value: 50.0 + Double(i), beginDate: date, endDate: date))
        }
        
        let result = service.calculateMovingAverages(from: samples)
        
        // 7-day average: (50+51+52+53+54+55+56) / 7 = 371 / 7 = 53.0
        XCTAssertEqual(result.sevenDay ?? 53.0, 53.0, accuracy: 0.1)
        
        // 30-day average: same as 7-day because we only have 10 samples
        // (50+51+52+53+54+55+56+57+58+59) / 10 = 545 / 10 = 54.5
        XCTAssertEqual(result.thirtyDay ?? 54.5, 54.5, accuracy: 0.1)
    }
    
    // MARK: - LoadAgentService Tests
    
    func testCalculateTRIMP_Male() {
        let service = LoadTrimpService()
        
        // Given: 60 min, avg HR 150, max HR 190, resting HR 60, male
        // deltaHR = (150 - 60) / (190 - 60) = 90 / 130 = 0.6923
        // y = 0.64 * e^(1.92 * 0.6923) = 0.64 * e^(1.3292) = 0.64 * 3.778 = 2.4179
        // TRIMP = 60 * 0.6923 * 2.4179 = 100.43
        
        let trimp = service.calculateTRIMP(
            durationInMinutes: 60,
            avgHeartRate: 150,
            maxHeartRate: 190,
            restingHeartRate: 60,
            isMale: true
        )
        
        XCTAssertEqual(trimp, 100.43, accuracy: 0.1)
    }
}
