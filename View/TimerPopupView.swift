import SwiftUI

struct TimerPopupView: View {
    @Binding var isPresented: Bool
    @Binding var selectedMinutes: Int
    
    // Timer limits
    private let minMinutes = 5
    private let maxMinutes = 240  // 4 hours = 240 minutes
    private let increment = 5
    
    var body: some View {
        ZStack {
            // Dark overlay background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isPresented = false
                    }
                }
            
            VStack(spacing: 0) {
                // Timer display box
                ZStack {
                    // Background frame (your asset)
                    Image("timer_frame_bg")
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 480, height: 340)
                    
                    VStack(spacing: 20) {
                        // Time display
                        ZStack {
                            // Light beige background
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "F6E5CB"))
                                .frame(width: 380, height: 120)
                            
                            Text(formatTime(selectedMinutes))
                                .font(.custom("PressStart2P-Regular", size: 48))
                                .foregroundColor(Color.borderBrown)
                        }
                        .padding(.top, 40)
                        
                        // Plus and Minus buttons
                        HStack(spacing: 20) {
                            // Plus button
                            Button {
                                if selectedMinutes < maxMinutes {
                                    selectedMinutes += increment
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(hex: "F6E5CB"))
                                        .frame(width: 140, height: 80)
                                    
                                    Image(systemName: "plus")
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(Color.borderBrown)
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(selectedMinutes >= maxMinutes)
                            .opacity(selectedMinutes >= maxMinutes ? 0.5 : 1.0)
                            
                            // Minus button
                            Button {
                                if selectedMinutes > minMinutes {
                                    selectedMinutes -= increment
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(hex: "F6E5CB"))
                                        .frame(width: 140, height: 80)
                                    
                                    Image(systemName: "minus")
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(Color.borderBrown)
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(selectedMinutes <= minMinutes)
                            .opacity(selectedMinutes <= minMinutes ? 0.5 : 1.0)
                        }
                    }
                }
                
                Spacer().frame(height: 40)
                
                // Start button
                Button {
                    // Start timer action
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isPresented = false
                    }
                    // TODO: Start actual timer here
                } label: {
                    ZStack {
                        Image("timer_start_button")
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 200, height: 80)
                        
                        Text("start")
                            .font(.custom("PressStart2P-Regular", size: 18))
                            .foregroundColor(.white)
                            .padding(.top, 4)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // Format minutes to HH:MM
    private func formatTime(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return String(format: "%02d:%02d", hours, mins)
    }
}