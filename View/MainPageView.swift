import SwiftUI

struct MainPageView: View {

    @ObservedObject var vm: OnboardingViewModel
    @State private var showMenu = false
    @State private var showTimerPopup = false
    @State private var selectedMinutes = 20
    @State private var showFocusSession = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {

                    // TOP BAR
                    HStack(alignment: .center) {

                        // Dates counter
                        HStack(spacing: 30) {
                            Image("dates_icon")
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(width: 24, height: 24)

                            Text("\(vm.datesCount)")
                                .font(.custom("PressStart2P-Regular", size: 16))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Image("score_box_bg")
                                .resizable()
                                .interpolation(.none)
                                .scaledToFill()
                        )

                        Spacer()

                        // Menu button (3 lines)
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showMenu.toggle()
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color.borderBrown)
                                .frame(width: 44, height: 44)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .overlay(alignment: .topTrailing) {
                        if showMenu {
                            MenuPopupView(showMenu: $showMenu, vm: vm)
                                .transition(.scale(scale: 0.8, anchor: .topTrailing).combined(with: .opacity))
                        }
                    }

                    Spacer()

                    // Character + Tent
                    if let imageName = vm.selectedCharacter?.imageName {
                        TentCharacterIntroView(
                            characterImageName: imageName,
                            characterName: (vm.characterName.isEmpty ? "player" : vm.characterName)
                        )
                    }

                    Spacer()

                    // Start button at bottom
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showTimerPopup = true
                        }
                    } label: {
                        ZStack {
                            Image("start_button_bg")
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()

                            Text("get to work")
                                .font(.custom("PressStart2P-Regular", size: 12))
                                .foregroundColor(.white)
                                .padding(.top, 2)
                        }
                        .frame(width: 380, height: 90)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 40)
                }
            }
            .overlay {
                if showTimerPopup {
                    TimerPopupView(
                        isPresented: $showTimerPopup,
                        selectedMinutes: $selectedMinutes,
                        onTimerStart: { minutes in
                            showTimerPopup = false
                            showFocusSession = true
                        }
                    )
                    .transition(.opacity)
                }
            }
            .navigationDestination(isPresented: $showFocusSession) {
                FocusSessionView(
                    vm: vm,
                    selectedMinutes: selectedMinutes,
                    onSessionComplete: { minutes in
                        vm.addDates(minutes)
                    }
                )
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

// MARK: - Menu Popup
struct MenuPopupView: View {
    @Binding var showMenu: Bool
    @ObservedObject var vm: OnboardingViewModel
    
    private let topRowSpacing: CGFloat = 5
    private let verticalSpacing: CGFloat = 0
    private let offsetFromRight: CGFloat = 60
    private let offsetFromTop: CGFloat = 10

    var body: some View {
        VStack(spacing: verticalSpacing) {
            HStack(spacing: topRowSpacing) {
                NavigationLink {
                    WeeklyProgressView(vm: vm)
                } label: {
                    Image("btn_clock")
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 52, height: 52)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    showMenu = false
                })

                NavigationLink {
                    ShopView()
                } label: {
                    Image("btn_shop")
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    showMenu = false
                })
            }

            NavigationLink {
                SettingsView()
            } label: {
                Image("btn_settings")
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            }
            .simultaneousGesture(TapGesture().onEnded {
                showMenu = false
            })
        }
        .padding(.top, offsetFromTop)
        .padding(.trailing, offsetFromRight)
    }
}

// MARK: - Tent Character Intro
struct TentCharacterIntroView: View {
    let characterImageName: String
    let characterName: String

    @State private var characterScale: CGFloat = 0.6
    @State private var characterOpacity: Double = 0.3
    @State private var showBlink = false
    @State private var showBubble = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("tent")
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 400, height: 400)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .zIndex(1)

                VStack(spacing: 8) {
                    ZStack {
                        Image(characterImageName)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 140, height: 170)
                            .scaleEffect(characterScale)
                            .opacity(characterOpacity)

                        if showBlink {
                            BlinkOverlay()
                                .offset(y: -18)
                                .scaleEffect(characterScale)
                        }
                    }

                    Text(characterName)
                        .font(.custom("PressStart2P-Regular", size: 16))
                        .foregroundColor(.black)
                        .opacity(characterOpacity)
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2 + 80)
                .zIndex(2)

                if showBubble {
                    PixelBubble(text: "are you ready to get\nsome dates?")
                        .position(x: geometry.size.width / 2, y: (geometry.size.height / 2) - 50)
                        .zIndex(3)
                }
            }
        }
        .frame(height: 500)
        .onAppear {
            runIntro()
        }
    }

    private func runIntro() {
        characterScale = 0.6
        characterOpacity = 0.3
        showBlink = false
        showBubble = false

        withAnimation(.easeOut(duration: 2.0)) {
            characterScale = 1.0
            characterOpacity = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            blinkTwice()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showBubble = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showBubble = false
                }
            }
        }
    }

    private func blinkTwice() {
        withAnimation(.easeInOut(duration: 0.08)) { showBlink = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.easeInOut(duration: 0.08)) { showBlink = false }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.easeInOut(duration: 0.08)) { showBlink = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                withAnimation(.easeInOut(duration: 0.08)) { showBlink = false }
            }
        }
    }
}

struct BlinkOverlay: View {
    var body: some View {
        HStack(spacing: 16) {
            Rectangle().frame(width: 13, height: 3)
            Rectangle().frame(width: 13, height: 3)
        }
        .foregroundColor(.black.opacity(0.9))
    }
}

struct PixelBubble: View {
    let text: String

    var body: some View {
        VStack(spacing: 0) {
            Text(text)
                .font(.custom("PressStart2P-Regular", size: 10))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white)
                .overlay(
                    Rectangle()
                        .stroke(Color.borderBrown, lineWidth: 2)
                )

            Rectangle()
                .fill(Color.white)
                .frame(width: 10, height: 10)
                .rotationEffect(.degrees(45))
                .overlay(
                    Rectangle()
                        .stroke(Color.borderBrown, lineWidth: 2)
                        .rotationEffect(.degrees(45))
                        .frame(width: 12, height: 12)
                )
                .offset(y: -5)
        }
        .frame(width: 260)
    }
}
