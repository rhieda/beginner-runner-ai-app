import Foundation

struct CoachAgentInput: Encodable {
    let loadReport: LoadReport
    let recoveryReport: RecoveryReport
    let userGoal: String
}

enum WorkoutIntensity: String, Codable, CaseIterable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
}

struct CustomWorkoutComposition: Codable {
    struct Step: Codable {
        let durationInMinutes: Int
        let intensityLevel: WorkoutIntensity?
    }
    
    struct Block: Codable {
        let work: Step
        let recovery: Step
    }
    
    let warmup: Step
    let blocks: [Block]
    let cooldown: Step
}

struct CoachAgent: AIAgentProtocol {
    typealias Input = CoachAgentInput
    typealias Output = CustomWorkoutComposition
    
    let name = "Head Coach Agent"
    let systemPrompt = AgentPrompts.coachAgentSystemPrompt
    let provider: LLMProviderProtocol
}
