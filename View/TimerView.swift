import SwiftUI

struct TimerView: View {
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            Text("Timer Page")
                .font(.custom("PressStart2P-Regular", size: 18))
                .foregroundColor(.black)
        }
    }
}
