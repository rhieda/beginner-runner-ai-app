import HealthKit

final actor HRVDataProvider: HealthKitDataRequestable, HealthKitTimeSeriesRequestable {
    /// Requests the most recent Heart Rate Variability (HRV) sample.
    /// Uses the SDNN (Standard Deviation of NN intervals) metric provided by Apple HealthKit.
    func requestData(
        from beginDate: Date,
        to endDate: Date
    ) async throws -> Double {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            throw HealthDataRequesterError.invalidParameter
        }

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: false
        )

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Double, Error>) in
            let query = HKSampleQuery(
                sampleType: quantityType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(throwing: HealthDataRequesterError.noDataAvailable)
                    return
                }

                let hrvValue = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))

                continuation.resume(with: .success(hrvValue))
            }
            HKHealthStore().execute(query)
        }
    }

    /// Requests a time-series of daily HRV averages for trend analysis.
    ///
    /// Business Rule: We aggregate HRV values by day using `HKStatisticsCollectionQuery`
    /// to smooth out intra-day fluctuations and provide a consistent data point for
    /// moving average (7-day/30-day) calculations in the Domain layer.
    func requestTimeSeries(
        from beginDate: Date,
        to endDate: Date
    ) async throws -> [HealthDataBaseLocalSample] {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            throw HealthDataRequesterError.invalidParameter
        }

        // 1-day interval is mandatory to feed the trend-analysis logic.
        let interval = DateComponents(day: 1)
        let predicate = HKQuery.predicateForSamples(withStart: beginDate, end: endDate, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage,
                anchorDate: beginDate,
                intervalComponents: interval
            )

            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let results = results else {
                    continuation.resume(throwing: HealthDataRequesterError.noDataAvailable)
                    return
                }

                var samples: [HealthDataBaseLocalSample] = []
                results.enumerateStatistics(from: beginDate, to: endDate) { statistics, _ in
                    if let average = statistics.averageQuantity() {
                        let value = average.doubleValue(for: HKUnit.secondUnit(with: .milli))
                        let sample = HealthDataBaseLocalSample(
                            value: value,
                            beginDate: statistics.startDate,
                            endDate: statistics.endDate,
                            unitString: "ms"
                        )
                        samples.append(sample)
                    }
                }
                continuation.resume(returning: samples)
            }
            HKHealthStore().execute(query)
        }
    }
}

import SwiftData

/// Implementation of the "Intelligence Cache" for Physiological Data.
///
/// Business Rule: To eliminate HealthKit latency during historical calculations,
/// we persist aggregated daily summaries in SwiftData. This allows the AI Agents
/// to instantly evaluate trends upon app launch.
final actor HRVCachedProvider: HealthKitDataRequestable, HealthKitTimeSeriesRequestable, HealthKitDataStorable {
    private let context: ModelContext

    init() throws {
        let modelContainer = try ModelContainer(
            for: HealthDataBaseLocalSample.self,
            configurations: ModelConfiguration()
        )

        self.context = ModelContext(modelContainer)
    }
    
    func requestData(
        from beginDate: Date,
        to endDate: Date
    ) async throws -> Double {
        let predicate = #Predicate<HealthDataBaseLocalSample> { $0.beginDate == beginDate && $0.endDate == endDate }
        let sortDescriptor = SortDescriptor<HealthDataBaseLocalSample>(\.beginDate, order: .forward)
        var fetchDescriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [sortDescriptor]
        )

        fetchDescriptor.fetchLimit = 1

        do {
            let fetchedResponse = try context.fetch(fetchDescriptor)
            guard let firstResponse = fetchedResponse.first else {
                throw HealthDataRequesterError.noDataAvailable
            }

            return firstResponse.value
        } catch {
            throw HealthKitManagerError.datasourceUnavailable
        }
    }

    func requestTimeSeries(
        from beginDate: Date,
        to endDate: Date
    ) async throws -> [HealthDataBaseLocalSample] {
        let predicate = #Predicate<HealthDataBaseLocalSample> { 
            $0.beginDate >= beginDate && $0.beginDate <= endDate 
        }
        let sortDescriptor = SortDescriptor<HealthDataBaseLocalSample>(\.beginDate, order: .forward)
        let fetchDescriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [sortDescriptor]
        )

        do {
            return try context.fetch(fetchDescriptor)
        } catch {
            throw HealthKitManagerError.datasourceUnavailable
        }
    }

    func store(input: HealthDataBaseLocalSample) throws {
        context.insert(input)
    }
}
