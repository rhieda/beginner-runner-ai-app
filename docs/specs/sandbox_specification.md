# Specification: Provider Sandbox (Developer Testing Tool)

## 1. Overview
The Provider Sandbox is a dedicated feature designed for developers to manually verify the integration between the app's physiological agents and Apple HealthKit. It provides a controlled environment to trigger data fetching and observe calculation results directly in the UI.

## 2. Features

### 2.1 HealthKit Authorization
- **Functionality**: Explicitly requests read permissions for all physiological metrics required by the app.
- **Metrics**: HRV (SDNN), Resting Heart Rate, Heart Rate, and Workouts.

### 2.2 Data Provider Verification
- **Test HRV**: Fetches daily HRV averages for the last 30 days. Logs each daily value found and displays calculated 7-day (Ready) and 30-day (Baseline) moving averages.
- **Test RHR**: Fetches daily Resting Heart Rate averages for the last 7 days and logs each individual daily sample.
- **Test Workouts & TRIMP**: Fetches the most recent workout from the last 7 days and calculates the TRIMP (Training Impulse) score using the current RHR baseline.

### 2.3 Live Logging
- **Visual Feedback**: Displays a real-time, reverse-chronological list of activity logs.
- **Log Management**: Includes a "Clear" button in the Logs section header to reset the log history during testing sessions.

## 3. Architecture
- **Layer**: Features
- **Components**:
  - `SandboxView`: SwiftUI interface.
  - `SandboxStore`: `@Observable` coordinator using Domain Services and Data Providers.

## 4. Usage in Development
- Access via the "Open Provider Sandbox" button on the Main Menu.
- Use during integration phases to confirm that raw HealthKit data correctly flows into the physiological modeling logic.
