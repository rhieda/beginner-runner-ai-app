import Foundation

class OpenAILLMProvider: LLMProviderProtocol {
    private let networkClient: LLMNetworkClientProtocol
    private let apiKey: String
    private let model: String
    
    init(networkClient: LLMNetworkClientProtocol = LLMNetworkClient(), apiKey: String = LLMConfig.openAIKey, model: String = "gpt-4-turbo-preview") {
        self.networkClient = networkClient
        self.apiKey = apiKey
        self.model = model
    }
    
    func generateResponse(prompt: String, systemInstruction: String) async throws -> String {
        guard !apiKey.isEmpty else {
            throw LLMNetworkError.unauthorized
        }
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let openAIRequest = OpenAIRequest(
            model: model,
            messages: [
                OpenAIMessage(role: "system", content: systemInstruction),
                OpenAIMessage(role: "user", content: prompt)
            ]
        )
        
        request.httpBody = try JSONEncoder().encode(openAIRequest)
        
        let response: OpenAIResponse = try await networkClient.execute(request: request)
        
        guard let content = response.choices.first?.message.content else {
            throw LLMNetworkError.invalidResponse
        }
        
        return content
    }
}
