import Foundation
import Combine
#if os(watchOS)
import CoreMotion
#endif

/// Provides a Combine stream describing possible sessions detected by the motion sensor.
public final class GuardianMotionDetector: ObservableObject {
    public enum State: Equatable {
        case idle
        case monitoring
        case possibleEvent
    }

    @Published public private(set) var state: State = .idle
    @Published public private(set) var lastDetectionDate: Date?

    private let subject = PassthroughSubject<Void, Never>()
    private var cancellable: AnyCancellable?
    #if os(watchOS)
    private var motionManager: CMMotionManager?
    #endif

    public init() {}

    /// Start monitoring sensors. On watchOS we listen to motion events; on other platforms we emit simulated values for previews.
    public func startMonitoring() {
        guard cancellable == nil else { return }
        state = .monitoring
    #if os(watchOS)
        let manager = CMMotionManager()
        manager.deviceMotionUpdateInterval = 0.5
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self else { return }
            guard let motion else { return }
            let acceleration = motion.userAcceleration
            let magnitude = sqrt(acceleration.x * acceleration.x + acceleration.y * acceleration.y + acceleration.z * acceleration.z)
            if magnitude > 1.2 {
                self.state = .possibleEvent
                self.lastDetectionDate = Date()
                self.subject.send()
            }
        }
        motionManager = manager
        cancellable = AnyCancellable { [weak self] in
            self?.motionManager?.stopDeviceMotionUpdates()
            self?.motionManager = nil
        }
    #else
        // Simulator friendly: emit a fake detection when started.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self else { return }
            self.state = .possibleEvent
            self.lastDetectionDate = Date()
            self.subject.send()
        }
        cancellable = AnyCancellable {}
    #endif
    }

    public func stopMonitoring() {
        cancellable?.cancel()
        cancellable = nil
        state = .idle
        #if os(watchOS)
        motionManager?.stopDeviceMotionUpdates()
        motionManager = nil
        #endif
    }

    public var detectionPublisher: AnyPublisher<Void, Never> {
        subject.eraseToAnyPublisher()
    }
}
