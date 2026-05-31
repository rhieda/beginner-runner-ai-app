import HealthKit

final actor RHRDataProvider: HealthKitDataRequestable, HealthKitTimeSeriesRequestable {
    /// Requests the most recent Resting Heart Rate (RHR) sample.
    ///
    /// Business Rule: RHR is used as the 'baseline effort' (0% Intensity)
    /// in the Karvonen formula to calculate the training load (TRIMP).
    func requestData(
        from beginDate: Date,
        to endDate: Date
    ) async throws -> Double {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
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
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(throwing: HealthDataRequesterError.noDataAvailable)
                    return
                }

                let value = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))

                continuation.resume(with: .success(value))
            }
            HKHealthStore().execute(query)
        }
    }

    /// Requests a time-series of daily Resting Heart Rate averages.
    ///
    /// Business Rule: Monitoring RHR trends helps the AI Coach identify
    /// potential overtraining or illness if the baseline HR shows a consistent increase.
    func requestTimeSeries(
        from beginDate: Date,
        to endDate: Date
    ) async throws -> [HealthDataBaseLocalSample] {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            throw HealthDataRequesterError.invalidParameter
        }

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
                        let value = average.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                        let sample = HealthDataBaseLocalSample(
                            value: value,
                            beginDate: statistics.startDate,
                            endDate: statistics.endDate,
                            unitString: "bpm"
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
