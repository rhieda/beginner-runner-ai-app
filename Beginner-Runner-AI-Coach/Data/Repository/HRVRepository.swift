import HealthKit

protocol HRVRepositoryRepresentable: Actor {
    func requestTimeSeries(
        from beginDate: Date,
        to endDate: Date
    ) async throws -> [HealthDataBaseLocalSample]
}

final actor HRVRepository<Provider, Cache>: HRVRepositoryRepresentable 
where Provider: HealthKitTimeSeriesRequestable, 
      Cache: HealthKitTimeSeriesRequestable & HealthKitDataStorable,
      Cache.T == HealthDataBaseLocalSample {
    
    private let provider: Provider
    private let cachedProvider: Cache?

    init(
        provider: Provider,
        cachedProvider: Cache? = nil
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
                if !cachedSamples.isEmpty {
                    return cachedSamples
                }
            } catch {
                // If cache fails, proceed to live provider
            }
        }

        // 2. Fetch from HealthKit
        let liveSamples = try await provider.requestTimeSeries(from: beginDate, to: endDate)

        // 3. Save to cache
        if let cachedProvider = cachedProvider {
            for sample in liveSamples {
                try? await cachedProvider.store(input: sample)
            }
        }

        return liveSamples
    }
}
