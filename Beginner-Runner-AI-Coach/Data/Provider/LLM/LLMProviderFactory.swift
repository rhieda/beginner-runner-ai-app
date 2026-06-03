import Foundation

enum LLMProviderType: String, CaseIterable, Identifiable {
    case mock = "Sandbox (Mock)"
    case openai = "OpenAI (GPT-4)"
    case gemini = "Google (Gemini 1.5)"
    case claude = "Anthropic (Claude 3)"
    
    var id: String { self.rawValue }
}

enum LLMProviderFactory {
    static func create(type: LLMProviderType) -> LLMProviderProtocol {
        switch type {
        case .mock:
            return SandboxLLMProvider()
        case .openai:
            return OpenAILLMProvider()
        case .gemini:
            return GeminiLLMProvider()
        case .claude:
            return ClaudeLLMProvider()
        }
    }
}
