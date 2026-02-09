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
    
    init(characterImageName: String, characterName: String, datesCount: Int = 0, totalMinutesStudied: Int = 0) {
        self.characterImageName = characterImageName
        self.characterName = characterName
        self.datesCount = datesCount
        self.totalMinutesStudied = totalMinutesStudied
        self.createdAt = Date()
    }
}