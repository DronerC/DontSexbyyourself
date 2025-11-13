import SwiftUI

@main
struct GuardianWatchApp: App {
    @StateObject private var store: BehaviorStore
    @StateObject private var viewModel: WatchGuardianViewModel

    init() {
        let store = BehaviorStore()
        _store = StateObject(wrappedValue: store)
        _viewModel = StateObject(wrappedValue: WatchGuardianViewModel(store: store))
    }

    var body: some Scene {
        WindowGroup {
            WatchHomeView(viewModel: viewModel)
        }
    }
}
