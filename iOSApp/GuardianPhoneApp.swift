import SwiftUI

@main
struct GuardianPhoneApp: App {
    @StateObject private var store = BehaviorStore()

    var body: some Scene {
        WindowGroup {
            DashboardView(viewModel: DashboardViewModel(store: store), store: store)
        }
    }
}
