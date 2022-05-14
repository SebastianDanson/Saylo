//
//  Chat.swift
//  Saylo
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
    var profileImage: String
    var isDm: Bool
    var mutedUsers: [String]
    var isTeamSaylo: Bool
    
    var messages = [Message]()
    var seenLastPost: [String]

    //user info
    let userIds: [String]
    var chatMembers = [ChatMember]()
    
    var nameDictionary: [String:Any]?
    
    @Published var isSelected = false
//    @Published var isSending = false {
//        didSet {
//            print("")
//        }
//    }
//    @Published var uploadProgress: Double = 0.0 
//    @Published var hasSent = false
    @Published var hasUnreadMessage = false

    var lastReadMessageIndex = 0

    init(dictionary: [String:Any], id: String, shouldRemoveOldMessages: Bool = true) {

        
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
        
        self.isTeamSaylo = dictionary["isTeamSaylo"] as? Bool ?? false
        
        //name
   
        if isDm {
            let customNameArray = dictionary["name"] as? [String:Any]
            let currentUid = AuthViewModel.shared.currentUser?.id ?? Auth.auth().currentUser?.uid ?? ""
            let friend = chatMembers.first(where: {$0.id != currentUid})
            
            let customName = customNameArray?[currentUid] as? String

            if let customName = customName {
                self.name = customName
                self.fullName = customName
                self.nameDictionary = customNameArray
            } else {
                self.name = friend?.firstName ?? ""
                self.fullName = self.name + " " + (friend?.lastName ?? "")
            }
          
            self.profileImage = friend?.profileImage ?? ""
        } else {
            self.name = dictionary["name"] as? String ?? ""
            self.fullName = self.name
            self.profileImage = dictionary["profileImage"] as? String ?? ""
        }
        
        
        //isDm
        self.isDm = isDm
        
        self.mutedUsers = dictionary["mutedUsers"] as? [String] ?? [String]()
        
        //users
        self.userIds = dictionary["userIds"] as? [String] ?? [String]()
        
        
        //Seen last post
        self.seenLastPost = dictionary["seenLastPost"] as? [String] ?? [String]()
        
        //messages
        self.messages = ConversationService.getMessagesFromData(data: dictionary, shouldRemoveMessages: shouldRemoveOldMessages, chatId: id)
        
        if self.name.isEmpty {
            self.name = getDefaultChatName()
            
            let currentUser = AuthViewModel.shared.currentUser
            let userFullname = (currentUser?.firstName ?? "") + " " + (currentUser?.lastName ?? "")
            self.fullName = self.name + ", " + userFullname
        }
        
        self.hasUnreadMessage = getHasUnreadMessage()
        
        self.lastReadMessageIndex = getLastReadMessageIndex()

        
//        //Add unread messages to player view
//        if self.hasUnreadMessage && ConversationViewModel.shared.chatId != id && isTeamSaylo == false {
//
//            for i in self.lastReadMessageIndex..<self.messages.count {
//
//                let messages = ConversationPlayerViewModel.shared.messages
//
//                if !messages.contains(where: {$0.id == self.messages[i].id}), self.messages[i].type != .NewChat {
//                    ConversationPlayerViewModel.shared.addMessage(self.messages[i])
//                }
//            }
//
//            ConversationPlayerViewModel.shared.addReplyMessages()
//
//        }
        
    }
    
    func getDictionary() -> [String:Any] {
        var users = [[String:Any]]()
        chatMembers.forEach({users.append($0.dictionary)})
        
        var messages = [[String:Any]]()
        self.messages.forEach({messages.append($0.getDictionary())})

        
        var dictionary = [
            "id":id,
            "profileImage":profileImage,
            "isTeamSaylo":isTeamSaylo,
            "isDm":isDm,
            "name":name,
            "users":users,
            "mutedUsers":mutedUsers,
            "userIds":userIds,
            "messages":messages,
            "lastReadMessageIndex":lastReadMessageIndex
        ] as [String: Any]
        
        if let nameDictionary = nameDictionary {
            dictionary["name"] = nameDictionary
        }
        
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
        if messages.count > 1 {
            for i in 0..<messages.count - 1 {
                if messages[i].timestamp.dateValue() > lastVisited.dateValue() {
                    return i
                }
            }
        }
                
        return max(0,messages.count - 1)
    }
    
    func setLastMessageIndex() {
        self.lastReadMessageIndex = getLastReadMessageIndex()
    }
    
    
    func getDefaultChatName() -> String {
        
        let currentUserId = AuthViewModel.shared.getUserId()
        
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

