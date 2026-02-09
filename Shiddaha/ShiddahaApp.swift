import SwiftUI
import SwiftData

@main
struct ShiddahaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [UserData.self, StudySession.self])
    }
}
