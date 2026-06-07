import XCTest
@testable import Beginner_Runner_AI_Coach

final class GeminiProviderTests: XCTestCase {
    var session: URLSession!
    var provider: GeminiLLMProvider!
    
    override func setUp() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        let networkClient = LLMNetworkClient(session: session)
        provider = GeminiLLMProvider(networkClient: networkClient, apiKey: "test_key")
    }
    
    func testGenerateResponse_Success() async throws {
        // Given
        let jsonResponse = """
        {
            "candidates": [
                {
                    "content": {
                        "parts": [
                            {
                                "text": "Gemini response"
                            }
                        ]
                    }
                }
            ]
        }
        """
        let data = jsonResponse.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertTrue(request.url?.absoluteString.contains("key=test_key") ?? false)
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        // When
        let result = try await provider.generateResponse(prompt: "Hi", systemInstruction: "Be helpful")
        
        // Then
        XCTAssertEqual(result, "Gemini response")
    }
    
    func testGenerateResponse_WithCustomModel() async throws {
        // Given
        let customModel = "gemini-3.5-flash"
        let networkClient = LLMNetworkClient(session: session)
        provider = GeminiLLMProvider(networkClient: networkClient, apiKey: "test_key", model: customModel)
        
        let jsonResponse = """
        {
            "candidates": [
                {
                    "content": {
                        "parts": [
                            {
                                "text": "Gemini custom response"
                            }
                        ]
                    }
                }
            ]
        }
        """
        let data = jsonResponse.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertTrue(request.url?.absoluteString.contains("key=test_key") ?? false)
            XCTAssertTrue(request.url?.absoluteString.contains("models/\(customModel):generateContent") ?? false)
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        // When
        let result = try await provider.generateResponse(prompt: "Hi", systemInstruction: "Be helpful")
        
        // Then
        XCTAssertEqual(result, "Gemini custom response")
    }
}
