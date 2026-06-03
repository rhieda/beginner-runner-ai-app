import Foundation

protocol LLMNetworkClientProtocol: Sendable {
    func execute<T: Decodable>(request: URLRequest) async throws -> T
}

struct LLMNetworkClient: LLMNetworkClientProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func execute<T: Decodable>(request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LLMNetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw LLMNetworkError.decodingFailed(error)
            }
        case 401:
            throw LLMNetworkError.unauthorized
        case 429:
            throw LLMNetworkError.rateLimitExceeded
        default:
            let payload = String(data: data, encoding: .utf8)
            throw LLMNetworkError.serverError(statusCode: httpResponse.statusCode, payload: payload)
        }
    }
}
