import Foundation
import Combine
#if os(watchOS)
import WatchKit
#endif

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
    @Published var elapsedTime: TimeInterval = 0
    @Published var currentRepetitionCount: Int = 0
    @Published var currentFrequencyPerMinute: Double = 0
    @Published var summary: SessionSummary?

    private let store: BehaviorStore
    private let detector: GuardianMotionDetector
    private var cancellables = Set<AnyCancellable>()
    private var timerCancellable: AnyCancellable?
    private var sessionStartDate: Date?
    private var lastPromptDate: Date?

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
            .sink { [weak self] magnitude in
                self?.handleDetection(magnitude: magnitude)
            }
            .store(in: &cancellables)
    }

    deinit {
        timerCancellable?.cancel()
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

    private func handleDetection(magnitude: Double) {
        switch state {
        case .monitoring:
            let now = Date()
            if let lastPromptDate, now.timeIntervalSince(lastPromptDate) < 60 {
                return
            }
            lastPromptDate = now
            showDetectionPrompt = true
            state = .awaitingConfirmation
            triggerHaptic()
        case .tracking:
            currentRepetitionCount += 1
            updateFrequency()
        default:
            break
        }
    }

    func confirmStart() {
        store.startSession()
        guard let session = store.sessions.last else { return }
        sessionStartDate = Date()
        elapsedTime = 0
        currentRepetitionCount = 0
        currentFrequencyPerMinute = 0
        lastPromptDate = nil
        startTimer()
        state = .tracking(sessionID: session.id)
        showDetectionPrompt = false
    }

    func dismissDetection() {
        showDetectionPrompt = false
        state = .monitoring
    }

    func endCurrentSession() {
        guard case let .tracking(id) = state else { return }
        let endDate = Date()
        let duration = endDate.timeIntervalSince(sessionStartDate ?? endDate)
        let frequency = computeFrequency(for: duration)
        let sanitizedFrequency = frequency.isFinite ? max(0, frequency) : 0
        store.endSession(id: id,
                         at: endDate,
                         repetitionCount: currentRepetitionCount,
                         averageFrequencyPerMinute: sanitizedFrequency)
        state = .monitoring
        stopTimer()
        showDetectionPrompt = false
        presentSummary(duration: duration, frequency: sanitizedFrequency)
        sessionStartDate = nil
        lastPromptDate = nil
    }

    private func startTimer() {
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                guard let self, let start = self.sessionStartDate else { return }
                elapsedTime = date.timeIntervalSince(start)
                updateFrequency()
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    private func updateFrequency() {
        guard let start = sessionStartDate else { return }
        let duration = Date().timeIntervalSince(start)
        currentFrequencyPerMinute = computeFrequency(for: duration)
    }

    private func computeFrequency(for duration: TimeInterval) -> Double {
        guard duration > 0 else { return 0 }
        return Double(currentRepetitionCount) / (duration / 60)
    }

    private func presentSummary(duration: TimeInterval, frequency: Double) {
        let feedback = feedbackMessage(for: store.weeklyCount)
        summary = SessionSummary(duration: duration,
                                 repetitionCount: currentRepetitionCount,
                                 averageFrequencyPerMinute: frequency,
                                 feedback: feedback)
    }

    private func feedbackMessage(for weeklyCount: Int) -> String {
        switch weeklyCount {
        case ..<4:
            return "没事，这是正常频率"
        case 4...6:
            return "注意节奏，保持平衡"
        default:
            return "需要节制一点了"
        }
    }

    private func triggerHaptic() {
#if os(watchOS)
        WKInterfaceDevice.current().play(.notification)
#endif
    }
}

struct SessionSummary: Identifiable {
    let id = UUID()
    let duration: TimeInterval
    let repetitionCount: Int
    let averageFrequencyPerMinute: Double
    let feedback: String
}
