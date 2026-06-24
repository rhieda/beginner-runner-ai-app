import HealthKit

protocol HRVRepositoryRepresentable: Actor {
    func requestTimeSeries(
        from beginDate: Date,
        to endDate: Date
    ) async throws -> [HealthDataBaseLocalSample]
}

final actor HRVRepository<Provider>: HRVRepositoryRepresentable 
where Provider: HealthKitTimeSeriesRequestable {
    
    private let provider: Provider

    init(provider: Provider) {
        self.provider = provider
    }

    func requestTimeSeries(
        from beginDate: Date,
        to endDate: Date
    ) async throws -> [HealthDataBaseLocalSample] {
        // Fetch from HealthKit
        return try await provider.requestTimeSeries(from: beginDate, to: endDate)
    }
}
