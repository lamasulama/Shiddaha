import SwiftUI
import SwiftData

@main
struct ShiddahaApp: App {

    @State private var didFinishSplash = false

    var body: some Scene {
        WindowGroup {

            if didFinishSplash {
                ContentView()   // 👈 هذه صفحة الـ Onboarding
            } else {
                SplashView {
                    didFinishSplash = true
                }
            }

        }
        .modelContainer(for: [UserData.self, StudySession.self])
    }
}
