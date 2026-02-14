import SwiftUI

struct SplashView: View {

    // مهم: هذا هو اللي ينقلك للصفحة اللي بعدها
    let onFinish: () -> Void

    @State private var showPalm = false
    @State private var showTitle = false
    @State private var showDate = false

    @State private var dateOffset: CGFloat = -260

    var body: some View {
        ZStack {

            // الخلفية
            AppBackgroundView()

            VStack(spacing: 0) {

                Spacer()

                // 🌴 النخلة
                Image("Palm")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 260)
                    .offset(y: -10)
                    .opacity(showPalm ? 1 : 0)
                    .animation(.easeOut(duration: 0.8), value: showPalm)

                Spacer().frame(height: 20)

                // 📝 اسم التطبيق + التمرة
                ZStack {
                    Text("Shiddaha")
                        .font(.custom("PressStart2P-Regular", size: 28))
                        .foregroundColor(.black)
                        .offset(y: 25)
                        .opacity(showTitle ? 1 : 0)
                        .animation(.easeOut(duration: 0.6), value: showTitle)

                    // 🍂 التمرة (عدّلي x/y لو تبينها على i بالضبط)
                    Image("DateT")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 20)
                        .offset(x: -43, y: dateOffset + 7)
                        .opacity(showDate ? 1 : 0)
                        .animation(.easeIn(duration: 1.2), value: dateOffset)
                }

                Spacer()
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { showPalm = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { showTitle = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            showDate = true
            dateOffset = 0
        }
        
        // 🎯 AUTO-DISMISS after 3 seconds total
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            onFinish()
        }
    }
}

#Preview {
    SplashView(onFinish: {})
}
