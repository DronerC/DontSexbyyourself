import Foundation
import Combine

final class DashboardViewModel: ObservableObject {
    @Published var weeklyCount: Int = 0
    @Published var monthlyCount: Int = 0
    @Published var averageInterval: String = "-"
    @Published var longestStreak: String = "0"

    private var cancellables = Set<AnyCancellable>()

    init(store: BehaviorStore) {
        store.$sessions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.weeklyCount = store.weeklyCount
                self?.monthlyCount = store.monthlyCount
                if let average = store.averageIntervalDays {
                    self?.averageInterval = String(format: "%.1f 天", average)
                } else {
                    self?.averageInterval = "-"
                }
                self?.longestStreak = "\(store.longestStreakDays) 天"
            }
            .store(in: &cancellables)
    }
}
