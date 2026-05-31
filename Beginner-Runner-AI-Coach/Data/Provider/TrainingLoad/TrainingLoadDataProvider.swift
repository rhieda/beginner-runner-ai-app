import HealthKit

final actor TrainingLoadDataProvider: HealthKitDataRequestable {
    private(set) var effort: Double = 0.0

    init(effort: Double) {
        self.effort = effort
    }

    func requestData(
        from beginDate: Date,
        to endDate: Date
    ) async throws -> Double {
        guard let loadType = HKQuantityType.quantityType(forIdentifier: .workoutEffortScore) else {
            throw HealthDataRequesterError.invalidParameter
        }

        // Predicate for the last 7 days to see current "Carga"
        let predicate = HKQuery.predicateForSamples(
            withStart: beginDate,
            end: endDate,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Double, Error>) in

            let query = HKStatisticsQuery(
                quantityType: loadType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, error in
                if let error {
                    dump(error)
                    continuation.resume(throwing: HealthDataRequesterError.noDataAvailable)
                    return
                }

                guard let average = result?.averageQuantity() else {
                    print("No training load data yet.")
                    continuation.resume(throwing: HealthDataRequesterError.noDataAvailable)
                    return
                }

                // Training load is a unitless score (often 1-10 scale in UI, but stored as count)
                let loadValue = average.doubleValue(for: .count())
                
                continuation.resume(with: .success(loadValue))
            }
            HKHealthStore().execute(query)
        }
    }

}
