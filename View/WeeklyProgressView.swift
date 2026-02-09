import SwiftUI
import SwiftData

struct WeeklyProgressView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: OnboardingViewModel
    
    @Query private var sessions: [StudySession]
    
    // 🎯 ADJUSTABLE POSITIONS - CHANGE THESE VALUES
    private let backButtonSize: CGFloat = 50
    private let backButtonTopPadding: CGFloat = 20
    private let backButtonLeadingPadding: CGFloat = 20
    
    private let titleTopPadding: CGFloat = 80
    private let titleFontSize: CGFloat = 20
    
    private let chartTopPadding: CGFloat = 40
    private let chartHeight: CGFloat = 400
    private let maxChartHours: CGFloat = 6
    
    private let palmTreeSize: CGFloat = 60
    private let palmTreeBottomOffset: CGFloat = 10
    
    private let totalTextTopPadding: CGFloat = 30
    private let totalNumberColor: String = "4CAF50"
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Back button
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "A0624A"))
                                .frame(width: backButtonSize, height: backButtonSize)
                            
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(hex: "F6E5CB"))
                        }
                    }
                    .padding(.leading, backButtonLeadingPadding)
                    .padding(.top, backButtonTopPadding)
                    
                    Spacer()
                }
                
                Spacer().frame(height: titleTopPadding)
                
                // Title
                Text("Weekly Focus Progress")
                    .font(.custom("PressStart2P-Regular", size: titleFontSize))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                Spacer().frame(height: chartTopPadding)
                
                // Chart
                WeeklyChartView(
                    sessions: sessions,
                    chartHeight: chartHeight,
                    maxHours: maxChartHours,
                    palmTreeSize: palmTreeSize,
                    palmTreeBottomOffset: palmTreeBottomOffset
                )
                .padding(.horizontal, 30)
                
                Spacer().frame(height: totalTextTopPadding)
                
                // Total hours text
                HStack(spacing: 0) {
                    Text("Youve accomulated Total of ")
                        .font(.custom("PressStart2P-Regular", size: 14))
                        .foregroundColor(.black)
                    
                    Text("\(weeklyTotalHours)")
                        .font(.custom("PressStart2P-Regular", size: 14))
                        .foregroundColor(Color(hex: totalNumberColor))
                    
                    Text(" Hours")
                        .font(.custom("PressStart2P-Regular", size: 14))
                        .foregroundColor(.black)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                
                Text("This week!!")
                    .font(.custom("PressStart2P-Regular", size: 14))
                    .foregroundColor(.black)
                    .padding(.top, 5)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var weeklyTotalHours: Int {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        
        let weekSessions = sessions.filter { $0.sessionDate >= weekStart }
        let totalMinutes = weekSessions.reduce(0) { $0 + $1.minutesStudied }
        
        return totalMinutes / 60
    }
}

// MARK: - Weekly Chart View
struct WeeklyChartView: View {
    let sessions: [StudySession]
    let chartHeight: CGFloat
    let maxHours: CGFloat
    let palmTreeSize: CGFloat
    let palmTreeBottomOffset: CGFloat
    
    private let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        GeometryReader { geometry in
            let chartWidth = geometry.size.width
            let barWidth = chartWidth / 10
            
            ZStack(alignment: .bottom) {
                // Y-axis labels
                VStack(alignment: .leading, spacing: 0) {
                    ForEach((1...Int(maxHours)).reversed(), id: \.self) { hour in
                        Text("\(hour)H")
                            .font(.custom("PressStart2P-Regular", size: 10))
                            .foregroundColor(.black.opacity(0.6))
                            .frame(height: chartHeight / maxHours)
                    }
                }
                .frame(width: 40)
                .position(x: 20, y: chartHeight / 2)
                
                // Chart area
                HStack(alignment: .bottom, spacing: barWidth / 2) {
                    ForEach(0..<7) { index in
                        VStack(spacing: palmTreeBottomOffset) {
                            // Bar (brown rectangle) - REMOVED
                            // Now only palm tree shows, no brown bar
                            
                            // Palm tree - 🎯 CHANGES SIZE BASED ON HOURS
                            let hours = hoursForDay(index)
                            let palmImage = getPalmImageForHours(hours)
                            
                            Image(palmImage)
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(width: palmTreeSize, height: palmTreeSize)
                            
                            // Day label
                            Text(days[index])
                                .font(.custom("PressStart2P-Regular", size: 10))
                                .foregroundColor(isToday(index) ? Color(hex: "4CAF50") : .black.opacity(0.6))
                        }
                    }
                }
                .padding(.leading, 60)
                .frame(height: chartHeight)
            }
        }
        .frame(height: chartHeight)
    }
    
    // 🎯 GET PALM TREE IMAGE BASED ON HOURS
    private func getPalmImageForHours(_ hours: Double) -> String {
        switch hours {
        case 0..<1:
            return "palm_0h"      // No palm or very small
        case 1..<2:
            return "palm_1h"      // Small palm
        case 2..<3:
            return "palm_2h"      // Medium palm
        case 3..<4:
            return "palm_3h"      // Larger palm
        case 4..<5:
            return "palm_4h"      // Even larger
        case 5..<6:
            return "palm_5h"      // Almost max
        default:
            return "palm_6h"      // Maximum size (6+ hours)
        }
    }
    
    private func hoursForDay(_ dayIndex: Int) -> Double {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        
        let targetDate = calendar.date(byAdding: .day, value: dayIndex, to: weekStart)!
        let startOfDay = calendar.startOfDay(for: targetDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let daySessions = sessions.filter {
            $0.sessionDate >= startOfDay && $0.sessionDate < endOfDay
        }
        
        let totalMinutes = daySessions.reduce(0) { $0 + $1.minutesStudied }
        return Double(totalMinutes) / 60.0
    }
    
    private func isToday(_ dayIndex: Int) -> Bool {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        return (today - 1) == dayIndex
    }
}