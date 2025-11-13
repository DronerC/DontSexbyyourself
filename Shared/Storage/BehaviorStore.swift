import Foundation
import Combine

public final class BehaviorStore: ObservableObject {
    @Published public private(set) var sessions: [BehaviorSession]
    @Published public var settings: GuardianSettings
    private let sessionStorage: DiskStorage<[BehaviorSession]>
    private let settingsStorage: DiskStorage<GuardianSettings>
    private var cancellables = Set<AnyCancellable>()

    public init(sessionStorage: DiskStorage<[BehaviorSession]> = DiskStorage(filename: "sessions.json"),
                settingsStorage: DiskStorage<GuardianSettings> = DiskStorage(filename: "settings.json")) {
        self.sessionStorage = sessionStorage
        self.settingsStorage = settingsStorage
        self.sessions = sessionStorage.load() ?? []
        self.settings = settingsStorage.load() ?? GuardianSettings()

        $sessions
            .dropFirst()
            .sink { [weak self] value in self?.sessionStorage.save(value) }
            .store(in: &cancellables)

        $settings
            .dropFirst()
            .sink { [weak self] value in self?.settingsStorage.save(value) }
            .store(in: &cancellables)
    }

    public func startSession(at date: Date = Date()) {
        var updated = sessions
        updated.append(BehaviorSession(startDate: date))
        sessions = updated
    }

    public func endSession(id: BehaviorSession.ID, at date: Date = Date(), mood: BehaviorSession.Mood? = nil, trigger: BehaviorSession.Trigger? = nil) {
        guard let index = sessions.firstIndex(where: { $0.id == id }) else { return }
        var session = sessions[index]
        session.endDate = date
        session.mood = mood
        session.trigger = trigger
        sessions[index] = session
    }

    public func deleteSession(id: BehaviorSession.ID) {
        sessions.removeAll { $0.id == id }
    }

    public func clearAll() {
        sessions.removeAll()
        sessionStorage.delete()
        settingsStorage.delete()
        settings = GuardianSettings()
    }

    public var weeklyCount: Int {
        guard let start = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else { return 0 }
        return sessions.filter { $0.startDate >= start }.count
    }

    public var monthlyCount: Int {
        guard let start = Calendar.current.date(byAdding: .day, value: -30, to: Date()) else { return 0 }
        return sessions.filter { $0.startDate >= start }.count
    }

    public var averageIntervalDays: Double? {
        let sorted = sessions.sorted { $0.startDate < $1.startDate }
        guard sorted.count >= 2 else { return nil }
        var intervals: [Double] = []
        for pair in zip(sorted, sorted.dropFirst()) {
            let days = pair.1.startDate.timeIntervalSince(pair.0.startDate) / 86_400
            intervals.append(days)
        }
        guard !intervals.isEmpty else { return nil }
        return intervals.reduce(0, +) / Double(intervals.count)
    }

    public var longestStreakDays: Int {
        let sorted = sessions.sorted { $0.startDate < $1.startDate }
        guard var previous = sorted.first?.startDate else {
            return 0
        }
        var longest: Double = 0
        for session in sorted.dropFirst() {
            let interval = session.startDate.timeIntervalSince(previous)
            longest = max(longest, interval)
            previous = session.startDate
        }
        let currentInterval = Date().timeIntervalSince(previous)
        longest = max(longest, currentInterval)
        return Int(longest / 86_400)
    }
}
