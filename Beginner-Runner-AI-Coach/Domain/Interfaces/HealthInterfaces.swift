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

enum HealthKitDataTypeIdentifier: CaseIterable {
    case steps
    case hrv
    case sleep
    case trainingLoad
    
    var readType: HKObjectType {
        fatalError("Not Implemented Yet")
    }

    var writingType: HKSampleType {
        fatalError("Not Implemented Yet")
    }
}

protocol HealthKitManagerRepresentation: Actor {
    func isDatasourceAvailable() -> Bool
    func requestAuthorization() throws
}

protocol HealthKitManagerAuthorizationRequestable: Actor {
    func requestAuthorization() throws -> Self
}

protocol HealthKitDataRequestable: Actor {
    func requestData(
        from beginDate: Date,
        to endDate: Date
    ) async throws -> Double
}

protocol HealthKitTimeSeriesRequestable: Actor {
    func requestTimeSeries(
        from beginDate: Date,
        to endDate: Date
    ) async throws -> [HealthDataBaseLocalSample]
}

struct WorkoutSample: Sendable {
    let id: UUID
    let duration: TimeInterval
    let averageHeartRate: Double?
    let maxHeartRate: Double?
    let startDate: Date
    let endDate: Date
    let activityType: HKWorkoutActivityType
}

protocol WorkoutDataRequestable: Actor {
    func requestWorkouts(
        from beginDate: Date,
        to endDate: Date
    ) async throws -> [WorkoutSample]
}

