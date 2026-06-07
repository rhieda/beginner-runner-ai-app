import Foundation

enum LLMProviderType: String, CaseIterable, Identifiable {
    case mock = "Sandbox (Mock)"
    
    // Gemini
    case gemini25FlashLite = "Gemini 2.5 Flash Lite"
    case gemini25Flash = "Gemini 2.5 Flash"
    case gemini35Flash = "Gemini 3.5 Flash"
    case gemini31FlashLite = "Gemini 3.1 Flash Lite"
    case gemini15Flash = "Gemini 1.5 Flash"
    case gemini15Pro = "Gemini 1.5 Pro"
    
    // OpenAI
    case gpt4o = "GPT-4o"
    case gpt4oMini = "GPT-4o Mini"
    case gpt4Turbo = "GPT-4 Turbo"
    
    // Claude
    case claude35Sonnet = "Claude 3.5 Sonnet"
    case claude35Haiku = "Claude 3.5 Haiku"
    case claude3Opus = "Claude 3 Opus"
    
    var id: String { self.rawValue }
}

enum LLMProviderFactory {
    static func create(type: LLMProviderType) -> LLMProviderProtocol {
        switch type {
        case .mock:
            return SandboxLLMProvider()
        case .gemini25FlashLite:
            return GeminiLLMProvider(model: "gemini-2.5-flash-lite")
        case .gemini25Flash:
            return GeminiLLMProvider(model: "gemini-2.5-flash")
        case .gemini35Flash:
            return GeminiLLMProvider(model: "gemini-3.5-flash")
        case .gemini31FlashLite:
            return GeminiLLMProvider(model: "gemini-3.1-flash-lite")
        case .gemini15Flash:
            return GeminiLLMProvider(model: "gemini-1.5-flash")
        case .gemini15Pro:
            return GeminiLLMProvider(model: "gemini-1.5-pro")
        case .gpt4o:
            return OpenAILLMProvider(model: "gpt-4o")
        case .gpt4oMini:
            return OpenAILLMProvider(model: "gpt-4o-mini")
        case .gpt4Turbo:
            return OpenAILLMProvider(model: "gpt-4-turbo")
        case .claude35Sonnet:
            return ClaudeLLMProvider(model: "claude-3-5-sonnet-20241022")
        case .claude35Haiku:
            return ClaudeLLMProvider(model: "claude-3-5-haiku-20241022")
        case .claude3Opus:
            return ClaudeLLMProvider(model: "claude-3-opus-20240229")
        }
    }
}
