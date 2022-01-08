//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by Sebastian Danson on 2022-01-07.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        let defaults = UserDefaults.init(suiteName: "group.com.SebastianDanson.saylo")
        var notificationArray = defaults?.object(forKey: "notifications") as? [String] ?? [String]()
        
        let data = bestAttemptContent?.userInfo["data"] as? [String:Any]
        
        if let bestAttemptContent = bestAttemptContent, let id = data?["chatId"] as? String, id != "" {
            
            if !notificationArray.contains(id) {
                notificationArray.append(id)
                defaults?.set(notificationArray, forKey: "notifications")
            }
            
            var mutedChats = defaults?.object(forKey: "mutedChats") as? [String:Any] ?? [String:Any]()

            if let time = mutedChats[id] as? Int {
                let now = Int(Date().timeIntervalSince1970*1000)
                if time > now {
                    contentHandler(UNNotificationContent())
                } else {
                    mutedChats.removeValue(forKey: id)
                }
                defaults?.set(mutedChats, forKey: "mutedChats")
            }
            
            
            bestAttemptContent.badge = notificationArray.count as? NSNumber
            contentHandler(bestAttemptContent)
        } else {
            contentHandler(bestAttemptContent ?? UNNotificationContent())
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
