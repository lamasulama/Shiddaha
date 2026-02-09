import SwiftUI

struct TimerPopupView: View {
    @Binding var isPresented: Bool
    @Binding var selectedMinutes: Int
    var onTimerStart: (Int) -> Void
    
    private let minMinutes = 5
    private let maxMinutes = 240
    private let increment = 5
    
    private let popupVerticalOffset: CGFloat = -50
    
    private let frameWidth: CGFloat = 520
    private let frameHeight: CGFloat = 340
    
    private let timeBoxWidth: CGFloat = 300
    private let timeBoxHeight: CGFloat = 270
    
    private let timeToButtonSpacing: CGFloat = 130
    
    private let buttonWidth: CGFloat = 60
    private let buttonHeight: CGFloat = 60
    private let buttonSpacing: CGFloat = 90
    
    private let startButtonWidth: CGFloat = 280
    private let startButtonHeight: CGFloat = 90
    private let startButtonTopSpace: CGFloat = 30
    
    private let timerTopPadding: CGFloat = 50  // 🎯 PUSH TIMER DOWN (increase to push more)
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isPresented = false
                    }
                }
            
            VStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "F6E5CB"))
                        .frame(width: timeBoxWidth, height: timeBoxHeight)
                        .zIndex(1)
                    
                    VStack(spacing: timeToButtonSpacing) {
                        Text(formatTime(selectedMinutes))
                            .font(.custom("PressStart2P-Regular", size: 48))
                            .foregroundColor(Color.borderBrown)
                            .padding(.top, timerTopPadding)  // 🎯 TIMER PUSHED DOWN
                        
                        HStack(spacing: buttonSpacing) {
                            Button {
                                if selectedMinutes < maxMinutes {
                                    selectedMinutes += increment
                                }
                            } label: {
                                Image("btn_plus")
                                    .resizable()
                                    .interpolation(.none)
                                    .scaledToFit()
                                    .frame(width: buttonWidth, height: buttonHeight)
                            }
                            .buttonStyle(.plain)
                            .disabled(selectedMinutes >= maxMinutes)
                            .opacity(selectedMinutes >= maxMinutes ? 0.5 : 1.0)
                            
                            Button {
                                if selectedMinutes > minMinutes {
                                    selectedMinutes -= increment
                                }
                            } label: {
                                Image("btn_minus")
                                    .resizable()
                                    .interpolation(.none)
                                    .scaledToFit()
                                    .frame(width: buttonWidth, height: buttonHeight)
                            }
                            .buttonStyle(.plain)
                            .disabled(selectedMinutes <= minMinutes)
                            .opacity(selectedMinutes <= minMinutes ? 0.5 : 1.0)
                        }
                    }
                    .zIndex(2)
                    
                    Image("timer_frame_bg")
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: frameWidth, height: frameHeight)
                        .allowsHitTesting(false)
                        .zIndex(3)
                }
                
                Spacer().frame(height: startButtonTopSpace)
                
                Button {
                    onTimerStart(selectedMinutes)
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isPresented = false
                    }
                } label: {
                    ZStack {
                        Image("timer_start_btn")
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: startButtonWidth, height: startButtonHeight)
                        
                        Text("start")
                            .font(.custom("PressStart2P-Regular", size: 20))
                            .foregroundColor(.white)
                            .padding(.top, 4)
                    }
                }
                .buttonStyle(.plain)
            }
            .offset(y: popupVerticalOffset)
        }
    }
    
    private func formatTime(_ minutes: Int) -> String {
        return String(format: "%02d:00", minutes)
    }
}
