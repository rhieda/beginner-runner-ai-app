---
name: physiological-coach-agent
description: Expert guidance for implementing physiological agents and HealthKit data providers. Use when adding biometric calculations (TRIMP, HRV) or time-series providers.
---

# Physiological Coach Agent Skill

## Operating Rules

- Adhere strictly to the Clean Architecture: Mathematical logic in **Domain**, Data extraction in **Data**.
- All HealthKit providers must implement `HealthKitTimeSeriesRequestable` or `WorkoutDataRequestable`.
- Physiological constants (Banister, Karvonen) must be documented in code with scientific rationale.
- Use `HKStatisticsCollectionQuery` for daily groupings to avoid data gaps and ensure consistency for moving averages.

## Task Workflow

### Implement a New Physiological Metric
1. **Define the Interface**: Add a new protocol in `Domain/Interfaces/HealthInterfaces.swift`.
2. **Create the Domain Agent**: Implement the mathematical formula in `Domain/Services/`. See [physiological-formulas.md](references/physiological-formulas.md).
3. **Implement the Data Provider**: Create a provider in `Data/Provider/` following the patterns in [healthkit-patterns.md](references/healthkit-patterns.md).
4. **Update Repository**: Orchestrate fetching and caching in the relevant Repository.

### Analyze Physiological Trends
- Compare 7-day (Short-term/Ready) vs 30-day (Long-term/Baseline) HRV moving averages.
- A significant drop in the 7-day average relative to the 30-day baseline indicates accumulated fatigue.

## References

- [physiological-formulas.md](references/physiological-formulas.md) -- Detailed TRIMP and HRV moving average formulas and constants.
- [healthkit-patterns.md](references/healthkit-patterns.md) -- Standard code patterns for HealthKit time-series queries and grouping.
