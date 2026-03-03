//
//  FocusSessionView.swift
//  Shiddaha
//
//  📁 Location: View folder
//  🎯 Target Membership: Shiddaha (app target only)

import SwiftUI
import ActivityKit

struct FocusSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: OnboardingViewModel
    
    let selectedMinutes: Int
    var onSessionComplete: (Int) -> Void
    
    @State private var countdown: Int = 5
    @State private var sessionStarted = false
    @State private var timeRemaining: Int = 0
    @State private var timer: Timer?
    @State private var showCancelAlert = false
    @State private var sessionCompleted = false
    @State private var showDateFalling = false
    
    // 🎯 Date Reward System
    private let dateCollectionInterval: Int = 300 // 5 minutes = 300 seconds
    private let standardSessionThreshold: Int = 60 // 60 minutes
    
    // 🎯 Computed properties for session type and rewards
    private var isStandardSession: Bool {
        selectedMinutes >= standardSessionThreshold
    }
    
    private var totalPossibleDates: Int {
        selectedMinutes / (dateCollectionInterval / 60) // dates per session
    }
    
    private var timeElapsed: Int {
        (selectedMinutes * 60) - timeRemaining
    }
    
    private var completionPercentage: Double {
        guard selectedMinutes > 0 else { return 0 }
        return Double(timeElapsed) / Double(selectedMinutes * 60)
    }
    
    private var earnedDates: Int {
        if isStandardSession {
            // Standard session: proportional to completion
            return Int(Double(totalPossibleDates) * completionPercentage)
        } else {
            // Mini session: all or nothing
            return sessionCompleted ? totalPossibleDates : 0
        }
    }
    
    // 🎯 ADJUSTABLE POSITIONS - CHANGE THESE VALUES
    private let titleTopPadding: CGFloat = 80
    private let titleToTimerSpacing: CGFloat = 20
    private let timerToCharacterSpacing: CGFloat = 100
    private let characterWidth: CGFloat = 100
    private let characterHeight: CGFloat = 130
    private let characterOffsetX: CGFloat = -90
    private let characterOffsetY: CGFloat = 80
    private let treeWidth: CGFloat = 200
    private let treeHeight: CGFloat = 280
    private let characterToTextSpacing: CGFloat = 40
    private let buttonBottomPadding: CGFloat = 60
    private let buttonWidth: CGFloat = 280
    private let buttonHeight: CGFloat = 70
    
    // 🎯 BUCKET POSITIONING
    private let bucketWidth: CGFloat = 45
    private let bucketHeight: CGFloat = 45
    private let bucketOffsetX: CGFloat = -35 // Position in front of character
    private let bucketOffsetY: CGFloat = 120 // Position at ground level
    
    // 🎯 ALERT SIZING
    private let alertWidth: CGFloat = 320
    private let alertHeight: CGFloat = 240
    
    // 🎯 Get sitting character based on selected character
    private var sittingCharacterImage: String {
        if vm.selectedCharacter?.imageName == "char_girl" {
            return "sitting_girl"
        } else {
            return "sitting_boy"
        }
    }
    
    // 🎯 Get bucket image based on session progress
    private var bucketImage: String {
        if !sessionStarted {
            return "bucket_empty"
        }
        
        let progress = completionPercentage
        
        if progress < 0.5 {
            return "bucket_empty"
        } else if progress < 0.75 {
            return "bucket_half"
        } else {
            return "bucket_full"
        }
    }
    
    var body: some View {
        ZStack {
            Color(hex: "786C59").ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                Spacer().frame(height: titleTopPadding)
                
                // Title
                Text(sessionStarted ? "time left" : "get ready!")
                    .font(.custom("PressStart2P-Regular", size: 20))
                    .foregroundColor(.black)
                
                Spacer().frame(height: titleToTimerSpacing)
                
                // Timer Display
                Text(sessionStarted ? formatTime(timeRemaining) : formatTime(selectedMinutes * 60))
                    .font(.custom("PressStart2P-Regular", size: 64))
                    .foregroundColor(.black)
                
                Spacer().frame(height: timerToCharacterSpacing)
                
                // Character with date tree
                ZStack {
                    // Date tree
                    Image("date_tree")
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: treeWidth, height: treeHeight)
                    
                    // Sitting character
                    Image(sittingCharacterImage)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: characterWidth, height: characterHeight)
                        .offset(x: characterOffsetX, y: characterOffsetY)
                    
                    // 🎯 Bucket (shows progress) - visible always (during countdown and session)
                    Image(bucketImage)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: bucketWidth, height: bucketHeight)
                        .offset(x: bucketOffsetX, y: bucketOffsetY)
                    
                    // Falling date animation
                    if showDateFalling {
                        DateFallingToHandView(
                            characterOffsetX: characterOffsetX,
                            characterOffsetY: characterOffsetY
                        )
                    }
                }
                .frame(height: 350)
                
                Spacer().frame(height: characterToTextSpacing)
                
                // Motivational text
                Text(sessionStarted ? getMotivationalText() : "starting soon...")
                    .font(.custom("PressStart2P-Regular", size: 16))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 20)
                
                Spacer()
                
                // Cancel / Stop button
                Button {
                    if sessionStarted {
                        showCancelAlert = true
                    } else {
                        cancelSession()
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "A0624A"))
                            .frame(width: buttonWidth, height: buttonHeight)
                        
                        Text(sessionStarted ? "stop focus" : "cancel (\(countdown))")
                            .font(.custom("PressStart2P-Regular", size: 16))
                            .foregroundColor(Color(hex: "F6E5CB"))
                    }
                }
                .buttonStyle(.plain)
                
                Spacer().frame(height: buttonBottomPadding)
            }
            
            // 🎯 CUSTOM STOP ALERT
            if showCancelAlert {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                CustomStopAlert(
                    onKeepGoing: {
                        withAnimation {
                            showCancelAlert = false
                        }
                    },
                    onStop: {
                        cancelSession()
                    },
                    earnedDates: earnedDates,
                    isStandardSession: isStandardSession,
                    alertWidth: alertWidth,
                    alertHeight: alertHeight
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            startInitialCountdown()
            
            // Request notification permission
            FocusSessionActivityManager.shared.requestNotificationPermission()
        }
        .onDisappear {
            timer?.invalidate()
            
            // End Live Activity if view disappears
            if FocusSessionActivityManager.shared.isActivityRunning {
                FocusSessionActivityManager.shared.endActivity(showCompletionMessage: false)
            }
        }
    }
    
    // MARK: - Timer Functions
    
    private func startInitialCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer?.invalidate()
                startSession()
            }
        }
    }
    
    private func startSession() {
        sessionStarted = true
        timeRemaining = selectedMinutes * 60
        showDateFalling = true // Start the falling date animation
        
        // Start Live Activity
        FocusSessionActivityManager.shared.startActivity(
            totalMinutes: selectedMinutes,
            isStandardSession: isStandardSession,
            characterImageName: vm.selectedCharacter?.imageName ?? "char_boy"
        )
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                
                // Update Live Activity every second
                FocusSessionActivityManager.shared.updateActivity(timeRemaining: timeRemaining)
            } else {
                completeSession()
            }
        }
    }
    
    private func completeSession() {
        timer?.invalidate()
        sessionCompleted = true
        
        // End Live Activity with completion
        FocusSessionActivityManager.shared.endActivity(showCompletionMessage: true)
        
        // Send completion notification
        FocusSessionActivityManager.shared.sendCompletionNotification(
            earnedDates: earnedDates,
            sessionMinutes: selectedMinutes
        )
        
        // Call the completion handler with earned dates
        onSessionComplete(earnedDates)
        
        // Small delay before dismissing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            dismiss()
        }
    }
    
    private func cancelSession() {
        timer?.invalidate()
        
        // End Live Activity when cancelled
        FocusSessionActivityManager.shared.endActivity(showCompletionMessage: false)
        
        // Pass earned dates even when stopping early
        onSessionComplete(earnedDates)
        
        dismiss()
    }
    
    // MARK: - Helper Functions
    
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    private func getMotivationalText() -> String {
        let progress = Int(completionPercentage * 100)
        
        if isStandardSession {
            // Standard session: show progress-based motivation
            if progress < 25 {
                return "stay focused!"
            } else if progress < 50 {
                return "you're doing great!"
            } else if progress < 75 {
                return "halfway there!"
            } else {
                return "almost done!"
            }
        } else {
            // Mini session: emphasize completion requirement
            if progress < 25 {
                return "stay focused!"
            } else if progress < 50 {
                return "keep going!"
            } else if progress < 75 {
                return "halfway there!"
            } else if progress < 100 {
                return "finish to earn dates!"
            } else {
                return "great job!"
            }
        }
    }
}

