import SwiftUI

struct WatchHomeView: View {
    @ObservedObject var viewModel: WatchGuardianViewModel

    var body: some View {
        VStack(spacing: 12) {
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
            Button(action: viewModel.toggleMonitoring) {
                Text(viewModelButtonTitle)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .sheet(isPresented: $viewModel.showDetectionPrompt) {
            detectionSheet
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
            Text("要记录为一次习惯行为吗？")
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
}
