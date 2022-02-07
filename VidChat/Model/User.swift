//
//  User.swift
//  Saylo
//
//  Created by Student on 2021-09-24.
//

import Foundation
import Firebase

class User: ChatMember, ObservableObject {
    
    //contact unfo
    let email: String
    let phoneNumber: String
    
    //profile
    let createdAt: Timestamp
    
    //chat
    @Published var chats = [UserChat]()
    var conversationsDic: [[String:Any]]
    
    
    //friends
    var friends: [String]
    var friendRequests: [String]
    
    init(dictionary: [String:Any], id: String) {
        
        //contact
        self.email = dictionary["email"] as? String ?? ""
        self.phoneNumber = dictionary["phoneNumber"] as? String ?? ""
        
        //profile
        self.createdAt = dictionary["createdAt"] as? Timestamp ?? Timestamp(date: Date())
        
        //friends
        self.friends = dictionary["friends"] as? [String] ?? [String]()
        self.friendRequests = dictionary["friendRequests"] as? [String] ?? [String]()
        
        self.conversationsDic = dictionary["conversations"] as? [[String:Any]] ?? [[String:Any]]()
        
        super.init(dictionary: dictionary, id: id)
        
        //chat
        conversationsDic.forEach({self.chats.append(UserChat(dictionary: $0))})
        
        let uid = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)?.string(forKey: "userId") ?? ""
        
        if !AuthViewModel.shared.hasUnseenFriendRequest && uid == id {
            AuthViewModel.shared.hasUnseenFriendRequest = dictionary["hasUnseenFriendRequest"] as? Bool ?? false
        }
    }
}

struct UserChat {
    let id: String
    var lastVisited: Timestamp
    let notificationsEnbaled: Bool
    
    init(dictionary: [String:Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.lastVisited = dictionary["lastVisited"] as? Timestamp ?? Timestamp(date: Date())
        self.notificationsEnbaled = dictionary["notificationsEnbaled"] as? Bool ?? true
    }
    
    func getDictionary() -> [String:Any] {
        return ["id":id, "lastVisited":lastVisited, "notificationsEnbaled":notificationsEnbaled]
    }
}


