import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            Text("Settings Page")
                .font(.custom("PressStart2P-Regular", size: 18))
                .foregroundColor(.black)
        }
    }
}
