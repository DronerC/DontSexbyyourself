import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @ObservedObject var store: BehaviorStore

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.pink.opacity(0.9), .orange.opacity(0.9), .purple.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        summarySection
                        trendSection
                        sessionsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("🌈 节律仪表盘")
            .toolbar {
                NavigationLink("⚙️ 设置") {
                    SettingsView(store: store)
                }
            }
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🚀 本周 \(viewModel.weeklyCount) 次")
                .font(.title2)
                .fontWeight(.black)
            Text("🌟 本月 \(viewModel.monthlyCount) 次")
            Text("⏳ 平均间隔：\(viewModel.averageInterval)")
            Text("🏆 最长空窗：\(viewModel.longestStreak)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .foregroundStyle(.white)
        .shadow(color: .purple.opacity(0.4), radius: 12, x: 0, y: 8)
    }

    private var trendSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("📈 最近记录")
                .font(.headline)
            if store.sessions.isEmpty {
                Text("还没有记录，守护模式会帮助你识别新的行为 ✨")
                    .foregroundStyle(.white.opacity(0.8))
            } else {
                SessionChartView(sessions: store.sessions)
                    .frame(height: 160)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(colors: [.mint, .teal], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .foregroundStyle(.white)
        .shadow(color: .teal.opacity(0.35), radius: 10, x: 0, y: 6)
    }

    private var sessionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🗒️ 行为记录")
                .font(.headline)
            SessionListView(store: store)
        }
        .padding()
        .background(
            LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .foregroundStyle(.white)
        .shadow(color: .orange.opacity(0.35), radius: 10, x: 0, y: 6)
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
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(colors: [.white.opacity(0.9), .pink.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                            )
                            .frame(width: width * 0.6, height: CGFloat(count) * 24)
                        Text(label)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
