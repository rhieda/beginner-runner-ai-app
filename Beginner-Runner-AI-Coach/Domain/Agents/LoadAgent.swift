import Foundation

struct LoadAgentInput: Encodable {
    struct WorkoutEntry: Encodable {
        let date: String
        let duration: Int
        let intensity: String
    }
    
    let trimpScore: Double
    let workoutHistory: [WorkoutEntry]
}

struct LoadReport: Codable {
    let status: String
    let physiologicalEvaluation: String
}

struct LoadAgent: AIAgentProtocol {
    typealias Input = LoadAgentInput
    typealias Output = LoadReport
    
    let name = "Load Analysis Agent"
    let systemPrompt = AgentPrompts.loadAgentSystemPrompt
    let provider: LLMProviderProtocol
}
