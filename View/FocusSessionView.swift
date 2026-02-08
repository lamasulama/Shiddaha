import SwiftUI

struct FocusSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: OnboardingViewModel
    
    let selectedMinutes: Int
    var onSessionComplete: (Int) -> Void
    
    @State private var countdown: Int = 5  // 5 second countdown before starting
    @State private var sessionStarted = false
    @State private var timeRemaining: Int = 0  // In seconds
    @State private var timer: Timer?
    @State private var showCancelAlert = false
    @State private var sessionCompleted = false
    @State private var showFallingDates = false
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer().frame(height: 60)
                
                // Title
                Text(sessionStarted ? "time left" : "get ready!")
                    .font(.custom("PressStart2P-Regular", size: 20))
                    .foregroundColor(.black)
                
                // Timer Display
                Text(sessionStarted ? formatTime(timeRemaining) : "00:\(String(format: "%02d", countdown))")
                    .font(.custom("PressStart2P-Regular", size: 64))
                    .foregroundColor(.black)
                    .padding(.vertical, 40)
                
                // Character with date tree
                ZStack {
                    // Date tree
                    Image("date_tree")
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 200, height: 280)
                    
                    // Character
                    if let imageName = vm.selectedCharacter?.imageName {
                        Image(imageName)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 100, height: 130)
                            .offset(x: -50, y: 60)
                    }
                }
                
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
                            .frame(width: 280, height: 70)
                        
                        Text(sessionStarted ? "stop focus" : "cancel")
                            .font(.custom("PressStart2P-Regular", size: 16))
                            .foregroundColor(Color(hex: "F6E5CB"))
                    }
                }
                .buttonStyle(.plain)
                .padding(.bottom, 40)
            }
            
            // Falling dates animation overlay
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
        timeRemaining = selectedMinutes * 60  // Convert minutes to seconds
        
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
        
        // Award dates
        onSessionComplete(selectedMinutes)
        
        // Show falling dates animation
        withAnimation {
            showFallingDates = true
        }
        
        // Dismiss after animation
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

// MARK: - Falling Dates Animation
struct FallingDatesView: View {
    @State private var dates: [FallingDate] = []
    
    var body: some View {
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
            startFallingDates()
        }
    }
    
    private func startFallingDates() {
        // Create 20 falling dates
        for i in 0..<20 {
            let delay = Double(i) * 0.1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let newDate = FallingDate(
                    x: CGFloat.random(in: 50...350),
                    y: -50,
                    opacity: 1.0
                )
                dates.append(newDate)
                
                // Animate falling
                withAnimation(.easeIn(duration: 2.0)) {
                    if let index = dates.firstIndex(where: { $0.id == newDate.id }) {
                        dates[index].y = UIScreen.main.bounds.height + 50
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