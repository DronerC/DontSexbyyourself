import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: BehaviorStore

    var body: some View {
        Form {
            Section("目标") {
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

            Section("提醒") {
                Toggle("夜间也允许提醒", isOn: $store.settings.allowNightReminders)
            }

            Section {
                Button(role: .destructive) {
                    store.clearAll()
                } label: {
                    Text("清除所有数据")
                }
            }
        }
        .navigationTitle("设置")
    }

    private func valueOrEmpty(_ value: Int?) -> String {
        guard let value else { return "" }
        return String(value)
    }
}
