import Foundation

/// Base Stored Sample Data
class HealthDataBaseLocalSample: Identifiable {
    var id: UUID
    var value: Double
    var beginDate: Date
    var endDate: Date
    var unitString: String?

    init(
        id: UUID = UUID(),
        value: Double,
        beginDate: Date,
        endDate: Date,
        unitString: String? = nil
    ) {
        self.id = id
        self.value = value
        self.beginDate = beginDate
        self.endDate = endDate
        self.unitString = unitString
    }
}
