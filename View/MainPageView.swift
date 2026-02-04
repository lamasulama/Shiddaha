import SwiftUI

struct MainPageView: View {

    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {

                // TOP BAR
                HStack(alignment: .center) {

                    // SCORE BOX
                    HStack(spacing: 30) {
                        Image("dates_icon")
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 24, height: 24)

                        Text("\(vm.datesCount)")
                            .font(.custom("PressStart2P-Regular", size: 18))
                            .foregroundColor(.black)
                            .padding(.top, 2)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        Image("score_box_bg")
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                    )

                    Spacer()

                    Button {
                        // later: open menu
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color.borderBrown)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)

                Spacer().frame(height: 80)

                // TENT + CHARACTER OVERLAY
                ZStack {
                    // TENT
                    Image("tent")
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 390)

                    // CHARACTER + NAME (IN FRONT)
                    VStack(spacing: 5) {
                        if let imageName = vm.selectedCharacter?.imageName {
                            Image(imageName)
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(width: 130, height: 170)
                        }

                        Text(vm.characterName.isEmpty ? "player" : vm.characterName.lowercased())
                            .font(.custom("PressStart2P-Regular", size: 18))
                            .foregroundColor(.black)
                    }
                    // يتحكم بمكان الولد قدام باب الخيمة
                    .offset(y: 185)
                }
                .padding(.top, 6)

                Spacer().frame(height: 200)

                // START BUTTON
                Button {
                    // start working
                } label: {
                    ZStack {
                        Image("start_button_bg")
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()

                        Text("get to work")
                            .font(.custom("PressStart2P-Regular", size: 16))
                            .foregroundColor(.white)
                            .padding(.top, 2)
                    }
                    .frame(width: 400, height: 120)
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
