import Foundation
import Combine

#if os(iOS) || os(watchOS)
import WatchConnectivity
#endif

/// Bridges behavior session updates between watchOS and iOS using WatchConnectivity.
public final class SessionSyncManager: NSObject, ObservableObject {
    private let store: BehaviorStore
    private var cancellables = Set<AnyCancellable>()

#if os(iOS) || os(watchOS)
    private var session: WCSession?
#endif
    private var isApplyingRemoteUpdate = false

    public init(store: BehaviorStore) {
        self.store = store
        super.init()

#if os(iOS) || os(watchOS)
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            self.session = session
        }
#endif

        store.$sessions
            .dropFirst()
            .sink { [weak self] sessions in
                self?.handleLocalChange(sessions)
            }
            .store(in: &cancellables)
    }

    private func handleLocalChange(_ sessions: [BehaviorSession]) {
        guard !isApplyingRemoteUpdate else { return }
#if os(iOS) || os(watchOS)
        guard let session else { return }
        guard session.activationState == .activated else { return }
        let message = SessionMessage.replaceAll(sessions)
        do {
            let data = try JSONEncoder().encode(message)
            try session.updateApplicationContext(["payload": data])
        } catch {
#if DEBUG
            print("SessionSyncManager send error: \(error)")
#endif
        }
#endif
    }

    private func applyRemoteSessions(_ sessions: [BehaviorSession]) {
        DispatchQueue.main.async {
            self.isApplyingRemoteUpdate = true
            self.store.replaceAllSessions(sessions)
            self.isApplyingRemoteUpdate = false
        }
    }
}

#if os(iOS) || os(watchOS)
extension SessionSyncManager: WCSessionDelegate {
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            handleLocalChange(store.sessions)
        }
    }

#if os(iOS)
    public func sessionDidBecomeInactive(_ session: WCSession) {}

    public func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
#endif

    public func sessionReachabilityDidChange(_ session: WCSession) {
        if session.activationState == .activated {
            handleLocalChange(store.sessions)
        }
    }

    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        guard let data = applicationContext["payload"] as? Data else { return }
        guard let message = try? JSONDecoder().decode(SessionMessage.self, from: data) else { return }
        switch message {
        case let .replaceAll(sessions):
            applyRemoteSessions(sessions)
        case let .start(date):
            DispatchQueue.main.async {
                self.isApplyingRemoteUpdate = true
                self.store.startSession(at: date)
                self.isApplyingRemoteUpdate = false
            }
        case let .end(id, endDate):
            DispatchQueue.main.async {
                self.isApplyingRemoteUpdate = true
                self.store.endSession(id: id, at: endDate)
                self.isApplyingRemoteUpdate = false
            }
        case let .delete(id):
            DispatchQueue.main.async {
                self.isApplyingRemoteUpdate = true
                self.store.deleteSession(id: id)
                self.isApplyingRemoteUpdate = false
            }
        }
    }
}
#endif
