//
//  Notification.swift
//  VidChat
//
//  Created by Student on 2021-09-25.
//

import FirebaseFirestoreSwift
import Firebase

struct Notification: Identifiable, Decodable {
    var postId: String?
    var username: String
    var profileImageUrl: String
    let timestamp: Timestamp
    let type: NotificationType
    let uid: String
    
    var post: Post?
    var isFollowed: Bool? = false
    var user: User?
    
    @DocumentID var id: String?
}

enum NotificationType: Int, Decodable {
    case like, comment, follow
    
    var notificationMessage: String {
        switch self {
        case .like:
            return " liked one of your posts"
        case .comment:
            return " commented on one of your posts"
        case .follow:
            return " started following you"
        
        }
    }
}
