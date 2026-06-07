import XCTest
@testable import Beginner_Runner_AI_Coach

final class OpenAIProviderTests: XCTestCase {
    var session: URLSession!
    var provider: OpenAILLMProvider!
    
    override func setUp() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        let networkClient = LLMNetworkClient(session: session)
        provider = OpenAILLMProvider(networkClient: networkClient, apiKey: "test_key")
    }
    
    func testGenerateResponse_Success() async throws {
        // Given
        let jsonResponse = """
        {
            "choices": [
                {
                    "message": {
                        "content": "Hello user"
                    }
                }
            ]
        }
        """
        let data = jsonResponse.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString, "https://api.openai.com/v1/chat/completions")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer test_key")
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        // When
        let result = try await provider.generateResponse(prompt: "Hi", systemInstruction: "Be kind")
        
        // Then
        XCTAssertEqual(result, "Hello user")
    }
    
    func testGenerateResponse_Unauthorized() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        
        // When / Then
        do {
            _ = try await provider.generateResponse(prompt: "Hi", systemInstruction: "Be kind")
            XCTFail("Should throw unauthorized error")
        } catch let error as LLMNetworkError {
            if case .unauthorized = error {
                // Success
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testGenerateResponse_WithCustomModel() async throws {
        // Given
        let customModel = "gpt-4o"
        let networkClient = LLMNetworkClient(session: session)
        provider = OpenAILLMProvider(networkClient: networkClient, apiKey: "test_key", model: customModel)
        
        let jsonResponse = """
        {
            "choices": [
                {
                    "message": {
                        "content": "Hello custom user"
                    }
                }
            ]
        }
        """
        let data = jsonResponse.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString, "https://api.openai.com/v1/chat/completions")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer test_key")
            
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
        let result = try await provider.generateResponse(prompt: "Hi", systemInstruction: "Be kind")
        
        // Then
        XCTAssertEqual(result, "Hello custom user")
    }
}
