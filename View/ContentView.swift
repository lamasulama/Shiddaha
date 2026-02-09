import SwiftUI
import SwiftData

struct ContentView: View {

    @StateObject private var vm = OnboardingViewModel()
    @FocusState private var nameFocused: Bool
    
    @Environment(\.modelContext) private var modelContext

    private var screenTransition: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.95).combined(with: .opacity),
            removal: .opacity
        )
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ZStack {
                switch vm.screen {
                case .choose:
                    chooseCharacterScreen
                        .transition(screenTransition)

                case .naming:
                    namingScreen
                        .transition(screenTransition)

                case .main:
                    MainPageView(vm: vm)
                        .transition(screenTransition)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: vm.screen)
            
            // 🎯 DEBUG RESET BUTTON - Only shows during development
            #if DEBUG
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button("🔄 DEV RESET") {
                        vm.resetAllData()
                    }
                    .font(.caption)
                    .padding(8)
                    .background(Color.red.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding()
                }
            }
            #endif
        }
        .onAppear {
            vm.loadUserData(context: modelContext)
        }
    }

    // MARK: - Choose Character Screen
    private var chooseCharacterScreen: some View {
        VStack(spacing: 24) {

            Spacer().frame(height: 170)

            Text("choose your\ncharacter")
                .font(.custom("PressStart2P-Regular", size: 22))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            HStack(spacing: 45) {
                ForEach(vm.characters) { character in
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            vm.select(character)
                        }
                    } label: {
                        Image(character.imageName)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 150, height: 190)
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()
        }
    }

    // MARK: - Naming Screen
    private var namingScreen: some View {
        VStack(spacing: 50) {

            Spacer().frame(height: 60)

            if let imageName = vm.selectedCharacter?.imageName {
                Image(imageName)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 220, height: 320)
                    .transition(.scale)
            }

            VStack(spacing: 30) {

                ZStack(alignment: .leading) {
                    if vm.characterName.isEmpty {
                        Text("name your character")
                            .font(.custom("PressStart2P-Regular", size: 10))
                            .foregroundColor(.black.opacity(0.4))
                            .padding(.leading, 12)
                    }

                    TextField("", text: $vm.characterName)
                        .font(.custom("PressStart2P-Regular", size: 14))
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .focused($nameFocused)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                }
                .frame(width: 240)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color.borderBrown, lineWidth: 2)
                )

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        vm.save()
                    }
                } label: {
                    Text("save")
                        .font(.custom("PressStart2P-Regular", size: 14))
                        .foregroundColor(Color(hex: "F6E5CB"))
                        .frame(width: 130, height: 32)
                        .background(
                            Image("save_background")
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                        )
                }
                .opacity(vm.canSave ? 1 : 0.4)
                .disabled(!vm.canSave)
            }

            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                nameFocused = true
            }
        }
    }
}
