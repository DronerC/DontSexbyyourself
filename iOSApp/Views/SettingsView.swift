import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: BehaviorStore

    var body: some View {
        Form {
            Section("🎯 目标") {
                TextField("每周最多次数", text: Binding(
                    get: { valueOrEmpty(store.settings.weeklyLimit) },
                    set: { store.settings.weeklyLimit = Int($0) }
                ))
                .keyboardType(.numberPad)

                TextField("希望最小间隔 (天)", text: Binding(
                    get: { valueOrEmpty(store.settings.minimumIntervalDays) },
                    set: { store.settings.minimumIntervalDays = Int($0) }
                ))
                .keyboardType(.numberPad)
            }
            .foregroundStyle(.white)
            .listRowBackground(LinearGradient(colors: [.orange.opacity(0.9), .pink.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))

            Section("🔔 提醒") {
                Toggle("夜间也允许提醒", isOn: $store.settings.allowNightReminders)
            }
            .foregroundStyle(.white)
            .listRowBackground(LinearGradient(colors: [.mint.opacity(0.9), .teal.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))

            Section {
                Button(role: .destructive) {
                    store.clearAll()
                } label: {
                    Text("🧹 清除所有数据")
                }
            }
            .foregroundStyle(.white)
            .listRowBackground(LinearGradient(colors: [.purple.opacity(0.8), .indigo.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        .scrollContentBackground(.hidden)
        .background(
            LinearGradient(colors: [.purple.opacity(0.95), .pink.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        )
        .tint(.yellow)
        .navigationTitle("⚙️ 设置")
    }

    private func valueOrEmpty(_ value: Int?) -> String {
        guard let value else { return "" }
        return String(value)
    }
}
