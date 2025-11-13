import Foundation

public struct GuardianSettings: Codable, Equatable {
    public var weeklyLimit: Int?
    public var minimumIntervalDays: Int?
    public var allowNightReminders: Bool
    public var reminderQuietHours: ClosedRange<Int>

    public init(weeklyLimit: Int? = nil, minimumIntervalDays: Int? = nil, allowNightReminders: Bool = false, reminderQuietHours: ClosedRange<Int> = 0...6) {
        self.weeklyLimit = weeklyLimit
        self.minimumIntervalDays = minimumIntervalDays
        self.allowNightReminders = allowNightReminders
        self.reminderQuietHours = reminderQuietHours
    }
}
