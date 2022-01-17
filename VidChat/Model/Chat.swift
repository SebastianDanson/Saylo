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
    var name: String
    var fullName: String
    var profileImageUrl: String
    var isDm = true
    var mutedUsers: [String]
  
    var messages = [Message]()
    
    //user info
    let userIds: [String]
    var chatMembers = [ChatMember]()
    
    
    @Published var isSelected = false
    @Published var isSending = false
    @Published var hasSent = false
    @Published var hasUnreadMessage = false

    var lastReadMessageIndex = 0
    

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
            let customNameArray = dictionary["name"] as? [String:Any]
            let currentUid = AuthViewModel.shared.currentUser?.id ?? Auth.auth().currentUser?.uid ?? ""
            let friend = chatMembers.first(where: {$0.id != currentUid})
            
            let customName = customNameArray?[currentUid] as? String

            if let customName = customName {
                self.name = customName
                self.fullName = customName
            } else {
                self.name = friend?.firstName ?? ""
                self.fullName = self.name + " " + (friend?.lastName ?? "")
            }
          
            self.profileImageUrl = friend?.profileImage ?? ""
        } else {
            self.name = dictionary["name"] as? String ?? ""
            self.fullName = self.name
            self.profileImageUrl = dictionary["profileImage"] as? String ?? ""
        }
        
        
        //isDm
        self.isDm = isDm
        
        self.mutedUsers = dictionary["mutedUsers"] as? [String] ?? [String]()
        
        //users
        self.userIds = dictionary["userIds"] as? [String] ?? [String]()
        

        //messages
        self.messages = ConversationService.getMessagesFromData(data: dictionary, chatId: id)

        if self.name.isEmpty {
            self.name = getDefaultChatName()
            
            let currentUser = AuthViewModel.shared.currentUser
            let userFullname = (currentUser?.firstName ?? "") + " " + (currentUser?.lastName ?? "")
            self.fullName = self.name + ", " + userFullname
        }
        
        self.hasUnreadMessage = getHasUnreadMessage()
        self.lastReadMessageIndex = getLastReadMessageIndex()
    }
    
    func getDictionary() -> [String:Any] {
        var users = [[String:Any]]()
        chatMembers.forEach({users.append($0.dictionary)})
        
        var messages = [[String:Any]]()
        self.messages.forEach({messages.append($0.getDictionary())})

        let dictionary = [
            "id":id,
            "profileImage":profileImageUrl,
            "isDm":isDm,
            "name":name,
            "users":users,
            "mutedUsers":mutedUsers,
            "userIds":userIds,
            "username": "Seb",
        ] as [String: Any]
        
        return dictionary
    }
    
    func getDateOfLastPost() -> Int {
        return Int(self.messages.last?.timestamp.dateValue().timeIntervalSince1970 ?? 0)
    }
    
    func getHasUnreadMessage() -> Bool {
        guard let user = AuthViewModel.shared.currentUser, let chat = user.chats.first(where: {$0.id == id}), let last = messages.last else {return false}
        return Int(chat.lastVisited.dateValue().timeIntervalSince1970) < getDateOfLastPost() && !last.isFromCurrentUser
    }
    
    func getLastReadMessageIndex() -> Int {
        
        guard let user = AuthViewModel.shared.currentUser, let chat = user.chats.first(where: {$0.id == id}) else {return messages.count - 1}

        let lastVisited = chat.lastVisited
        
        for i in 0..<messages.count {
            if messages[i].timestamp.dateValue() > lastVisited.dateValue() {
                return i
            }
        }
        
        return messages.count - 1
    }
    
    
    func getDefaultChatName() -> String {
        
        guard let currentUserId = AuthViewModel.shared.currentUser?.id ?? Auth.auth().currentUser?.uid else {return ""}

        var name = ""
        
        self.chatMembers.forEach { chatMember in
            
            if chatMember.id != currentUserId {
                
                if name.isEmpty {
                    name = chatMember.firstName
                } else {
                    name += ", \(chatMember.firstName)"
                }
                
            }
            
        }
        
        return name
    }

}

