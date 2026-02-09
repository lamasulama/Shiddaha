import Foundation
import Combine
import SwiftData

final class OnboardingViewModel: ObservableObject {

    enum Screen {
        case choose
        case naming
        case main
    }

    @Published var screen: Screen = .choose
    @Published var characters: [AppCharacter] = [
        AppCharacter(imageName: "char_boy"),
        AppCharacter(imageName: "char_girl")
    ]
    @Published var selectedCharacter: AppCharacter? = nil
    @Published var characterName: String = ""
    @Published var datesCount: Int = 0
    
    var userData: UserData?
    var modelContext: ModelContext?

    var canSave: Bool {
        !characterName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func select(_ character: AppCharacter) {
        selectedCharacter = character
        screen = .naming
    }

    func save() {
        guard canSave, let context = modelContext else { return }
        
        let newUser = UserData(
            characterImageName: selectedCharacter?.imageName ?? "",
            characterName: characterName
        )
        
        context.insert(newUser)
        try? context.save()
        
        userData = newUser
        datesCount = newUser.datesCount
        
        screen = .main
    }

    func backToChoose() {
        screen = .choose
        characterName = ""
        selectedCharacter = nil
    }
    
    func addDates(_ minutes: Int) {
        guard let context = modelContext, let user = userData else { return }
        
        user.datesCount += minutes
        user.totalMinutesStudied += minutes
        datesCount = user.datesCount
        
        let session = StudySession(minutesStudied: minutes, datesEarned: minutes)
        context.insert(session)
        
        try? context.save()
    }
    
    func loadUserData(context: ModelContext) {
        self.modelContext = context
        
        let descriptor = FetchDescriptor<UserData>()
        if let existingUser = try? context.fetch(descriptor).first {
            userData = existingUser
            selectedCharacter = characters.first(where: { $0.imageName == existingUser.characterImageName })
            characterName = existingUser.characterName
            datesCount = existingUser.datesCount
            screen = .main
        }
    }
    
    func resetAllData() {
        guard let context = modelContext else { return }
        
        let userDescriptor = FetchDescriptor<UserData>()
        if let users = try? context.fetch(userDescriptor) {
            users.forEach { context.delete($0) }
        }
        
        let sessionDescriptor = FetchDescriptor<StudySession>()
        if let sessions = try? context.fetch(sessionDescriptor) {
            sessions.forEach { context.delete($0) }
        }
        
        try? context.save()
        
        userData = nil
        datesCount = 0
        screen = .choose
    }
}
