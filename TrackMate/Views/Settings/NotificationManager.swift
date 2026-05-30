//
//  NotificationManager.swift
//  TrackMate
//
//  Created by Glen Mars on 4/10/25.
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notificatoin permission granted.")
                self.scheduleDailyNotification()
            } else if let error = error {
                print("Error requesting notificaiton permission: \(error.localizedDescription)")
            } else {
                print("Notification permission denied.")
            }
        }
    }
    
    /// Shedule a notification that repeats daily
    func scheduleDailyNotification() {
        let redFlagFacts = [
            "Gaslighting: A form of manipulation that makes you doubt your reality.",
            "Narcissistic Behavior: Excessive self-centeredness at the expense of empathy.",
            "Love Bombing: Overwhelming someone with attention to gain control.",
            "Stonewalling: Withdrawing or refusing to communicate.",
            "Trauma Bonding: Strong, unhealthy attachments in abusive relationships.",
            "Codependency: Over-reliance on another for self-esteem and validation.",
            "Hoovers: Cycles where an abuser returns to re-engage with their victim.",
            "DARVO: Deny, Attack, Reverse Victim and Offender.",
            "Boundaries vs. Control: Recognizing healthy limits versus controlling behavior."
        ]
        
        // Pick a random fact
        let randomFact = redFlagFacts.randomElement() ?? "Remember to set healthy boundaries."
        
        let content = UNMutableNotificationContent()
        content.title = "Red Flag Fact of the Day"
        content.body = randomFact
        content.sound = UNNotificationSound.default
        
        // Configuratiojn for notification time trigger
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Unique identifier for this notification request
        let request = UNNotificationRequest(identifier: "RedFlagDailyNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily notification: \(error.localizedDescription)")
            } else {
                print("Daily Red Flag notification scheduled.")
            }
        }
    }
	
	func scheduleHindsightReflection(for personName: String, interactionId: UUID, after timeInterval: TimeInterval = 86400) {
		let content = UNMutableNotificationContent()
		content.title = "Time to reflect"
		content.body = "Have your thoughts changed about your interaction with \(personName)? Take a moment to add a note that gives more context to what happened."
		content.sound = UNNotificationSound.default
		
		// Store ID to deep-link to the exact interaction (later)
		content.userInfo = ["interactionId": interactionId.uuidString]
		
		// TimeInterval trigger (24 hours)
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
		
		// Use the interaction ID to prevent duplicate notifications for the same interaction
		let request = UNNotificationRequest(identifier: "Hindsight-\(interactionId.uuidString)", content: content, trigger: trigger)
		
		UNUserNotificationCenter.current().add(request) { error in
			if let error = error {
				print("Error scheduling hindsight notification: \(error.localizedDescription)")
			} else {
				print("Hindsight reflection scheduled for \(personName) in \(timeInterval / 3600) hours.")
			}
		}
	}
}
