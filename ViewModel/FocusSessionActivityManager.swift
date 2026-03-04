//
//  FocusSessionActivityManager.swift
//  Shiddaha
//
//  Created by lama bin slmah on 03/03/2026.
//
//  📁 Location: ViewModel folder
//  🎯 Target Membership: Shiddaha (app target only)

import ActivityKit
import Foundation
import UserNotifications

// MARK: - Focus Session Activity Manager
class FocusSessionActivityManager {
    static let shared = FocusSessionActivityManager()
    
    private var currentActivity: Activity<FocusSessionAttributes>?
    private var updateTimer: Timer?
    
    private init() {}
    
    // Start Live Activity
    func startActivity(totalMinutes: Int, isStandardSession: Bool, characterImageName: String) {
        // Check if Live Activities are supported and enabled
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled")
            return
        }
        
        let attributes = FocusSessionAttributes(sessionStartTime: Date())
        let initialState = FocusSessionAttributes.ContentState(
            timeRemaining: totalMinutes * 60,
            totalMinutes: totalMinutes,
            isStandardSession: isStandardSession,
            characterImageName: characterImageName,
            sessionStartTime: Date()
        )
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(
                    state: initialState,
                    staleDate: nil
                )
            )
            print("✅ Live Activity started")
        } catch {
            print("❌ Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    // Update Live Activity
    func updateActivity(timeRemaining: Int) {
        guard let activity = currentActivity else { return }
        
        Task {
            let updatedState = FocusSessionAttributes.ContentState(
                timeRemaining: timeRemaining,
                totalMinutes: activity.content.state.totalMinutes,
                isStandardSession: activity.content.state.isStandardSession,
                characterImageName: activity.content.state.characterImageName,
                sessionStartTime: activity.content.state.sessionStartTime
            )
            
            await activity.update(
                ActivityContent(
                    state: updatedState,
                    staleDate: nil
                )
            )
        }
    }
    
    // End Live Activity
    func endActivity(showCompletionMessage: Bool = true) {
        guard let activity = currentActivity else { return }
        
        Task {
            if showCompletionMessage {
                // Update one last time with completion message
                let finalState = FocusSessionAttributes.ContentState(
                    timeRemaining: 0,
                    totalMinutes: activity.content.state.totalMinutes,
                    isStandardSession: activity.content.state.isStandardSession,
                    characterImageName: activity.content.state.characterImageName,
                    sessionStartTime: activity.content.state.sessionStartTime
                )
                
                await activity.update(
                    ActivityContent(
                        state: finalState,
                        staleDate: nil
                    )
                )
            }
            
            // End the activity
            await activity.end(nil, dismissalPolicy: .immediate)
            currentActivity = nil
            print("✅ Live Activity ended")
        }
    }
    
    // Check if activity is running
    var isActivityRunning: Bool {
        return currentActivity != nil
    }
    
    // MARK: - Notifications
    
    // Request notification permission
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // Send completion notification
    func sendCompletionNotification(earnedDates: Int, sessionMinutes: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Focus Session Complete! 🎉"
        content.body = "Great work! You completed \(sessionMinutes) minutes and earned \(earnedDates) date\(earnedDates == 1 ? "" : "s")!"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Deliver immediately
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Notification error: \(error.localizedDescription)")
            } else {
                print("✅ Notification sent")
            }
        }
    }
}
