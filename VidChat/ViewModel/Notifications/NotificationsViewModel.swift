//
//  NotificationsViewModel.swift
//  VidChat
//
//  Created by Student on 2021-09-25.
//

import Foundation
import Firebase

class NotificationsViewModel: ObservableObject {
    @Published var notifications = [Notification]()
    
    init() {
        fetchNotifications()
    }
    
    func fetchNotifications() {
        guard let uid = AuthViewModel.shared.userSession?.uid else {return}
        
        let query = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications")
            .order(by: "timestamp", descending: true)
        
        query.getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else {return}
            self.notifications = documents.compactMap({ try? $0.data(as: Notification.self) })
        }

    }
    
    static func uploadNotification(toUid uid: String, type: NotificationType, post: Post? = nil) {
        guard let user = AuthViewModel.shared.currentUser, uid != user.id else {return}
        
        var data = ["username": user.username,
                    "timestamp": Timestamp(date: Date()),
                    "uid": user.id ?? "",
                    "profileImageUrl":user.profileImageUrl,
                    "type": type.rawValue] as [String : Any]
        
        if let post = post, let id = post.id {
            data["postId"] = id
        }
        
        COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").addDocument(data: data)
    }
}
