import Foundation

struct ClaudeRequest: Encodable {
    let model: String
    let system: String?
    let messages: [ClaudeMessage]
    let maxTokens: Int
    let temperature: Double?
    
    enum CodingKeys: String, CodingKey {
        case model, system, messages, temperature
        case maxTokens = "max_tokens"
    }
    
    init(model: String = "claude-3-sonnet-20240229", system: String? = nil, messages: [ClaudeMessage], maxTokens: Int = 1024, temperature: Double? = 0.0) {
        self.model = model
        self.system = system
        self.messages = messages
        self.maxTokens = maxTokens
        self.temperature = temperature
    }
}

struct ClaudeMessage: Encodable {
    let role: String
    let content: String
}

struct ClaudeResponse: Decodable {
    let content: [ClaudeContentResponse]
}

struct ClaudeContentResponse: Decodable {
    let text: String
}