// MARK: - Custom Stop Alert
struct CustomStopAlert: View {
    let onKeepGoing: () -> Void
    let onStop: () -> Void
    let earnedDates: Int
    let isStandardSession: Bool
    let alertWidth: CGFloat
    let alertHeight: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "F6E5CB"))
                .frame(width: alertWidth, height: alertHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "8B4513"), lineWidth: 6)
                )
            
            VStack(spacing: 20) {
                Text("STOP FOCUS\nSESSION?")
                    .font(.custom("PressStart2P-Regular", size: 18))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                // Dynamic message based on session type and earned dates
                if isStandardSession {
                    // Standard session: show earned dates
                    if earnedDates > 0 {
                        VStack(spacing: 8) {
                            HStack(spacing: 5) {
                                Image("dates_icon")
                                    .resizable()
                                    .interpolation(.none)
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                
                                Text("You'll earn \(earnedDates) date\(earnedDates == 1 ? "" : "s")")
                                    .font(.custom("PressStart2P-Regular", size: 11))
                                    .foregroundColor(Color(hex: "4CAF50"))
                            }
                        }
                    } else {
                        Text("Keep going to earn\nmore dates!")
                            .font(.custom("PressStart2P-Regular", size: 12))
                            .foregroundColor(.black.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                    }
                } else {
                    // Mini session: all or nothing
                    Text("You won't earn any\ndates if you stop now.")
                        .font(.custom("PressStart2P-Regular", size: 12))
                        .foregroundColor(.black.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                }
                
                HStack(spacing: 15) {
                    Button(action: onKeepGoing) {
                        Text("KEEP GOING")
                            .font(.custom("PressStart2P-Regular", size: 11))
                            .foregroundColor(.white)
                            .frame(width: 130, height: 50)
                            .background(Color(hex: "4CAF50"))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: "2D5A2D"), lineWidth: 3)
                            )
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: onStop) {
                        Text("STOP")
                            .font(.custom("PressStart2P-Regular", size: 11))
                            .foregroundColor(.white)
                            .frame(width: 130, height: 50)
                            .background(Color(hex: "D32F2F"))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: "8B0000"), lineWidth: 3)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(width: alertWidth, height: alertHeight)
        }
    }
}

