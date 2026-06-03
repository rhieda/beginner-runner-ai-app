import XCTest
@testable import Beginner_Runner_AI_Coach

final class ClaudeProviderTests: XCTestCase {
    var session: URLSession!
    var provider: ClaudeLLMProvider!
    
    override func setUp() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        let networkClient = LLMNetworkClient(session: session)
        provider = ClaudeLLMProvider(networkClient: networkClient, apiKey: "test_key")
    }
    
    func testGenerateResponse_Success() async throws {
        // Given
        let jsonResponse = """
        {
            "content": [
                {
                    "text": "Claude response"
                }
            ]
        }
        """
        let data = jsonResponse.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.value(forHTTPHeaderField: "x-api-key"), "test_key")
            XCTAssertEqual(request.value(forHTTPHeaderField: "anthropic-version"), "2023-06-01")
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        // When
        let result = try await provider.generateResponse(prompt: "Hi", systemInstruction: "Be precise")
        
        // Then
        XCTAssertEqual(result, "Claude response")
    }
}
