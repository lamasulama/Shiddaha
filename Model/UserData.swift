//
//  UserData.swift
//  Shiddaha
//
//  Created by lama bin slmah on 08/02/2026.
//

import Foundation
import SwiftData

@Model
final class UserData {
    var characterImageName: String
    var characterName: String
    var datesCount: Int
    var totalMinutesStudied: Int
    var createdAt: Date
    
    // 🎯 NEW - Shop properties
    var selectedTentImageName: String
    var purchasedTentIds: [String]
    var purchasedCharacterIds: [String]
    
    init(characterImageName: String, characterName: String, datesCount: Int = 0, totalMinutesStudied: Int = 0) {
        self.characterImageName = characterImageName
        self.characterName = characterName
        self.datesCount = datesCount
        self.totalMinutesStudied = totalMinutesStudied
        self.createdAt = Date()
        
        // 🎯 NEW - Initialize shop properties
        self.selectedTentImageName = "tent"
        self.purchasedTentIds = ["tent"] // Start with default tent
        self.purchasedCharacterIds = []
    }
}
