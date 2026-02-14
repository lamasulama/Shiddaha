import SwiftUI
import SwiftData

@main
struct ShiddahaApp: App {

    @Environment(\.scenePhase) private var scenePhase

    // Splash state
    @State private var splashFinished = false
    @State private var showSplash = true

    // Time tracking (last time app was ACTIVE)
    @AppStorage("lastActiveTimestamp") private var lastActiveTimestamp: Double = 0

    // App state
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    private let splashDuration: Double = 3.0
    private let inactivitySeconds: Double = 30 * 60  // 30 minutes

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView {
                        // Splash ends after its own animations
                        withAnimation(.easeInOut(duration: 0.25)) {
                            splashFinished = true
                            showSplash = false
                        }
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                } else {
                    rootAfterSplash
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
            }
            .onAppear {
                decideIfShouldShowSplashOnLaunch()
            }
            .onChange(of: scenePhase) { _, newPhase in
                handleScenePhaseChange(newPhase)
            }
        }
        .modelContainer(for: [UserData.self, StudySession.self])
    }

    // MARK: - Root after splash
    @ViewBuilder
    private var rootAfterSplash: some View {
        ContentView()

    }

    // MARK: - Splash decision
    private func decideIfShouldShowSplashOnLaunch() {
        let now = Date().timeIntervalSince1970

        // First time ever
        if lastActiveTimestamp == 0 {
            showSplash = true
            splashFinished = false
            return
        }

        // If app was inactive >= 30 minutes
        let diff = now - lastActiveTimestamp
        if diff >= inactivitySeconds {
            showSplash = true
            splashFinished = false
        } else {
            showSplash = false
            splashFinished = true
        }
    }

    // MARK: - ScenePhase (this is the "touched time" tracker)
    private func handleScenePhaseChange(_ phase: ScenePhase) {
        let now = Date().timeIntervalSince1970

        switch phase {
        case .active:
            // If coming back after 30 minutes -> show splash again
            if lastActiveTimestamp != 0 {
                let diff = now - lastActiveTimestamp
                if diff >= inactivitySeconds {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showSplash = true
                        splashFinished = false
                    }

                    // Auto-dismiss splash after duration (optional safety)
                    DispatchQueue.main.asyncAfter(deadline: .now() + splashDuration) {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showSplash = false
                            splashFinished = true
                        }
                    }
                }
            }

            // Update last active time
            lastActiveTimestamp = now

        case .inactive, .background:
            // Save last active time when leaving
            lastActiveTimestamp = now

        @unknown default:
            lastActiveTimestamp = now
        }
    }
}
