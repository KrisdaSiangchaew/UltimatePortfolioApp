//
//  DataController-Reminder.swift
//  UltimatePortfolioApp
//
//  Created by Krisda on 13/6/2564 BE.
//

import Foundation
import UserNotifications

extension DataController {
    // MARK: - UserNotifications
    
    func addReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        // 1. Check our authorization status for local notification
        // 2. If status is not determined - i.e. user made no choice - do something
        // 3. If status is authorized, we call placeReminders immediately
        // 4. If we're in any other authorization state, we'll consider it a failure
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestNotification { success in
                    if success {
                        self.placeReminders(for: project, completion: completion)
                    } else {
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                }
            case .authorized:
                self.placeReminders(for: project, completion: completion)
            default:
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    func removeReminders(for project: Project) {
        let id = project.objectID.uriRepresentation().absoluteString
        
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    private func requestNotification(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            completion(granted)
        }
    }
    
    private func placeReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        // Deciding the content of the notification
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = project.projectTitle
        if let projectDetail = project.detail {
            content.subtitle = projectDetail
        }
        
        // Telling iOS when the notification should be shown
        let components = Calendar.current.dateComponents([.hour, .minute], from: project.reminderTime ?? Date())
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Wrapping above two pieces of information along with a unique identifier
        let id = project.objectID.uriRepresentation().absoluteString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    
        // Sending it off to iOS to be shown while handling the response carefully
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if error == nil {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
   
}
