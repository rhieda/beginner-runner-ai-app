import Foundation

class GeminiLLMProvider: LLMProviderProtocol {
    private let networkClient: LLMNetworkClientProtocol
    private let apiKey: String
    private let model: String
    
    init(networkClient: LLMNetworkClientProtocol = LLMNetworkClient(), apiKey: String = LLMConfig.geminiKey, model: String = "gemini-2.5-flash-lite") {
        self.networkClient = networkClient
        self.apiKey = apiKey
        self.model = model
    }
    
    func generateResponse(prompt: String, systemInstruction: String) async throws -> String {
        guard !apiKey.isEmpty else {
            throw LLMNetworkError.unauthorized
        }
        
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw LLMNetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let geminiRequest = GeminiRequest(
            contents: [
                GeminiContent(role: "user", parts: [GeminiPart(text: prompt)])
            ],
            systemInstruction: GeminiContent(role: nil, parts: [GeminiPart(text: systemInstruction)]),
            generationConfig: GeminiGenerationConfig(temperature: 0.0, responseMimeType: "application/json")
        )
        
        request.httpBody = try JSONEncoder().encode(geminiRequest)
        
        let response: GeminiResponse = try await networkClient.execute(request: request)
        
        guard let content = response.candidates.first?.content.parts.first?.text else {
            throw LLMNetworkError.invalidResponse
        }
        
        return content
    }
}
