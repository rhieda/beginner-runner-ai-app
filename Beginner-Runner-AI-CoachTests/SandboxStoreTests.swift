import XCTest
@testable import Beginner_Runner_AI_Coach

final class SandboxStoreTests: XCTestCase {
    
    func testMockProviderSelected() async {
        let store = SandboxStore()
        store.selectedLLMProvider = .mock
        store.clearLogs()
        
        await store.testAIAgents()
        
        XCTAssertTrue(store.logs.contains { $0.text.contains("Using simulated metrics for the sandbox execution.") })
        XCTAssertNotNil(store.generatedWorkout)
    }
    
    func testRealProviderSelected() async {
        let store = SandboxStore()
        store.selectedLLMProvider = .gpt4o
        store.useSimulatedMetrics = false
        store.clearLogs()
        
        await store.testAIAgents()
        
        XCTAssertTrue(store.logs.contains { $0.text.contains("Collecting real HealthKit metrics for AI Orchestrator...") })
    }
}
