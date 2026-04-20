import HealthKit

final actor HRVDataProvider: HealthKitDataRequestable {
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

import SwiftData
final actor HRVCachedProvider: HealthKitDataRequestable, HealthKitDataStorable {
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

    func store(input: HealthDataBaseLocalSample) throws {
        context.insert(input)
    }
}
