// UserData.swift

import Foundation
import SwiftData

@Model
final class UserData {
    var characterImageName: String
    var characterName: String
    var datesCount: Int
    var totalMinutesStudied: Int
    var createdAt: Date

    // Shop
    var selectedTentImageName: String
    var purchasedTentIds: [String]
    var purchasedCharacterIds: [String]

    init(
        characterImageName: String,
        characterName: String,
        datesCount: Int = 0,
        totalMinutesStudied: Int = 0
    ) {
        self.characterImageName = characterImageName
        self.characterName = characterName
        self.datesCount = datesCount
        self.totalMinutesStudied = totalMinutesStudied
        self.createdAt = Date()

        // Default tent owned
        self.selectedTentImageName = "tent"
        self.purchasedTentIds = ["tent"]

        // ✅ Default characters owned
        self.purchasedCharacterIds = ["char_boy", "char_girl"]
    }
}
