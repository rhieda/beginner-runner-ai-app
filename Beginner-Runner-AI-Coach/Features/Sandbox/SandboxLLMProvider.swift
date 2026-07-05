import Foundation

/// A mock LLM provider specifically built for testing the AI orchestration within the Sandbox UI.
class SandboxLLMProvider: LLMProviderProtocol {
    static var simulateError = false
    
    func generateResponse(prompt: String, systemInstruction: String) async throws -> String {
        if SandboxLLMProvider.simulateError {
            throw AIAgentError.invalidOutput("Simulated Sandbox error for fallback testing")
        }
        
        // Simulate network delay (skip during XCTest to keep test runs fast)
        if NSClassFromString("XCTestCase") == nil {
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }
        
        if systemInstruction.contains("Load Analysis Agent") {
            return """
            {
              "status": "adapting",
              "physiologicalEvaluation": "The user is adapting perfectly to the current load. No signs of overreaching."
            }
            """
        } else if systemInstruction.contains("Recovery Analysis Agent") {
            return """
            {
              "status": "recovered",
              "physiologicalEvaluation": "Biological readiness is high based on the 7-day vs 30-day HRV baseline."
            }
            """
        } else if systemInstruction.contains("Head Coach Agent") {
            return """
            {
              "warmup": { "durationInMinutes": 10, "intensityLevel": "Low" },
              "blocks": [
                {
                  "work": { "durationInMinutes": 25, "intensityLevel": "Moderate" },
                  "recovery": { "durationInMinutes": 5, "intensityLevel": "Low" }
                }
              ],
              "cooldown": { "durationInMinutes": 10, "intensityLevel": "Low" }
            }
            """
        }
        
        throw AIAgentError.invalidOutput("Unrecognized agent prompt in Sandbox")
    }
}
