import Foundation
import Combine

final class WatchGuardianViewModel: ObservableObject {
    enum MonitoringState {
        case idle
        case monitoring
        case awaitingConfirmation
        case tracking(sessionID: UUID)
    }

    @Published var state: MonitoringState = .idle
    @Published var todaysCount: Int = 0
    @Published var weeklyCount: Int = 0
    @Published var streakText: String = "0 天"
    @Published var showDetectionPrompt: Bool = false

    private let store: BehaviorStore
    private let detector: GuardianMotionDetector
    private var cancellables = Set<AnyCancellable>()

    init(store: BehaviorStore, detector: GuardianMotionDetector = GuardianMotionDetector()) {
        self.store = store
        self.detector = detector

        store.$sessions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessions in
                guard let self else { return }
                let calendar = Calendar.current
                self.todaysCount = sessions.filter { calendar.isDateInToday($0.startDate) }.count
                self.weeklyCount = store.weeklyCount
                self.streakText = "\(store.longestStreakDays) 天"
            }
            .store(in: &cancellables)

        detector.detectionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.handleDetection()
            }
            .store(in: &cancellables)
    }

    func toggleMonitoring() {
        switch state {
        case .idle:
            detector.startMonitoring()
            state = .monitoring
        default:
            detector.stopMonitoring()
            state = .idle
        }
    }

    private func handleDetection() {
        guard state == .monitoring else { return }
        showDetectionPrompt = true
        state = .awaitingConfirmation
    }

    func confirmStart() {
        store.startSession()
        guard let session = store.sessions.last else { return }
        state = .tracking(sessionID: session.id)
        showDetectionPrompt = false
    }

    func dismissDetection() {
        showDetectionPrompt = false
        state = .monitoring
    }

    func endCurrentSession() {
        guard case let .tracking(id) = state else { return }
        store.endSession(id: id)
        state = .monitoring
    }
}
