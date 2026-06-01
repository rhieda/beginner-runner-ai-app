# Physiological Formulas & Constants

## TRIMP (Training Impulse) - Banister Model
Quantifies the physiological stress of a workout session.

### Formula
`TRIMP = Duration (min) * DeltaHR * WeightingFactor`

### Components
1. **DeltaHR (Fractional Heart Rate Reserve)**:
   - `deltaHR = (avgHR - restingHR) / (maxHR - restingHR)`
   - Uses the Karvonen method to scale intensity from 0.0 to 1.0.

2. **Weighting Factor (y)**:
   - Accounts for the exponential increase in lactate.
   - `y = A * exp(B * deltaHR)`
   - **Male Constants**: A = 0.64, B = 1.92
   - **Female Constants**: A = 0.86, B = 1.67

## HRV Moving Averages
Used to assess central nervous system readiness.

### Readiness Window (Short-term)
- **Period**: 7 days.
- **Metric**: Simple Moving Average (SMA) of daily SDNN values.
- **Interpretation**: Current state of recovery.

### Baseline Window (Long-term)
- **Period**: 30 days.
- **Metric**: SMA of daily SDNN values.
- **Interpretation**: Historical biological capability.

### Readiness Score
- Ratio of 7-day Avg / 30-day Avg.
- > 1.0: Well recovered/Ready.
- < 0.8: Potential fatigue/Overtraining risk.
