import SwiftUI

struct SessionListView: View {
    @ObservedObject var store: BehaviorStore

    var body: some View {
        if store.sessions.isEmpty {
            Text("暂无记录")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .foregroundStyle(.secondary)
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
        VStack(alignment: .leading, spacing: 4) {
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
                Text("情绪：\(mood.label)")
                    .font(.subheadline)
            }
            if let trigger = session.trigger {
                Text("诱因：\(trigger.label)")
                    .font(.subheadline)
            }
            Button(role: .destructive, action: onDelete) {
                Text("删除记录")
            }
            .buttonStyle(.borderless)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var durationFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter
    }
}
