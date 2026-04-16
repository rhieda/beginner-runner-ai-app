import HealthKit

final actor HRVDataProvider: HealthKitDataRequester {
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
        }
    }
    
    
}
