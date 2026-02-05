import SwiftUI

struct ContentView: View {

    @StateObject private var vm = OnboardingViewModel()
    @FocusState private var nameFocused: Bool
    @State private var goToMainPage = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if vm.isNaming {
                namingScreen
            } else {
                chooseCharacterScreen
            }
        }
        .navigationDestination(isPresented: $goToMainPage) {
            MainPageView(vm: vm)
        }
    }

    // MARK: - Choose Character Screen
    private var chooseCharacterScreen: some View {
        VStack(spacing: 34) {

            Spacer().frame(height: 100)

            Text("choose your\ncharacter")
                .font(.custom("PressStart2P-Regular", size: 22))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            HStack(spacing: 40) {
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
                            .frame(width: 170, height: 190)
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()
        }
    }

    // MARK: - Naming Screen
    private var namingScreen: some View {
        VStack(spacing: 20) {

            Spacer().frame(height: 60)

            if let imageName = vm.selectedCharacter?.imageName {
                Image(imageName)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 240, height: 340)
            }

            VStack(spacing: 12) {

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
                }
                .frame(width: 240)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color.borderBrown, lineWidth: 2)
                )

                Button {
                    vm.save()
                    goToMainPage = true
                } label: {
                    Text("save")
                        .font(.custom("PressStart2P-Regular", size: 14))
                        .foregroundColor(Color(hex: "#FFF7E0"))
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
    }
}

