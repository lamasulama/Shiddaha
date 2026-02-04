import Foundation
import Combine

final class OnboardingViewModel: ObservableObject {

    @Published var characters: [AppCharacter] = [
        AppCharacter(imageName: "char_boy"),
        AppCharacter(imageName: "char_girl")
    ]

    @Published var selectedCharacter: AppCharacter? = nil
    @Published var characterName: String = ""
    @Published var isNaming: Bool = false

    @Published var datesCount: Int = 0   // للمين بيج

    var canSave: Bool {
        !characterName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func select(_ character: AppCharacter) {
        selectedCharacter = character
        isNaming = true
    }

    func save() {
        guard canSave else { return }
        // التنقل يصير من الفيو
    }

    func backToChoose() {
        isNaming = false
        characterName = ""
        selectedCharacter = nil
    }
}
