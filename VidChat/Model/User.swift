//
//  User.swift
//  VidChat
//
//  Created by Student on 2021-09-24.
//

import Foundation
import Firebase

class User: ObservableObject  {
    
    //Doc info
    let id: String
    
    //name
    var username: String
    var firstName: String
    var lastName: String

    //contact unfo
    let email: String
    let phoneNumber: String

    //profile
    var profileImageUrl: String
    let createdAt: Timestamp

    //chat
    @Published var chats = [UserChat]()
    
    //tokens
    let fcmToken: String
    let pushKitToken: String
    
    //friends
    var friends: [String]
    var friendRequests: [String]
    @Published var hasUnseenFriendRequest: Bool

    init(dictionary: [String:Any], id: String) {
        
        //Doc info
        self.id = id

        //name
        self.username = dictionary["username"] as? String ?? ""
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""

        //contact
        self.email = dictionary["email"] as? String ?? ""
        self.phoneNumber = dictionary["phoneNumber"] as? String ?? ""
        
        //profile
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.createdAt = dictionary["createdAt"] as? Timestamp ?? Timestamp(date: Date())

        //friends
        self.friends = dictionary["friends"] as? [String] ?? [String]()
        self.friendRequests = dictionary["friendRequests"] as? [String] ?? [String]()
        self.hasUnseenFriendRequest = dictionary["hasUnseenFriendRequest"] as? Bool ?? false

        //tokens
        self.fcmToken = dictionary["fcmToken"] as? String ?? ""
        self.pushKitToken = dictionary["pushKitToken"] as? String ?? ""

        //chat
        let chatDic = dictionary["conversations"] as? [[String:Any]] ?? [[String:Any]]()
        chatDic.forEach({self.chats.append(UserChat(dictionary: $0))})
    }
}

struct UserChat {
    let id: String
    let lastVisited: Timestamp
    let notificationsEnbaled: Bool
    
    init(dictionary: [String:Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.lastVisited = dictionary["lastVisited"] as? Timestamp ?? Timestamp(date: Date())
        self.notificationsEnbaled = dictionary["notificationsEnbaled"] as? Bool ?? true
    }
}


