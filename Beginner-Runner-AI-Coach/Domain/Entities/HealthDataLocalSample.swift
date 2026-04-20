import Foundation
import SwiftData

/// Base Stored Sample Data
@Model
class HealthDataBaseLocalSample: Identifiable {
    @Attribute(.unique) var id: UUID
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
