//
//  FocusSessionLiveActivity.swift
//  FocusSessionWidget
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Widget
struct FocusSessionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusSessionAttributes.self) { context in
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(getBucketImage(for: context.state))
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(formatTime(context.state.timeRemaining))
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 4) {
                        ProgressView(value: getProgress(for: context.state))
                            .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "4CAF50")))
                        
                        Text(getMotivationalText(for: context.state))
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 8)
                }
            } compactLeading: {
                Image(getBucketImage(for: context.state))
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            } compactTrailing: {
                Text(formatTimeShort(context.state.timeRemaining))
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
            } minimal: {
                Image(systemName: "timer")
                    .foregroundColor(.white)
            }
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    private func formatTimeShort(_ seconds: Int) -> String {
        let mins = seconds / 60
        return "\(mins)m"
    }
    
    private func getProgress(for state: FocusSessionAttributes.ContentState) -> Double {
        let totalSeconds = state.totalMinutes * 60
        let elapsed = totalSeconds - state.timeRemaining
        return Double(elapsed) / Double(totalSeconds)
    }
    
    private func getBucketImage(for state: FocusSessionAttributes.ContentState) -> String {
        let progress = getProgress(for: state)
        if progress < 0.5 {
            return "bucket_empty"
        } else if progress < 0.75 {
            return "bucket_half"
        } else {
            return "bucket_full"
        }
    }
    
    private func getMotivationalText(for state: FocusSessionAttributes.ContentState) -> String {
        let progress = getProgress(for: state)
        
        if progress < 0.25 {
            return "stay focused!"
        } else if progress < 0.5 {
            return "keep going!"
        } else if progress < 0.75 {
            return "halfway there!"
        } else {
            return "almost done!"
        }
    }
}

// MARK: - Lock Screen View (SIMPLIFIED)
struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<FocusSessionAttributes>
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "786C59"))
            
            VStack(spacing: 12) {
                // Title
                Text("Focus Session")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black.opacity(0.7))
                
                // Bucket + Timer in horizontal layout
                HStack(spacing: 20) {
                    // Bucket image
                    Image(getBucketImage())
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                    
                    // Timer
                    Text(formatTime(context.state.timeRemaining))
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                }
                
                // Progress bar
                ProgressView(value: getProgress())
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "4CAF50")))
                    .frame(height: 8)
                    .padding(.horizontal, 24)
                
                // Motivational text
                Text(getMotivationalText())
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black.opacity(0.7))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    private func getProgress() -> Double {
        let totalSeconds = context.state.totalMinutes * 60
        let elapsed = totalSeconds - context.state.timeRemaining
        return Double(elapsed) / Double(totalSeconds)
    }
    
    private func getBucketImage() -> String {
        let progress = getProgress()
        if progress < 0.5 {
            return "bucket_empty"
        } else if progress < 0.75 {
            return "bucket_half"
        } else {
            return "bucket_full"
        }
    }
    
    private func getMotivationalText() -> String {
        let progress = getProgress()
        
        if progress < 0.25 {
            return "stay focused!"
        } else if progress < 0.5 {
            return "keep going!"
        } else if progress < 0.75 {
            return "halfway there!"
        } else {
            return "almost done!"
        }
    }
}

// MARK: - Widget Bundle
@main
struct FocusSessionWidgetBundle: WidgetBundle {
    var body: some Widget {
        FocusSessionLiveActivity()
    }
}
