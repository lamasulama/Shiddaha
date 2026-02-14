// WeeklyProgressView.swift
// ✅ Updates:
// 1) Push EVERYTHING down (bigger top spacer)
// 2) Vertical line stops at 6H (does NOT extend past the top tick area)
// 3) Vertical line still reaches the baseline (so palms sit under 1H correctly)

import SwiftUI
import SwiftData

struct WeeklyProgressView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: OnboardingViewModel
    @Query private var sessions: [StudySession]

    // MARK: - DESIGN CONSTANTS

    private let backgroundAssetName = "weekly_progress_bg"

    // ✅ Push whole screen down
    private let screenTopPush: CGFloat = 125

    // Back button positioning
    private let backTopPadding: CGFloat = -70
    private let backLeadingPadding: CGFloat = 22

    // Title
    private let titleTopGap: CGFloat = 50
    private let titleFontSize: CGFloat = 20

    // Chart
    private let chartTopGap: CGFloat = 38
    private let chartHeight: CGFloat = 220

    // Axis
    private let axisWidth: CGFloat = 60
    private let axisLineWidth: CGFloat = 8
    private let axisColor = Color(hex: "8B4513")
    private let axisFontSize: CGFloat = 11
    private let tickWidth: CGFloat = 10
    private let tickHeight: CGFloat = 3

    // Baseline
    private let baselineHeight: CGFloat = 8

    // ✅ Vertical line tuning
    private let axisTopTrim: CGFloat = 5 // makes vertical line NOT "linger" above 6H

    // Palms
    private let palmWidth: CGFloat = 38
    private let palmSpacing: CGFloat = 10
    private let palmMinHeight: CGFloat = 55
    private let palmMaxHeightPercent: CGFloat = 0.92

    // Day labels
    private let dayFontSize: CGFloat = 9
    private let dayTopGap: CGFloat = 4
    private let dayNormalOpacity: Double = 0.6
    private let todayGreen = Color(hex: "4CAF50")

    // Total text
    private let totalTopGap: CGFloat = 65
    private let totalFontSize: CGFloat = 12

    var body: some View {
        ZStack {
            Image(backgroundAssetName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // ✅ Push everything down
                Spacer().frame(height: screenTopPush)

                // Back Button
                HStack {
                    PixelBackButton(action: { dismiss() })
                    Spacer()
                }
                .padding(.top, backTopPadding)
                .padding(.leading, backLeadingPadding)

                Spacer().frame(height: titleTopGap)

                // Title (Centered)
                Text("Weekly Focus Progress")
                    .font(.custom("PressStart2P-Regular", size: titleFontSize))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)

                Spacer().frame(height: chartTopGap)

                // MARK: - CHART BLOCK
                VStack(spacing: 0) {

                    HStack(alignment: .bottom, spacing: 0) {

                        // ✅ Y Axis (stops at top of ticks, reaches baseline)
                        ZStack(alignment: .trailing) {

                            // Total axis area height = chartHeight + baselineHeight
                            // But the visible vertical line is slightly shorter on top (axisTopTrim)
                            Rectangle()
                                .fill(axisColor)
                                .frame(
                                    width: axisLineWidth,
                                    height: (chartHeight + baselineHeight) - axisTopTrim
                                )
                                .frame(height: chartHeight + baselineHeight, alignment: .bottom) // anchor to baseline

                            // Tick labels aligned to chart area only (above baseline)
                            VStack(spacing: 0) {
                                ForEach((1...6).reversed(), id: \.self) { h in
                                    HStack(spacing: 6) {
                                        Text("\(h)H")
                                            .font(.custom("PressStart2P-Regular", size: axisFontSize))
                                            .foregroundColor(.black.opacity(0.6))

                                        Rectangle()
                                            .fill(axisColor)
                                            .frame(width: tickWidth, height: tickHeight)
                                    }
                                    .frame(height: chartHeight / 6, alignment: .trailing)
                                }
                            }
                            .padding(.trailing, 6)
                            .padding(.bottom, baselineHeight)
                        }
                        .frame(width: axisWidth)
                        .frame(height: chartHeight + baselineHeight, alignment: .bottom)

                        // Palms
                        HStack(alignment: .bottom, spacing: palmSpacing) {
                            ForEach(0..<7, id: \.self) { idx in
                                let bucket = hourBucket(hoursForDay(idx))
                                let height = palmHeight(bucket)

                                VStack(spacing: 0) {
                                    Spacer(minLength: 0)
                                    Image("palm_\(bucket)h")
                                        .resizable()
                                        .interpolation(.none)
                                        .scaledToFit()
                                        .frame(width: palmWidth, height: height, alignment: .bottom)
                                }
                                .frame(width: palmWidth, height: chartHeight, alignment: .bottom)
                            }
                        }
                        .frame(height: chartHeight, alignment: .bottom)
                    }

                    // Baseline
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(axisColor)
                            .frame(width: axisWidth - 4, height: baselineHeight)

                        Rectangle()
                            .fill(axisColor)
                            .frame(height: baselineHeight)
                    }

                    // Day Labels
                    HStack(spacing: 0) {
                        Spacer().frame(width: axisWidth)

                        HStack(spacing: palmSpacing) {
                            ForEach(0..<7, id: \.self) { idx in
                                Text(dayName(idx))
                                    .font(.custom("PressStart2P-Regular", size: dayFontSize))
                                    .foregroundColor(isToday(idx) ? todayGreen : .black.opacity(dayNormalOpacity))
                                    .frame(width: palmWidth)
                            }
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(.top, dayTopGap)
                }

                Spacer().frame(height: totalTopGap)

                // ✅ TOTAL TEXT (ONE LINE, SAME FONT SIZE, ONLY HOURS GREEN)
                Text("You have accumulated Total of \(weeklyTotalHours) Hours This week!!")
                    .font(.custom("PressStart2P-Regular", size: totalFontSize))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .overlay(
                        // draw the green number on top, same size, same position
                        Text("\(weeklyTotalHours)")
                            .font(.custom("PressStart2P-Regular", size: totalFontSize))
                            .foregroundColor(todayGreen)
                            .padding(.horizontal, 20)
                            .opacity(1)
                            .mask(
                                // mask so ONLY the number is visible
                                Text("You have accumulated Total of \(weeklyTotalHours) Hours This week!!")
                                    .font(.custom("PressStart2P-Regular", size: totalFontSize))
                                    .foregroundColor(.black)
                            )
                    )

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Data

    private var weeklyTotalHours: Int {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let weekSessions = sessions.filter { $0.sessionDate >= weekStart }
        let totalMinutes = weekSessions.reduce(0) { $0 + $1.minutesStudied }
        return totalMinutes / 60
    }

    private func hoursForDay(_ dayIndex: Int) -> Double {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!

        let target = calendar.date(byAdding: .day, value: dayIndex, to: weekStart)!
        let start = calendar.startOfDay(for: target)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!

        let daySessions = sessions.filter { $0.sessionDate >= start && $0.sessionDate < end }
        let totalMinutes = daySessions.reduce(0) { $0 + $1.minutesStudied }
        return Double(totalMinutes) / 60.0
    }

    private func hourBucket(_ hours: Double) -> Int {
        let h = Int(floor(hours))
        return min(max(h, 0), 6)
    }

    private func palmHeight(_ bucket: Int) -> CGFloat {
        let maxHeight = chartHeight * palmMaxHeightPercent
        if bucket == 0 { return palmMinHeight }
        let ratio = CGFloat(bucket) / 6.0
        return palmMinHeight + (maxHeight - palmMinHeight) * ratio
    }

    private func dayName(_ index: Int) -> String {
        ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"][index]
    }

    private func isToday(_ index: Int) -> Bool {
        let today = Calendar.current.component(.weekday, from: Date())
        return (today - 1) == index
    }
}
