//
//  WeeklyProgressView.swift
//  Shiddaha
//
//  Created by lama bin slmah on 09/02/2026.
//

import SwiftUI
import SwiftData

struct WeeklyProgressView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: OnboardingViewModel
    
    @Query private var sessions: [StudySession]
    
    // 🎯 ADJUSTABLE POSITIONS - CHANGE THESE VALUES
    
    // Back button
    private let backButtonSize: CGFloat = 50
    private let backButtonTopPadding: CGFloat = 60
    private let backButtonLeadingPadding: CGFloat = 20
    
    // Title
    private let titleTopPadding: CGFloat = 80
    private let titleFontSize: CGFloat = 20
    
    // Chart area
    private let chartTopPadding: CGFloat = 40
    private let chartHeight: CGFloat = 400
    private let chartHorizontalPadding: CGFloat = 20
    private let maxChartHours: CGFloat = 6
    
    // Y-axis
    private let yAxisWidth: CGFloat = 40
    private let yAxisToChartSpacing: CGFloat = 10
    private let yAxisFontSize: CGFloat = 10
    
    // Palm trees
    private let palmTreeSize: CGFloat = 60
    private let palmTreeSpacing: CGFloat = 12
    private let dayLabelFontSize: CGFloat = 10
    private let dayLabelTopSpacing: CGFloat = 5
    
    // Total text
    private let totalTextTopPadding: CGFloat = 30
    private let totalTextFontSize: CGFloat = 14
    private let totalNumberColor: String = "4CAF50"
    private let weekTextTopSpacing: CGFloat = 5
    
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
                HStack(spacing: 0) {
                    // Y-axis
                    VStack(alignment: .trailing, spacing: 0) {
                        ForEach((1...Int(maxChartHours)).reversed(), id: \.self) { hour in
                            Text("\(hour)H")
                                .font(.custom("PressStart2P-Regular", size: yAxisFontSize))
                                .foregroundColor(.black.opacity(0.6))
                                .frame(height: chartHeight / maxChartHours, alignment: .trailing)
                        }
                    }
                    .frame(width: yAxisWidth)
                    .padding(.trailing, yAxisToChartSpacing)
                    
                    // Palm trees
                    HStack(alignment: .bottom, spacing: palmTreeSpacing) {
                        ForEach(0..<7) { index in
                            VStack(spacing: dayLabelTopSpacing) {
                                let hours = hoursForDay(index)
                                let palmImage = getPalmImageForHours(hours)
                                
                                Image(palmImage)
                                    .resizable()
                                    .interpolation(.none)
                                    .scaledToFit()
                                    .frame(width: palmTreeSize, height: palmTreeSize)
                                
                                Text(getDayName(index))
                                    .font(.custom("PressStart2P-Regular", size: dayLabelFontSize))
                                    .foregroundColor(isToday(index) ? Color(hex: "4CAF50") : .black.opacity(0.6))
                            }
                        }
                    }
                }
                .frame(height: chartHeight + 40)
                .padding(.horizontal, chartHorizontalPadding)
                
                Spacer().frame(height: totalTextTopPadding)
                
                // Total hours text
                HStack(spacing: 0) {
                    Text("Youve accomulated Total of ")
                        .font(.custom("PressStart2P-Regular", size: totalTextFontSize))
                        .foregroundColor(.black)
                    
                    Text("\(weeklyTotalHours)")
                        .font(.custom("PressStart2P-Regular", size: totalTextFontSize))
                        .foregroundColor(Color(hex: totalNumberColor))
                    
                    Text(" Hours")
                        .font(.custom("PressStart2P-Regular", size: totalTextFontSize))
                        .foregroundColor(.black)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                
                Text("This week!!")
                    .font(.custom("PressStart2P-Regular", size: totalTextFontSize))
                    .foregroundColor(.black)
                    .padding(.top, weekTextTopSpacing)
                
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
    
    private func getDayName(_ index: Int) -> String {
        let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return days[index]
    }
    
    private func getPalmImageForHours(_ hours: Double) -> String {
        switch hours {
        case 0..<1:
            return "palm_0h"
        case 1..<2:
            return "palm_1h"
        case 2..<3:
            return "palm_2h"
        case 3..<4:
            return "palm_3h"
        case 4..<5:
            return "palm_4h"
        case 5..<6:
            return "palm_5h"
        default:
            return "palm_6h"
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
