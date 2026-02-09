//
//  StudySession.swift
//  Shiddaha
//
//  Created by lama bin slmah on 08/02/2026.
//


import Foundation
import SwiftData

@Model
final class StudySession {
    var minutesStudied: Int
    var datesEarned: Int
    var sessionDate: Date
    
    init(minutesStudied: Int, datesEarned: Int, sessionDate: Date = Date()) {
        self.minutesStudied = minutesStudied
        self.datesEarned = datesEarned
        self.sessionDate = sessionDate
    }
}