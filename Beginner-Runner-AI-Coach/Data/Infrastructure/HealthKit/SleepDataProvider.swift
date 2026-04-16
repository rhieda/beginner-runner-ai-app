import HealthKit

final actor SleepDataProvider: HealthKitDataRequester {
    let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }

    func requestData(
        from beginDate: Date,
        to endDate: Date
    ) async throws -> Double {
        guard let categoryType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw HealthDataRequesterError.invalidParameter
        }
        let calendar = Calendar.current

        let predicate = HKQuery.predicateForSamples(
            withStart: beginDate,
            end: endDate
        )

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Double, Error>) in
            let query = HKSampleQuery(
                sampleType: categoryType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, statistics, error in
                if let error {
                    dump(error)
                    continuation.resume(throwing: HealthDataRequesterError.noDataAvailable)
                    return
                }

                guard let statistics,
                      let sleepSample = statistics as? [HKCategorySample] else {
                    continuation.resume(throwing: HealthDataRequesterError.noDataAvailable)
                    return
                }

                let sleepTime: Double = sleepSample
                    .filter { $0.value != HKCategoryValueSleepAnalysis.awake.rawValue } // remove awake time
                    .reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }

                let totalInHours = sleepTime / 3600

                continuation.resume(with: .success(sleepTime))
            }
        }
        
    }
    
    
}
