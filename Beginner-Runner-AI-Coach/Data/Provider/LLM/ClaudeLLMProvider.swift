import Foundation

class ClaudeLLMProvider: LLMProviderProtocol {
    private let networkClient: LLMNetworkClientProtocol
    private let apiKey: String
    
    init(networkClient: LLMNetworkClientProtocol = LLMNetworkClient(), apiKey: String = LLMConfig.claudeKey) {
        self.networkClient = networkClient
        self.apiKey = apiKey
    }
    
    func generateResponse(prompt: String, systemInstruction: String) async throws -> String {
        guard !apiKey.isEmpty else {
            throw LLMNetworkError.unauthorized
        }
        
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let claudeRequest = ClaudeRequest(
            system: systemInstruction,
            messages: [ClaudeMessage(role: "user", content: prompt)]
        )
        
        request.httpBody = try JSONEncoder().encode(claudeRequest)
        
        let response: ClaudeResponse = try await networkClient.execute(request: request)
        
        guard let content = response.content.first?.text else {
            throw LLMNetworkError.invalidResponse
        }
        
        return content
    }
}
