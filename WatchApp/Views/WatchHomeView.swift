import SwiftUI

struct WatchHomeView: View {
    @ObservedObject var viewModel: WatchGuardianViewModel

    var body: some View {
        VStack(spacing: 12) {
            if case .tracking = viewModel.state {
                trackingView
            } else {
                summaryView
                Button(action: viewModel.toggleMonitoring) {
                    Text(viewModelButtonTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .sheet(isPresented: $viewModel.showDetectionPrompt) {
            detectionSheet
        }
        .sheet(item: $viewModel.summary) { summary in
            SessionSummaryView(summary: summary)
        }
    }

    private var viewModelButtonTitle: String {
        switch viewModel.state {
        case .idle: return "开启守护模式"
        case .monitoring: return "关闭守护模式"
        case .awaitingConfirmation: return "等待确认"
        case .tracking: return "行为进行中"
        }
    }

    private var detectionSheet: some View {
        VStack(spacing: 12) {
            Text("检测到重复动作")
                .font(.headline)
            Text("确定要这么做吗？")
                .multilineTextAlignment(.center)
            HStack {
                Button("不是") {
                    viewModel.dismissDetection()
                }
                Button("记录") {
                    viewModel.confirmStart()
                }
                .tint(.green)
            }
        }
        .padding()
    }

    private var trackingView: some View {
        VStack(spacing: 8) {
            Text("行为进行中")
                .font(.headline)
            Text("时长：\(formattedDuration(viewModel.elapsedTime))")
            Text("重复次数：\(viewModel.currentRepetitionCount)")
            Text("平均频率：\(formattedFrequency(viewModel.currentFrequencyPerMinute))")
            Button("结束") {
                viewModel.endCurrentSession()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var summaryView: some View {
        VStack(spacing: 4) {
            VStack(spacing: 4) {
                Text("今天")
                    .font(.headline)
                Text("\(viewModel.todaysCount) 次")
                    .font(.title2)
            }
            VStack(spacing: 4) {
                Text("本周")
                Text("\(viewModel.weeklyCount) 次")
            }
            Text("已坚持 \(viewModel.streakText)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = duration >= 60 ? [.minute, .second] : [.second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: max(0, duration)) ?? "0s"
    }

    private func formattedFrequency(_ frequency: Double) -> String {
        guard frequency.isFinite, frequency > 0 else {
            return "-"
        }
        return String(format: "%.1f 次/分钟", frequency)
    }
}

private struct SessionSummaryView: View {
    let summary: SessionSummary
    @Environment(\.dismiss) private var dismiss

    private var formatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("本次总结")
                .font(.headline)
            Text("时长：\(formatter.string(from: summary.duration) ?? "0:00")")
            Text("重复次数：\(summary.repetitionCount)")
            if summary.averageFrequencyPerMinute > 0 {
                Text("平均频率：\(String(format: "%.1f 次/分钟", summary.averageFrequencyPerMinute))")
            } else {
                Text("平均频率：-")
            }
            Text(summary.feedback)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(feedbackColor)
            Button("好的") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var feedbackColor: Color {
        if summary.feedback.contains("正常") {
            return .green
        } else if summary.feedback.contains("注意") {
            return .orange
        } else {
            return .red
        }
    }
}
