import Foundation
import HealthKit

actor StepsDatasource: HealthDataRequester {
    let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }

    func requestAuthorization() throws -> Self {
        let allowedTypes: Set<HKObjectType> = [
            .quantityType(forIdentifier: .stepCount)!
        ]
        
        let writeTypes: Set<HKSampleType> = [
            .quantityType(forIdentifier: .stepCount)!
        ]

        healthStore.requestAuthorization(
            toShare: writeTypes,
            read: allowedTypes
        ) { didSucceed, error in
            if let error {
                dump("*** error happened: \(error)")
            }
            dump("*** did Succeed? \(didSucceed)")
        }
        return self
    }

    func requestData(
        from beginDate: Date,
        to endDate: Date
    ) async throws -> Double {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw HealthDataRequesterError.invalidParameter
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: beginDate,
            end: endDate
        )

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Double, Error>) in
            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate
            ) { _, statistics, error in
                if let error {
                    dump(error)
                    continuation.resume(throwing: HealthDataRequesterError.noDataAvailable)
                    return
                }
                guard let statistics = statistics,
                      let sum = statistics.sumQuantity() else {
                    continuation.resume(throwing: HealthDataRequesterError.noDataAvailable)
                    return
                }

                let steps = sum.doubleValue(for: HKUnit.count())
                continuation.resume(with: .success(steps))
            }
            healthStore.execute(query)
        }
    }
}
