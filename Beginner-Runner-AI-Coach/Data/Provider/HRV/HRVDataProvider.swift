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
                        dump(sample)
                        samples.append(sample)
                    }
                }
                continuation.resume(returning: samples)
            }
            HKHealthStore().execute(query)
        }
    }
}
