//
//  Chat.swift
//  VidChat
//
//  Created by Student on 2021-09-24.
//

import Foundation
import Firebase

class Chat: ObservableObject {
    
    //Doc info
    var id: String
    
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
    
    @Published var isSelected = false
    
    init(dictionary: [String:Any], id: String) {
        
        //Doc info
        self.id = id
        let isDm = dictionary["isDm"] as? Bool ?? false
        var chatMembers = [ChatMember]()
        
        //chat members
        let chatMembersDic = dictionary["users"] as? [[String:Any]] ?? [[String:Any]]()
        
        chatMembersDic.forEach({
            chatMembers.append(ChatMember(dictionary: $0))
        })
        
        self.chatMembers = chatMembers
        
        //name
        
        if isDm {
            let currentUid = AuthViewModel.shared.currentUser?.id ?? ""
            let friend = chatMembers.first(where: {$0.id != currentUid})
            
            self.name = friend?.firstName ?? ""
            self.profileImageUrl = friend?.profileImage ?? ""
            
        } else {
            self.name = dictionary["name"] as? String ?? ""
            self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        }
        
        
        //isDm
        self.isDm = isDm
        
        //messages
        self.lastMessagedCreatedAt = dictionary["lastMessagedCreatedAt"] as? Timestamp ?? Timestamp(date: Date())
        
        //users
        self.userIds = dictionary["userIds"] as? [String] ?? [String]()
        
        
        //messages
        let messagesDic = dictionary["messages"] as? [[String:Any]] ?? [[String:Any]]()
        messagesDic.forEach({ self.messages.append(Message(dictionary: $0, id: $0[id] as? String ?? "")) })
        
    }
}

struct ChatMember {
    
    let id: String
    let firstName: String
    let lastName: String
    let username: String
    let fcmToken: String
    let pushKitToken: String
    let profileImage: String
    
    init(dictionary: [String:Any]) {
        
        self.id = dictionary["userId"] as? String ?? ""
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.fcmToken = dictionary["fcmToken"] as? String ?? ""
        self.pushKitToken = dictionary["pushKitToken"] as? String ?? ""
        self.profileImage = dictionary["profileImage"] as? String ?? ""
    }
}
