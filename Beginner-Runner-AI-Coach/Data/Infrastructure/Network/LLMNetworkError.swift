import Foundation

enum LLMNetworkError: Error {
    case invalidURL
    case invalidResponse
    case unauthorized
    case rateLimitExceeded
    case serverError(statusCode: Int, payload: String?)
    case decodingFailed(Error)
    case unknown(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL: return "The URL provided is invalid."
        case .invalidResponse: return "The server returned an invalid response."
        case .unauthorized: return "Authentication failed. Check your API key."
        case .rateLimitExceeded: return "Rate limit exceeded. Please try again later."
        case .serverError(let code, let payload): return "Server error (\(code)): \(payload ?? "No details")"
        case .decodingFailed: return "Failed to decode the response from the server."
        case .unknown(let error): return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}
