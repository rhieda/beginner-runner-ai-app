import Foundation

protocol RecoveryCalculationRepresentatable: Sendable {
    func calculateMovingAverages(from samples: [HealthDataBaseLocalSample]) -> (sevenDay: Double?, thirtyDay: Double?)
}

struct RecoveryCalculationService: RecoveryCalculationRepresentatable {
    /// Calculates 7-day and 30-day moving averages for Heart Rate Variability (HRV).
    ///
    /// Business Rule: Instead of reacting to daily fluctuations, the AI Coach evaluates biological readiness
    /// based on the relationship between short-term (7-day) and long-term (30-day) trends.
    /// A 7-day average significantly lower than the 30-day average may indicate accumulated fatigue.
    func calculateMovingAverages(from samples: [HealthDataBaseLocalSample]) -> (sevenDay: Double?, thirtyDay: Double?) {
        let sortedSamples = samples.sorted { $0.beginDate > $1.beginDate }
        
        let now = Date()
        let calendar = Calendar.current
        
        // Window definitions based on physiological research for sports adaptation.
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        
        let sevenDaySamples = sortedSamples.filter { $0.beginDate >= sevenDaysAgo }
        let thirtyDaySamples = sortedSamples.filter { $0.beginDate >= thirtyDaysAgo }
        
        // Mean calculation for the short-term window (readiness)
        let sevenDayAvg = sevenDaySamples.isEmpty ? nil : sevenDaySamples.reduce(0.0) { $0 + $1.value } / Double(sevenDaySamples.count)
        
        // Mean calculation for the long-term window (baseline)
        let thirtyDayAvg = thirtyDaySamples.isEmpty ? nil : thirtyDaySamples.reduce(0.0) { $0 + $1.value } / Double(thirtyDaySamples.count)
        
        return (sevenDayAvg, thirtyDayAvg)
    }
}
