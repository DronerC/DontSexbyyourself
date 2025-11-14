import Foundation

/// A single recorded behavior session.
public struct BehaviorSession: Identifiable, Codable, Hashable {
    public let id: UUID
    public var startDate: Date
    public var endDate: Date?
    public var mood: Mood?
    public var trigger: Trigger?
    public var repetitionCount: Int
    public var averageFrequencyPerMinute: Double?

    public init(id: UUID = UUID(),
                startDate: Date,
                endDate: Date? = nil,
                mood: Mood? = nil,
                trigger: Trigger? = nil,
                repetitionCount: Int = 0,
                averageFrequencyPerMinute: Double? = nil) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.mood = mood
        self.trigger = trigger
        self.repetitionCount = repetitionCount
        self.averageFrequencyPerMinute = averageFrequencyPerMinute
    }

    public var duration: TimeInterval? {
        guard let endDate else { return nil }
        return endDate.timeIntervalSince(startDate)
    }

    public enum Mood: String, Codable, CaseIterable, Identifiable {
        case satisfied
        case empty
        case anxious
        case bored
        case stressed
        case sleepless

        public var id: String { rawValue }

        public var label: String {
            switch self {
            case .satisfied: return "满足"
            case .empty: return "空虚"
            case .anxious: return "焦虑"
            case .bored: return "无聊"
            case .stressed: return "压力大"
            case .sleepless: return "失眠"
            }
        }
    }

    public enum Trigger: String, Codable, CaseIterable, Identifiable {
        case boredom
        case loneliness
        case stress
        case insomnia
        case curiosity
        case stimulation

        public var id: String { rawValue }

        public var label: String {
            switch self {
            case .boredom: return "无聊"
            case .loneliness: return "孤独"
            case .stress: return "压力大"
            case .insomnia: return "睡不着"
            case .curiosity: return "好奇"
            case .stimulation: return "受到刺激"
            }
        }
    }
}
