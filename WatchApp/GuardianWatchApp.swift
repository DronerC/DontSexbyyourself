import SwiftUI

@main
struct GuardianWatchApp: App {
    @StateObject private var store: BehaviorStore
    @StateObject private var viewModel: WatchGuardianViewModel
    @StateObject private var syncManager: SessionSyncManager

    init() {
        let store = BehaviorStore()
        let syncManager = SessionSyncManager(store: store)
        _store = StateObject(wrappedValue: store)
        _syncManager = StateObject(wrappedValue: syncManager)
        _viewModel = StateObject(wrappedValue: WatchGuardianViewModel(store: store))
    }

    var body: some Scene {
        WindowGroup {
            WatchHomeView(viewModel: viewModel)
                .environmentObject(syncManager)
        }
    }
}
