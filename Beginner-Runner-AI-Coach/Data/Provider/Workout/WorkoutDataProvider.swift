import HealthKit

final actor WorkoutDataProvider: WorkoutDataRequestable {
    /// Requests completed workouts and extracts their internal physiological metrics.
    ///
    /// Business Rule: We fetch the duration and heart rate statistics (Average/Max)
    /// recorded strictly during the exercise to quantify the "Internal Load" (TRIMP).
    func requestWorkouts(
        from beginDate: Date,
        to endDate: Date
    ) async throws -> [WorkoutSample] {
        let predicate = HKQuery.predicateForSamples(withStart: beginDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[WorkoutSample], Error>) in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let workouts = samples as? [HKWorkout] else {
                    continuation.resume(returning: [])
                    return
                }

                let workoutSamples = workouts.map { workout -> WorkoutSample in
                    // Extraction Rule: Average and Maximum Heart Rates are pulled from the workout's
                    // statistics to ensure accuracy in the TRIMP calculation.
                    let avgHeartRate = workout.statistics(for: HKQuantityType(.heartRate))?.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    let maxHeartRate = workout.statistics(for: HKQuantityType(.heartRate))?.maximumQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))

                    return WorkoutSample(
                        id: workout.uuid,
                        duration: workout.duration,
                        averageHeartRate: avgHeartRate,
                        maxHeartRate: maxHeartRate,
                        startDate: workout.startDate,
                        endDate: workout.endDate,
                        activityType: workout.workoutActivityType
                    )
                }

                continuation.resume(returning: workoutSamples)
            }
            HKHealthStore().execute(query)
        }
    }
}
