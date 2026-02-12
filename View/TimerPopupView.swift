import SwiftUI

struct TimerPopupView: View {
    @Binding var isPresented: Bool
    @Binding var selectedMinutes: Int
    var onTimerStart: (Int) -> Void
    
    private let minMinutes = 5
    private let maxMinutes = 240
    private let increment = 5
    
    // Alert sizing
    private let alertWidth: CGFloat = 380
    private let alertHeight: CGFloat = 350
    
    private let timeBoxWidth: CGFloat = 320
    private let timeBoxHeight: CGFloat = 90
    private let timeBoxTopPadding: CGFloat = 30
    
    private let sliderWidth: CGFloat = 320
    private let sliderToStartSpacing: CGFloat = 1
    
    private let startButtonWidth: CGFloat = 280
    private let startButtonHeight: CGFloat = 70
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isPresented = false
                    }
                }
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "F6E5CB"))
                    .frame(width: alertWidth, height: alertHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: "8B4513"), lineWidth: 6)
                    )
                
                VStack(spacing: 25) {
                    // Timer display
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "E8D5B7"))
                            .frame(width: timeBoxWidth, height: timeBoxHeight)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "8B4513"), lineWidth: 3)
                            )
                        
                        Text(formatTime(selectedMinutes))
                            .font(.custom("PressStart2P-Regular", size: 40))
                            .foregroundColor(Color(hex: "8B4513"))
                    }
                    .padding(.top, timeBoxTopPadding)
                    
                    // Slider
                    VStack(spacing: 10) {
                        Slider(
                            value: Binding(
                                get: { Double(selectedMinutes) },
                                set: { selectedMinutes = Int($0 / Double(increment)) * increment }
                            ),
                            in: Double(minMinutes)...Double(maxMinutes),
                            step: Double(increment)
                        )
                        .frame(width: sliderWidth)
                        .accentColor(Color(hex: "8B4513"))
                        .tint(Color(hex: "8B4513"))
                        
                        HStack {
                            Text("5 min")
                                .font(.custom("PressStart2P-Regular", size: 8))
                                .foregroundColor(Color(hex: "8B4513").opacity(0.7))
                            
                            Spacer()
                            
                            Text("4 hrs")
                                .font(.custom("PressStart2P-Regular", size: 8))
                                .foregroundColor(Color(hex: "8B4513").opacity(0.7))
                        }
                        .frame(width: sliderWidth)
                    }
                    
                    Spacer().frame(height: sliderToStartSpacing)
                    
                    // Start button
                    Button {
                        onTimerStart(selectedMinutes)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isPresented = false
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "A0624A"))
                                .frame(width: startButtonWidth, height: startButtonHeight)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "6B3A2A"), lineWidth: 4)
                                )
                            
                            Text("start")
                                .font(.custom("PressStart2P-Regular", size: 18))
                                .foregroundColor(.white)
                                .padding(.top, 4)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .frame(width: alertWidth, height: alertHeight)
            }
        }
    }
    
    private func formatTime(_ minutes: Int) -> String {
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return String(format: "%d:00:00", hours)
            } else {
                return String(format: "%d:%02d:00", hours, mins)
            }
        } else {
            return String(format: "%02d:00", minutes)
        }
    }
}
