import Foundation

struct RecoveryAgentInput: Encodable {
    let sevenDayHRVAvg: Double
    let thirtyDayHRVAvg: Double
}

struct RecoveryReport: Codable {
    let status: String
    let physiologicalEvaluation: String
}

struct RecoveryAgent: AIAgentProtocol {
    typealias Input = RecoveryAgentInput
    typealias Output = RecoveryReport
    
    let name = "Recovery Analysis Agent"
    let systemPrompt = AgentPrompts.recoveryAgentSystemPrompt
    let provider: LLMProviderProtocol
}
