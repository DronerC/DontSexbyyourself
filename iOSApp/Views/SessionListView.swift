import SwiftUI

struct SessionListView: View {
    @ObservedObject var store: BehaviorStore

    var body: some View {
        if store.sessions.isEmpty {
            Text("🌱 暂无记录，开启守护模式试试看！")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .foregroundStyle(.white.opacity(0.85))
        } else {
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(store.sessions.sorted(by: { $0.startDate > $1.startDate })) { session in
                    SessionRow(session: session, onDelete: { store.deleteSession(id: session.id) })
                }
            }
        }
    }
}

private struct SessionRow: View {
    let session: BehaviorSession
    let onDelete: () -> Void
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(formatter.string(from: session.startDate))
                    .font(.headline)
                Spacer()
                if let duration = session.duration {
                    Text(durationFormatter.string(from: duration) ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            if let mood = session.mood {
                Text("😊 情绪：\(mood.label)")
                    .font(.subheadline)
            }
            if let trigger = session.trigger {
                Text("🎯 诱因：\(trigger.label)")
                    .font(.subheadline)
            }
            if session.repetitionCount > 0 {
                Text("🔁 重复次数：\(session.repetitionCount)")
                    .font(.subheadline)
            }
            if let frequency = session.averageFrequencyPerMinute {
                Text(String(format: "🎵 平均频率：%.1f 次/分钟", frequency))
                    .font(.subheadline)
            }
            Button(role: .destructive, action: onDelete) {
                Text("🗑️ 删除记录")
            }
            .buttonStyle(.borderless)
        }
        .padding()
        .background(
            LinearGradient(colors: [.purple.opacity(0.9), .pink.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .foregroundStyle(.white)
        .shadow(color: .pink.opacity(0.4), radius: 8, x: 0, y: 4)
    }

    private var durationFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter
    }
}
