# Specification: HealthKit Communication & TRIMP/HRV Calculations

## 1. Overview
This specification details the implementation for extracting physiological data (HRV, RHR, Workouts) from Apple HealthKit and calculating two core metrics for the AI Coach:
- **TRIMP (Training Impulse):** A mathematical load score.
- **HRV Moving Averages:** A readiness trend based on historical Heart Rate Variability.

The implementation strictly follows the Clean Architecture guidelines defined in `AI_INSTRUCTIONS.md`, ensuring that mathematical logic resides in the Domain layer, while the Data layer focuses purely on data extraction and caching.

## 2. Domain Layer

### 2.1 Entities
- Enhance `HealthDataLocalSample` (or equivalent `HealthDataBaseLocalSample`) to securely represent time-series points (Date + Double value).

### 2.2 Interfaces
- Define `HealthKitTimeSeriesRequestable` in `Domain/Interfaces/HealthInterfaces.swift`.
  - Must return `[HealthDataLocalSample]` given a start and end date.

### 2.3 Services (Agents)
- **RecoveryAgentService**
  - Input: Array of daily HRV values.
  - Responsibility: Calculate 7-day and 30-day moving averages.
  - Output: Readiness trend score/status.
- **LoadAgentService**
  - Input: Workout duration, Average Heart Rate, Resting Heart Rate (RHR).
  - Responsibility: Apply the Banister TRIMP formula to calculate the stress of a workout.
  - Output: TRIMP score (Double).

## 4. Data Layer

### 3.1 Providers
All providers below must implement `HealthKitTimeSeriesRequestable`:
- **HRVDataProvider:** Uses `HKStatisticsCollectionQuery` (daily discrete average) to fetch HRV (SDNN) over the specified period.
- **RHRDataProvider:** Uses `HKStatisticsCollectionQuery` to fetch daily average Resting Heart Rate.
- **WorkoutDataProvider:** Uses `HKSampleQuery` to fetch `HKWorkout`s. Extracts total duration, and uses embedded `HKStatistics` to extract average and max heart rates.

### 3.2 Repository & Cache
- **HRVRepository:** Orchestrates the fetching process.
- **SwiftData Cache:** Checks `HRVCachedProvider` first. If data for a specific date range is missing, calls the respective Data Providers (HealthKit), returns the data to the Domain, and asynchronously persists the missing days in SwiftData to prevent future latency.

## 5. Testing Criteria (Given-When-Then)

### 4.1 RecoveryAgentService Tests
- **Given** an array of 30 mock HRV values,
- **When** the moving averages are calculated,
- **Then** the 7-day average and 30-day average should match the mathematically expected values with a precision of 0.01.

### 4.2 LoadAgentService Tests
- **Given** a 60-minute workout with an average HR of 150 bpm and an RHR of 60 bpm,
- **When** the TRIMP score is calculated,
- **Then** the output score must match the Banister TRIMP formula result.

### 4.3 Data Provider Integration
- **Given** HealthKit authorization is granted,
- **When** the `HRVDataProvider` requests 7 days of data,
- **Then** it should return an array of up to 7 items, correctly aggregated by day.

## 6. Security & Privacy
- Ensure all HealthKit data requests happen asynchronously.
- Fail gracefully if `authorizationFailed` or `datasourceUnavailable` occurs.
- Do not log physiological values to external tracking services.