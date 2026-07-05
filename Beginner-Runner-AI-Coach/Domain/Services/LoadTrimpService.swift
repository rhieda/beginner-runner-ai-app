import Foundation

protocol LoadTRIMPRepresentable: Sendable {
    func calculateTRIMP(
        durationInMinutes: Double,
        avgHeartRate: Double,
        maxHeartRate: Double,
        restingHeartRate: Double,
        isMale: Bool
    ) -> Double
}

struct LoadTrimpService: LoadTRIMPRepresentable {
    /// Calculates the Training Impulse (TRIMP) using Banister's original formula.
    ///
    /// TRIMP quantifies the physiological stress of a workout session by combining duration,
    /// fractional heart rate reserve, and a non-linear weighting factor to account for the
    /// exponential increase in lactate at high intensities.
    ///
    /// - Parameters:
    ///   - durationInMinutes: Total length of the workout session.
    ///   - avgHeartRate: Average Heart Rate recorded during the session.
    ///   - maxHeartRate: The user's theoretical or recorded Maximum Heart Rate.
    ///   - restingHeartRate: The user's current Resting Heart Rate (from HRV/RHR trends).
    ///   - isMale: Boolean to apply gender-specific weighting factors.
    /// - Returns: A unified load score (Double).
    func calculateTRIMP(
        durationInMinutes: Double,
        avgHeartRate: Double,
        maxHeartRate: Double,
        restingHeartRate: Double,
        isMale: Bool
    ) -> Double {
        // Delta HR represents the fractional heart rate reserve (Karvonen method).
        // It scales intensity between 0.0 (rest) and 1.0 (maximal effort).
        let deltaHR = (avgHeartRate - restingHeartRate) / (maxHeartRate - restingHeartRate)
        
        // Weighting Factor (y): Represents the non-linear relationship between intensity and blood lactate.
        // Formula: y = A * exp(B * deltaHR)
        // Constants A and B differ between biological sexes due to physiological response curves:
        // Male: A = 0.64, B = 1.92
        // Female: A = 0.86, B = 1.67
        let weightingFactor: Double
        if isMale {
            weightingFactor = 0.64 * exp(1.92 * deltaHR)
        } else {
            weightingFactor = 0.86 * exp(1.67 * deltaHR)
        }
        
        // Final Score: Duration * Fractional Intensity * Physiological Weight
        return durationInMinutes * deltaHR * weightingFactor
    }
}
