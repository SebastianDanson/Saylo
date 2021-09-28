//
//  User.swift
//  VidChat
//
//  Created by Student on 2021-09-24.
//

import Foundation
import Firebase

struct User {
    
    //Doc info
    let id: String
    
    //name
    let username: String
    let fullname: String
    
    //contact unfo
    let email: String
    let phoneNumber: String

    //profile
    let profileImageUrl: String
    let createdAt: Timestamp

    //chat
    var chats = [UserChat]()
    
    //connections
    let connections: [String]
    
    init(dictionary: [String:Any], id: String) {
        
        //Doc info
        self.id = id

        //name
        self.username = dictionary["username"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        
        //contact
        self.email = dictionary["email"] as? String ?? ""
        self.phoneNumber = dictionary["phoneNumber"] as? String ?? ""
        
        //profile
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.createdAt = dictionary["createdAt"] as? Timestamp ?? Timestamp(date: Date())

        //connections
        self.connections = dictionary["connections"] as? [String] ?? [String]()
        
        //chat
        let chatDic = dictionary["chats"] as? [[String:Any]] ?? [[String:Any]]()
    
        chatDic.forEach({
            let id = $0["id"] as? String ?? ""
            let lastVisited = $0["lastVisited"] as? String ?? ""
            self.chats.append(UserChat(id: id, lastVisited: lastVisited))
        })
    }
}

struct UserChat: Decodable {
    let id: String
    let lastVisited: String
}
