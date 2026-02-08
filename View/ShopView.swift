import SwiftUI

struct ShopView: View {
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            Text("Shop Page")
                .font(.custom("PressStart2P-Regular", size: 18))
                .foregroundColor(.black)
        }
    }
}
