import Foundation

/// Protocol for an LLM provider (e.g., OpenAI, Local LLM, etc.)
protocol LLMProviderProtocol: Sendable {
    func generateResponse(prompt: String, systemInstruction: String) async throws -> String
}

/// Generic protocol for an AI Agent
protocol AIAgentProtocol: Sendable {
    associatedtype Input: Encodable
    associatedtype Output: Decodable
    
    var name: String { get }
    var systemPrompt: String { get }
    var provider: LLMProviderProtocol { get }
    
    func execute(input: Input) async throws -> Output
}

extension AIAgentProtocol {
    /// Default implementation for executing an agent by encoding input and decoding output JSON.
    func execute(input: Input) async throws -> Output {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let inputData = try encoder.encode(input)
        guard let inputString = String(data: inputData, encoding: .utf8) else {
            throw AIAgentError.encodingFailed
        }
        
        let response = try await provider.generateResponse(prompt: inputString, systemInstruction: systemPrompt)
        
        guard let responseData = response.data(using: .utf8) else {
            throw AIAgentError.decodingFailed
        }
        
        return try JSONDecoder().decode(Output.self, from: responseData)
    }
}

enum AIAgentError: Error {
    case encodingFailed
    case decodingFailed
    case providerError(Error)
    case invalidOutput(String)
}
