import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @ObservedObject var store: BehaviorStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    summarySection
                    trendSection
                    sessionsSection
                }
                .padding()
            }
            .navigationTitle("节律仪表盘")
            .toolbar {
                NavigationLink("设置") {
                    SettingsView(store: store)
                }
            }
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("本周 \(viewModel.weeklyCount) 次")
                .font(.title2)
                .fontWeight(.semibold)
            Text("本月 \(viewModel.monthlyCount) 次")
            Text("平均间隔：\(viewModel.averageInterval)")
            Text("最长空窗：\(viewModel.longestStreak)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var trendSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("最近记录")
                .font(.headline)
            if store.sessions.isEmpty {
                Text("还没有记录，守护模式会帮助你识别新的行为。")
                    .foregroundStyle(.secondary)
            } else {
                SessionChartView(sessions: store.sessions)
                    .frame(height: 160)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var sessionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("行为记录")
                .font(.headline)
            SessionListView(store: store)
        }
    }
}

struct SessionChartView: View {
    let sessions: [BehaviorSession]

    private var grouped: [(String, Int)] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        let lastSeven = (0..<7).compactMap { calendar.date(byAdding: .day, value: -$0, to: Date()) }
        let counts = Dictionary(grouping: sessions) { session -> String in
            let day = calendar.startOfDay(for: session.startDate)
            return dateFormatter.string(from: day)
        }
        return lastSeven.reversed().map { day in
            let label = dateFormatter.string(from: day)
            return (label, counts[label]?.count ?? 0)
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width / CGFloat(grouped.count)
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(grouped, id: \.0) { label, count in
                    VStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.blue.opacity(0.4))
                            .frame(width: width * 0.6, height: CGFloat(count) * 24)
                        Text(label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
