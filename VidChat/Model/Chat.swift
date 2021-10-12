//
//  Chat.swift
//  VidChat
//
//  Created by Student on 2021-09-25.
//

import Foundation
import Firebase

struct Chat {
    
    //Doc info
    let id: String
    
    //info
    let name: String
    let profileImageUrl: String
    var isDm = true

    //messages
    let lastMessagedCreatedAt: Timestamp //the date when the most recent message was created
    var messages = [Message]()
        
    //users
    let userIds: [String]
    var chatMembers = [ChatMember]()

    
    init(dictionary: [String:Any], id: String) {
        
        //Doc info
        self.id = id
        
        //name
        self.name = dictionary["name"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""

        //messages
        self.lastMessagedCreatedAt = dictionary["lastMessagedCreatedAt"] as? Timestamp ?? Timestamp(date: Date())
        
        //users
        self.userIds = dictionary["userIds"] as? [String] ?? [String]()
        
        //chat members
        let chatMembersDic = dictionary["chatMembers"] as? [[String:Any]] ?? [[String:Any]]()
        chatMembersDic.forEach({
            self.chatMembers.append(ChatMember(id: $0["id"] as? String ?? "",
                                               name: $0["name"] as? String ?? "",
                                               token: $0["token"] as? String ?? "",
                                               profileImageUrl: $0["profileImageUrl"] as? String ?? ""))
        })
        
        //messages
        let messagesDic = dictionary["messages"] as? [[String:Any]] ?? [[String:Any]]()
        messagesDic.forEach({ self.messages.append(Message(dictionary: $0, id: $0[id] as? String ?? "")) })
        
        //isDm
        self.isDm = chatMembers.count == 2 && chatMembers[0].token != nil
    }
}

struct ChatMember {
    let id: String
    let name: String
    let token: String?
    let profileImageUrl: String?
}
