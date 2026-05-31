# HealthKit Time-Series Patterns

## Daily Statistics Aggregation
Always group physiological data by day to align with AI Coaching logic (Daily summaries).

### Implementation Pattern
```swift
let interval = DateComponents(day: 1)
let query = HKStatisticsCollectionQuery(
    quantityType: quantityType,
    quantitySamplePredicate: predicate,
    options: .discreteAverage, // or .discreteMax for Max HR
    anchorDate: anchorDate,
    intervalComponents: interval
)

query.initialResultsHandler = { query, results, error in
    results?.enumerateStatistics(from: start, to: end) { statistics, _ in
        if let avg = statistics.averageQuantity() {
            let value = avg.doubleValue(for: unit)
            // Create Local Sample
        }
    }
}
```

## Workout Intensity Extraction
When fetching `HKWorkout`, always extract embedded statistics for higher precision.

```swift
let avgHeartRate = workout.statistics(for: HKQuantityType(.heartRate))?
    .averageQuantity()?
    .doubleValue(for: .count().unitDivided(by: .minute()))
```

## Repository Caching (Intelligence Cache)
Orchestrate between SwiftData and HealthKit to minimize latency.

1. **Check Cache**: Query SwiftData for the requested range.
2. **Identify Gaps**: If dates are missing, fetch from HealthKit.
3. **Merge & Store**: Combine results and persist new data to SwiftData.
