import HealthKit

protocol HRVRepositoryRepresentable: Actor {
    func requestTimeSeries(
        from beginDate: Date,
        to endDate: Date
    ) async throws -> [HealthDataBaseLocalSample]
}

final actor HRVRepository: HRVRepositoryRepresentable {
    private let provider: any HealthKitTimeSeriesRequestable
    private let cachedProvider: (any HealthKitTimeSeriesRequestable & HealthKitDataStorable)?

    init(
        provider: any HealthKitTimeSeriesRequestable,
        cachedProvider: (any HealthKitTimeSeriesRequestable & HealthKitDataStorable)? = nil
    ) {
        self.provider = provider
        self.cachedProvider = cachedProvider
    }

    func requestTimeSeries(
        from beginDate: Date,
        to endDate: Date
    ) async throws -> [HealthDataBaseLocalSample] {
        // 1. Try to fetch from cache first
        if let cachedProvider = cachedProvider {
            do {
                let cachedSamples = try await cachedProvider.requestTimeSeries(from: beginDate, to: endDate)
                // For this implementation, we assume if we have data in cache, we return it.
                // A more robust implementation would check for gaps.
                if !cachedSamples.isEmpty {
                    return cachedSamples
                }
            } catch {
                // If cache fails, proceed to live provider
            }
        }

        // 2. Fetch from HealthKit
        let liveSamples = try await provider.requestTimeSeries(from: beginDate, to: endDate)

        // 3. Save to cache asynchronously
        if let cachedProvider = cachedProvider {
            for sample in liveSamples {
                try? cachedProvider.store(input: sample)
            }
        }

        return liveSamples
    }
}
