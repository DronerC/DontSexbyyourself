import SwiftUI

@main
struct GuardianPhoneApp: App {
    @StateObject private var store: BehaviorStore
    @StateObject private var syncManager: SessionSyncManager

    init() {
        let store = BehaviorStore()
        let syncManager = SessionSyncManager(store: store)
        _store = StateObject(wrappedValue: store)
        _syncManager = StateObject(wrappedValue: syncManager)
    }

    var body: some Scene {
        WindowGroup {
            DashboardView(viewModel: DashboardViewModel(store: store), store: store)
                .environmentObject(syncManager)
        }
    }
}
