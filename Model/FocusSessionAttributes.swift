//
//  FocusSessionAttributes.swift
//  Shiddaha
//
//  Created by lama bin slmah on 03/03/2026.
//
//  📁 Location: Model folder
//  🎯 Target Membership: Shiddaha + FocusSessionWidget (BOTH!)

import ActivityKit
import Foundation

// MARK: - Focus Session Live Activity Attributes
struct FocusSessionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var timeRemaining: Int // seconds
        var totalMinutes: Int
        var isStandardSession: Bool
        var characterImageName: String
    }
    
    // Fixed attributes (don't change during the activity)
    var sessionStartTime: Date
}
