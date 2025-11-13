# 节律守护 MVP

这是一份基于产品需求文档实现的最小化 SwiftUI MVP，包含 iPhone 与 Apple Watch 两端的界面、数据模型与伪动作检测逻辑。项目重点演示「守护模式」闭环：检测 → 用户确认 → 行为记录 → 统计回顾。

## 功能概览

- **Apple Watch 守护模式**：`WatchGuardianViewModel` + `GuardianMotionDetector` 持续监听重复动作，在侦测到疑似行为时伴随震动弹出温和提醒，用户可选择记录或忽略。
- **行为会话记录**：`BehaviorStore` 负责管理会话列表、时长、情绪与诱因标签，同时支持一键清除，并记录重复次数与平均节奏。
- **实时同步**：`SessionSyncManager` 基于 `WatchConnectivity` 将手表记录实时写回 iPhone，保证两端数据一致。
- **iPhone 仪表盘**：`DashboardView` 展示本周/本月次数、平均间隔、最长空窗，以及最近 7 天趋势图和详细列表。
- **目标与提醒设置**：`SettingsView` 支持配置每周次数与冷静期目标，并切换夜间提醒策略。
- **行为总结反馈**：手表端记录过程中实时显示时长、频率与重复次数，结束时生成总结与节奏建议，帮助用户温和自我管理。

## 目录结构

```
Shared/
  Models/
  Storage/
  Detection/
  Connectivity/
iOSApp/
  GuardianPhoneApp.swift
  Views/
  ViewModels/
WatchApp/
  GuardianWatchApp.swift
  Views/
  ViewModels/
```

`Shared` 目录包含跨端复用的核心逻辑；`iOSApp` 与 `WatchApp` 提供 SwiftUI 场景与 UI。

## 构建说明

该仓库未包含完整的 Xcode 工程文件，可在 Xcode 中创建 Multi-Platform 项目后，将上述 Swift 文件拷贝进对应 target（iOS 与 watchOS）。`GuardianMotionDetector` 在 watchOS 上使用 `CoreMotion`，在模拟环境会回退到模拟检测事件，便于预览流程。

## 隐私与数据

- 数据仅存储在本地 `Application Support` 目录。
- `BehaviorStore.clearAll()` 支持一键删除所有记录。
- 未引入任何第三方 SDK 或网络请求。

## 下一步可扩展方向

- 引入本地化 Core ML 模型降低误报。
- Watch 端加入误报反馈与冷静期替代建议组件。
- 扩展 iPhone 端情绪/诱因分析图表与更丰富的行为洞察。
