import SwiftUI

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
    @State private var showFallingDates = false
    @State private var showDateFalling = false
    
    // 🎯 ADJUSTABLE POSITIONS - CHANGE THESE VALUES
    private let titleTopPadding: CGFloat = 80
    private let titleToTimerSpacing: CGFloat = 20
    private let timerToCharacterSpacing: CGFloat = 100
    private let characterWidth: CGFloat = 100
    private let characterHeight: CGFloat = 130
    private let characterOffsetX: CGFloat = -80
    private let characterOffsetY: CGFloat = 80
    private let treeWidth: CGFloat = 200
    private let treeHeight: CGFloat = 280
    private let characterToTextSpacing: CGFloat = 40
    private let buttonBottomPadding: CGFloat = 60
    private let buttonWidth: CGFloat = 280
    private let buttonHeight: CGFloat = 70
    
    // 🎯 Get sitting character based on selected character
    private var sittingCharacterImage: String {
        if vm.selectedCharacter?.imageName == "char_girl" {
            return "sitting_girl"
        } else {
            return "sitting_boy"
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
                    
                    // Falling date animation (during timer)
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
                Text(sessionStarted ? "mind your buisness!" : "starting soon...")
                    .font(.custom("PressStart2P-Regular", size: 16))
                    .foregroundColor(.black)
                
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
            
            // Falling dates animation overlay (at completion)
            if showFallingDates {
                FallingDatesView()
                    .ignoresSafeArea()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            startInitialCountdown()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .alert("Stop Focus Session?", isPresented: $showCancelAlert) {
            Button("Keep Going", role: .cancel) { }
            Button("Stop", role: .destructive) {
                cancelSession()
            }
        } message: {
            Text("You won't earn any dates if you stop now.")
        }
    }
    
    // MARK: - Initial 5 second countdown
    private func startInitialCountdown() {
        countdown = 5
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if countdown > 1 {
                countdown -= 1
            } else {
                timer?.invalidate()
                startFocusSession()
            }
        }
    }
    
    // MARK: - Start actual focus session
    private func startFocusSession() {
        sessionStarted = true
        timeRemaining = selectedMinutes * 60
        showDateFalling = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                completeSession()
            }
        }
    }
    
    // MARK: - Complete session successfully
    private func completeSession() {
        timer?.invalidate()
        sessionCompleted = true
        showDateFalling = false
        
        onSessionComplete(selectedMinutes)
        
        withAnimation {
            showFallingDates = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            dismiss()
        }
    }
    
    // MARK: - Cancel session (no dates)
    private func cancelSession() {
        timer?.invalidate()
        dismiss()
    }
    
    // MARK: - Format time as MM:SS
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
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
    private let dateEndY: CGFloat = 300          // Where date ends (character's hand)
    private let dateOffsetX: CGFloat = 50           // Horizontal offset from character center
    private let dateSize: CGFloat = 30              // Size of falling date image
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

// MARK: - Falling Dates Animation (At Completion)
struct FallingDatesView: View {
    @State private var dates: [FallingDate] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(dates) { date in
                    Image("dates_icon")
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .position(x: date.x, y: date.y)
                        .opacity(date.opacity)
                }
            }
            .onAppear {
                startFallingDates(screenHeight: geometry.size.height, screenWidth: geometry.size.width)
            }
        }
    }
    
    private func startFallingDates(screenHeight: CGFloat, screenWidth: CGFloat) {
        for i in 0..<20 {
            let delay = Double(i) * 0.1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let newDate = FallingDate(
                    x: CGFloat.random(in: 50...(screenWidth - 50)),
                    y: -50,
                    opacity: 1.0
                )
                dates.append(newDate)
                
                withAnimation(.easeIn(duration: 2.0)) {
                    if let index = dates.firstIndex(where: { $0.id == newDate.id }) {
                        dates[index].y = screenHeight + 50
                        dates[index].opacity = 0.0
                    }
                }
            }
        }
    }
}

struct FallingDate: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var opacity: Double
}
