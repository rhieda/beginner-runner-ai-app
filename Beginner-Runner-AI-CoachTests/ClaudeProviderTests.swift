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
    
    func testGenerateResponse_WithCustomModel() async throws {
        // Given
        let customModel = "claude-3-5-sonnet-20241022"
        let networkClient = LLMNetworkClient(session: session)
        provider = ClaudeLLMProvider(networkClient: networkClient, apiKey: "test_key", model: customModel)
        
        let jsonResponse = """
        {
            "content": [
                {
                    "text": "Claude custom response"
                }
            ]
        }
        """
        let data = jsonResponse.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.value(forHTTPHeaderField: "x-api-key"), "test_key")
            
            // Verify model in the JSON body
            if let bodyData = request.getBodyData() {
                do {
                    if let json = try JSONSerialization.jsonObject(with: bodyData) as? [String: Any],
                       let model = json["model"] as? String {
                        XCTAssertEqual(model, customModel)
                    } else {
                        XCTFail("Failed to parse model from request body")
                    }
                } catch {
                    XCTFail("Failed to decode JSON from request body: \(error)")
                }
            } else {
                XCTFail("No http body found in request")
            }
            
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        // When
        let result = try await provider.generateResponse(prompt: "Hi", systemInstruction: "Be precise")
        
        // Then
        XCTAssertEqual(result, "Claude custom response")
    }
}
