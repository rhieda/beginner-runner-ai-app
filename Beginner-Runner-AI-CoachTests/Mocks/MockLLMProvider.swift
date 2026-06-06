import Foundation
@testable import Beginner_Runner_AI_Coach

class MockLLMProvider: LLMProviderProtocol {
    var responses: [String: String] = [:]
    
    func generateResponse(prompt: String, systemInstruction: String) async throws -> String {
        // Simple logic to return a response based on the systemInstruction (acting as the agent type)
        if systemInstruction.contains("Load Analysis Agent") {
            return """
            {
              "status": "adapting",
              "physiologicalEvaluation": "The user is adapting well to the current load."
            }
            """
        } else if systemInstruction.contains("Recovery Analysis Agent") {
            return """
            {
              "status": "recovered",
              "physiologicalEvaluation": "Biological readiness is high."
            }
            """
        } else if systemInstruction.contains("Head Coach Agent") {
            return """
            {
              "warmup": { "durationInMinutes": 10 },
              "blocks": [
                {
                  "work": { "durationInMinutes": 20, "intensityLevel": "Moderate" },
                  "recovery": { "durationInMinutes": 5, "intensityLevel": "Low" }
                }
              ],
              "cooldown": { "durationInMinutes": 10 }
            }
            """
        }
        throw AIAgentError.invalidOutput("No mock response for this agent.")
    }
}
