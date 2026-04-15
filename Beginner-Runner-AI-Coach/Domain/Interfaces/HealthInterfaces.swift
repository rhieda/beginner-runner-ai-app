import Foundation
import HealthKit

enum HealthKitManagerError: LocalizedError {
    case datasourceUnavailable
    case authorizationFailed
}

enum HealthDataRequesterError: LocalizedError {
    case noDataAvailable
    case invalidParameter
}

protocol HealthKitManagerRepresentation: Actor {
    func isDatasourceAvailable() -> Bool
    func requestAuthorization() throws
}

protocol HealthDataRequester: Actor {
    func requestData(
        from beginDate: Date,
        to endDate: Date
    ) async throws -> Double
}
