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
    
    // Shop properties
    @Published var selectedTentImageName: String = "tent"
    @Published var purchasedTentIds: Set<String> = ["tent"]
    @Published var purchasedCharacterIds: Set<String> = ["char_boy", "char_girl"]

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
        
        selectedTentImageName = newUser.selectedTentImageName
        purchasedTentIds = Set(newUser.purchasedTentIds)
        purchasedCharacterIds = Set(newUser.purchasedCharacterIds)
        
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
            
            // 🔥 مهم: نخلي أي شخصية محفوظة تظهر حتى لو مو ضمن الـ characters array
            selectedCharacter = AppCharacter(imageName: existingUser.characterImageName)
            
            characterName = existingUser.characterName
            datesCount = existingUser.datesCount
            
            selectedTentImageName = existingUser.selectedTentImageName
            purchasedTentIds = Set(existingUser.purchasedTentIds)
            purchasedCharacterIds = Set(existingUser.purchasedCharacterIds)
            
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
        
        selectedTentImageName = "tent"
        purchasedTentIds = ["tent"]
        purchasedCharacterIds = ["char_boy", "char_girl"]
        
        screen = .choose
    }
    
    // MARK: - Shop

    func purchaseItem(_ item: StoreItem) -> Bool {
        guard let context = modelContext, let user = userData else { return false }
        guard datesCount >= item.price else { return false }
        
        user.datesCount -= item.price
        datesCount = user.datesCount
        
        switch item.category {
        case .tents:
            purchasedTentIds.insert(item.imageName)
            user.purchasedTentIds = Array(purchasedTentIds)
        case .characters:
            purchasedCharacterIds.insert(item.imageName)
            user.purchasedCharacterIds = Array(purchasedCharacterIds)
        }
        
        try? context.save()
        return true
    }
    
    func isPurchased(_ item: StoreItem) -> Bool {
        switch item.category {
        case .tents:
            return purchasedTentIds.contains(item.imageName)
        case .characters:
            return purchasedCharacterIds.contains(item.imageName)
        }
    }
    
    func selectTent(_ tentImageName: String) {
        guard let context = modelContext, let user = userData else { return }
        guard purchasedTentIds.contains(tentImageName) else { return }
        
        selectedTentImageName = tentImageName
        user.selectedTentImageName = tentImageName
        
        try? context.save()
    }
    
    func isTentSelected(_ tentImageName: String) -> Bool {
        selectedTentImageName == tentImageName
    }
    
    func selectCharacter(_ characterImageName: String) {
        guard let context = modelContext, let user = userData else { return }
        guard purchasedCharacterIds.contains(characterImageName) else { return }
        
        // 🔥 هذا أهم تعديل
        selectedCharacter = AppCharacter(imageName: characterImageName)
        user.characterImageName = characterImageName
        
        try? context.save()
    }
    
    func isCharacterSelected(_ characterImageName: String) -> Bool {
        // نخلي المصدر الحقيقي هو المحفوظ في SwiftData
        return userData?.characterImageName == characterImageName
    }
}
