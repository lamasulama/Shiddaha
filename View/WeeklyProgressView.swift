import SwiftUI
import SwiftData

struct WeeklyProgressView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: OnboardingViewModel

    @Query private var sessions: [StudySession]

    // 🎯 ============================================================
    // MARK: - ALL ADJUSTABLE POSITIONS (EVERY SINGLE OBJECT)
    // 🎯 ============================================================
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // TITLE ("Weekly Focus Progress")
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    private let titleTop: CGFloat = 60                    // Space from top (adjusted since no back button)
    private let titleSize: CGFloat = 18                   // Font size

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // CHART CONTAINER (entire chart area)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    private let chartTop: CGFloat = 30                    // Space below title
    private let chartSidePadding: CGFloat = 1             // Left/right padding (decrease to shift left)
    private let chartHeightPercent: CGFloat = 0.45        // Chart height as % of screen (0.45 = 45%)
    private let chartMaxHeight: CGFloat = 430             // Maximum chart height

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // Y-AXIS (brown vertical line on left with hour labels)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    private let axisWidth: CGFloat = 56                   // Total width of Y-axis area
    private let axisLineWidth: CGFloat = 10               // Brown vertical line thickness
    private let axisLineOffsetX: CGFloat = -2             // Shift brown line left/right
    private let axisFont: CGFloat = 11                    // Hour label font size (1H, 2H, etc.)
    private let axisLabelOpacity: Double = 0.55           // Hour label transparency
    private let axisLabelToTickGap: CGFloat = 6           // Space between label and tick
    
    // Y-axis ticks (small horizontal lines)
    private let tickW: CGFloat = 10                       // Tick width (length)
    private let tickH: CGFloat = 4                        // Tick height (thickness)

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // BASELINE (brown horizontal line at bottom of chart)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    private let baselineH: CGFloat = 10                   // Thickness of horizontal baseline
    private let baselineYAxisWidth: CGFloat = -2          // Width adjustment for baseline under Y-axis

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // PALM TREES (7 trees for each day)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    private let palmWidth: CGFloat = 45                   // Width of each palm tree
    private let palmSpacing: CGFloat = 6                  // Space between palm trees
    private let palmToAxisGap: CGFloat = -6               // Gap between axis and first palm (negative = closer)
    private let palmMinHeight: CGFloat = 70               // Minimum palm height (0 hours)
    private let palmMaxHeightPercent: CGFloat = 0.92      // Max palm as % of chart height (6+ hours)
    private let palmVerticalOffset: CGFloat = 17          // 🎯 Push palms down (increase to move more down)

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // DAY LABELS (Sun, Mon, Tue, etc. below palms)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    private let dayFont: CGFloat = 8                      // Font size of day names
    private let dayTopGap: CGFloat = 8                    // Space above day labels (from baseline)
    private let dayNormalOpacity: Double = 0.55           // Opacity for non-today days
    private let dayLabelLeftAdjust: CGFloat = -2          // Fine-tune day label alignment

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // TOTAL TEXT ("You have accumulated Total of X Hours...")
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    private let totalTop: CGFloat = 30                    // Space above total text (from day labels)
    private let totalFont: CGFloat = 12                  // Font size for regular tex
    private let totalNumberBump: CGFloat = 8             // Extra size for the number (e.g., "36")
    private let totalHorizontalPadding: CGFloat = 22      // Left/right padding
    private let totalTextSpacing: CGFloat = 6             // Space between text segments

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // DONE BUTTON (bottom button)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    private let doneTop: CGFloat = 150                     // Space above button (from total text)
    private let doneW: CGFloat = 150                      // Button width
    private let doneH: CGFloat = 50                       // Button height
    private let doneFont: CGFloat = 14                    // "Done" text font size
    private let doneCorner: CGFloat = 10                  // Button corner radius
    private let doneBorder: CGFloat = 3                   // Button border thickness
    private let doneTextOpacity: Double = 0.85            // "Done" text transparency

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // COLORS (all colors used in the view)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    private let brown = Color(hex: "8B4513")              // Y-axis line & baseline
    private let brownDark = Color(hex: "6B3A2A")          // Done button border
    private let backBrown = Color(hex: "A0624A")          // Done button background
    private let green = Color(hex: "4CAF50")              // Today's day & total number

    // 🎯 ============================================================
    // END OF ADJUSTABLE POSITIONS
    // 🎯 ============================================================

    var body: some View {
        GeometryReader { geo in
            // Chart height tuned for tall iPhone screens (responsive)
            let chartHeight = min(geo.size.height * chartHeightPercent, chartMaxHeight)

            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {

                    Spacer().frame(height: titleTop)

                    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    // TITLE
                    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    Text("Weekly Focus Progress")
                        .font(.custom("PressStart2P-Regular", size: titleSize))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)

                    Spacer().frame(height: chartTop)

                    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    // CHART (Y-axis + Palms + Baseline + Day labels)
                    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    VStack(spacing: 0) {

                        HStack(alignment: .bottom, spacing: 0) {

                            // Y-AXIS (vertical line + ticks + labels)
                            ZStack(alignment: .trailing) {
                                Rectangle()
                                    .fill(brown)
                                    .frame(width: axisLineWidth, height: chartHeight)
                                    .offset(x: axisLineOffsetX)

                                VStack(alignment: .trailing, spacing: 0) {
                                    ForEach((1...6).reversed(), id: \.self) { h in
                                        HStack(spacing: axisLabelToTickGap) {
                                            Text("\(h)H")
                                                .font(.custom("PressStart2P-Regular", size: axisFont))
                                                .foregroundColor(.black.opacity(axisLabelOpacity))

                                            Rectangle()
                                                .fill(brown)
                                                .frame(width: tickW, height: tickH)
                                        }
                                        .frame(height: chartHeight / 6, alignment: .trailing)
                                    }
                                }
                            }
                            .frame(width: axisWidth)

                            // PALM TREES (7 days)
                            HStack(alignment: .bottom, spacing: palmSpacing) {
                                ForEach(0..<7, id: \.self) { idx in
                                    let hours = hoursForDay(idx)
                                    let bucket = hourBucket(hours)
                                    let img = palmImageName(bucket)
                                    let palmH = palmHeight(bucket, chartHeight: chartHeight)

                                    VStack(spacing: 0) {
                                        Spacer().frame(height: chartHeight - palmH)

                                        Image(img)
                                            .resizable()
                                            .interpolation(.none)
                                            .scaledToFit()
                                            .frame(width: palmWidth, height: palmH)
                                    }
                                    .frame(height: chartHeight)
                                    .offset(y: palmVerticalOffset)  // 🎯 PUSH PALMS DOWN
                                }
                            }
                            .padding(.leading, palmToAxisGap)
                        }
                        .padding(.horizontal, chartSidePadding)

                        // BASELINE (horizontal brown line)
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(brown)
                                .frame(width: axisWidth + baselineYAxisWidth, height: baselineH)

                            Rectangle()
                                .fill(brown)
                                .frame(height: baselineH)
                        }
                        .padding(.horizontal, chartSidePadding)

                        // DAY LABELS (Sun, Mon, Tue, etc.)
                        HStack(spacing: 0) {
                            Spacer().frame(width: axisWidth + chartSidePadding + dayLabelLeftAdjust)

                            HStack(spacing: palmSpacing) {
                                ForEach(0..<7, id: \.self) { idx in
                                    Text(dayName(idx))
                                        .font(.custom("PressStart2P-Regular", size: dayFont))
                                        .foregroundColor(isToday(idx) ? green : .black.opacity(dayNormalOpacity))
                                        .frame(width: palmWidth)
                                }
                            }
                            .padding(.leading, palmToAxisGap)

                            Spacer().frame(width: chartSidePadding)
                        }
                        .padding(.top, dayTopGap)
                    }

                    Spacer().frame(height: totalTop)

                    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    // TOTAL TEXT
                    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    HStack(spacing: totalTextSpacing) {
                        Text("You have accumulated Total of")
                            .font(.custom("PressStart2P-Regular", size: totalFont))
                            .foregroundColor(.black)

                        Text("\(weeklyTotalHours)")
                            .font(.custom("PressStart2P-Regular", size: totalFont + totalNumberBump))
                            .foregroundColor(green)

                        Text("Hours This week!!")
                            .font(.custom("PressStart2P-Regular", size: totalFont))
                            .foregroundColor(.black)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, totalHorizontalPadding)

                    Spacer().frame(height: doneTop)

                    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    // DONE BUTTON
                    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    Button { dismiss() } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: doneCorner)
                                .fill(backBrown)
                                .frame(width: doneW, height: doneH)
                                .overlay(
                                    RoundedRectangle(cornerRadius: doneCorner)
                                        .stroke(brownDark, lineWidth: doneBorder)
                                )

                            Text("Done")
                                .font(.custom("PressStart2P-Regular", size: doneFont))
                                .foregroundColor(.black.opacity(doneTextOpacity))
                        }
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Data Calculation Functions
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private var weeklyTotalHours: Int {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!

        let weekSessions = sessions.filter { $0.sessionDate >= weekStart }
        let totalMinutes = weekSessions.reduce(0) { $0 + $1.minutesStudied }
        return totalMinutes / 60
    }

    /// Returns exact hours (Double) for the dayIndex inside current week (Sun=0 ... Sat=6)
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

    /// Bucket logic: 0,1,2,3,4,5,6 (6 = 6+)
    private func hourBucket(_ hours: Double) -> Int {
        // floor: 1.00 -> 1, 1.99 -> 1, 0.50 -> 0
        let h = Int(floor(hours))
        return min(max(h, 0), 6)
    }

    private func palmImageName(_ bucket: Int) -> String {
        // your assets: palm_0h ... palm_6h
        return "palm_\(bucket)h"
    }

    private func palmHeight(_ bucket: Int, chartHeight: CGFloat) -> CGFloat {
        // Make it look like your mock: 0 is tiny, 6 is tallest
        // Tuned manually for pixel-art feel.
        let maxH = chartHeight * palmMaxHeightPercent

        if bucket == 0 { return palmMinHeight }
        let t = CGFloat(bucket) / 6.0
        return palmMinHeight + (maxH - palmMinHeight) * t
    }

    // MARK: - Days

    private func dayName(_ index: Int) -> String {
        ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"][index]
    }

    private func isToday(_ dayIndex: Int) -> Bool {
        // Calendar weekday: 1=Sun ... 7=Sat
        let today = Calendar.current.component(.weekday, from: Date())
        return (today - 1) == dayIndex
    }
}
