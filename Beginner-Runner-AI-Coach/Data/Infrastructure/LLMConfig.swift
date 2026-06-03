import Foundation

/// Utility to load API keys from Secrets.plist
enum LLMConfig {
    static var openAIKey: String {
        return value(for: "OPENAI_API_KEY")
    }
    
    static var geminiKey: String {
        return value(for: "GEMINI_API_KEY")
    }
    
    static var claudeKey: String {
        return value(for: "CLAUDE_API_KEY")
    }
    
    private static func value(for key: String) -> String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: String],
              let value = dict[key],
              !value.isEmpty,
              !value.contains("YOUR_") else {
            // Log or handle missing key if necessary
            return ""
        }
        return value
    }
}
