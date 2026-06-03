import Foundation

struct GeminiRequest: Encodable {
    let contents: [GeminiContent]
    let systemInstruction: GeminiContent?
    let generationConfig: GeminiGenerationConfig?
}

struct GeminiContent: Encodable {
    let role: String?
    let parts: [GeminiPart]
}

struct GeminiPart: Encodable {
    let text: String
}

struct GeminiGenerationConfig: Encodable {
    let temperature: Double?
    let responseMimeType: String?
}

struct GeminiResponse: Decodable {
    let candidates: [GeminiCandidate]
}

struct GeminiCandidate: Decodable {
    let content: GeminiContentResponse
}

struct GeminiContentResponse: Decodable {
    let parts: [GeminiPartResponse]
}

struct GeminiPartResponse: Decodable {
    let text: String
}