// MARK: - Date Falling to Character's Hand (During Timer)
struct DateFallingToHandView: View {
    let characterOffsetX: CGFloat
    let characterOffsetY: CGFloat
    
    @State private var dateY: CGFloat = -80
    @State private var dateOpacity: Double = 1.0
    @State private var animationTimer: Timer?
    
    // 🎯 ADJUSTABLE DATE FALLING POSITIONS - CHANGE THESE VALUES
    private let dateStartY: CGFloat = 170         // Where date starts (top of screen)
    private let dateEndY: CGFloat = 280          // Where date ends (character's hand)
    private let dateOffsetX: CGFloat = 60// Horizontal offset from character center
    private let dateSize: CGFloat = 27             // Size of falling date image
    private let fallDuration: Double = 1.5          // How long it takes to fall (seconds)
    private let repeatInterval: Double = 2.0        // How often date falls (seconds)
    
    var body: some View {
        GeometryReader { geometry in
            Image("date_falling")
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: dateSize, height: dateSize)
                .position(
                    x: (geometry.size.width / 2) + characterOffsetX + dateOffsetX,
                    y: dateY
                )
                .opacity(dateOpacity)
                .onAppear {
                    startAnimation()
                }
                .onDisappear {
                    animationTimer?.invalidate()
                }
        }
    }
    
    private func startAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: repeatInterval, repeats: true) { _ in
            dateY = dateStartY
            dateOpacity = 1.0
            
            withAnimation(.easeIn(duration: fallDuration)) {
                dateY = dateEndY
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (fallDuration - 0.2)) {
                withAnimation(.easeOut(duration: 0.2)) {
                    dateOpacity = 0.0
                }
            }
        }
        
        animationTimer?.fire()
    }
}
