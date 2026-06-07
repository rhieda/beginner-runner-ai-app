import XCTest
@testable import Beginner_Runner_AI_Coach

final class SandboxStoreTests: XCTestCase {
    
    func testMockProviderSelected() async {
        let store = SandboxStore()
        store.selectedProvider = .mock
        store.clearLogs()
        
        await store.testAIAgents()
        
        XCTAssertTrue(store.logs.contains { $0.contains("Using mocked biometrics for the sandbox demonstration.") })
        XCTAssertNotNil(store.generatedWorkout)
    }
    
    func testRealProviderSelected() async {
        let store = SandboxStore()
        store.selectedProvider = .gpt4o
        store.clearLogs()
        
        await store.testAIAgents()
        
        XCTAssertTrue(store.logs.contains { $0.contains("Collecting real HealthKit metrics for AI Orchestrator...") })
    }
}
