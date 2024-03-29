//
//  ChatSettingsViewModel.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-14.
//

import SwiftUI
import Firebase

class ChatSettingsViewModel: ObservableObject {
    
    @Published var addedChats = [Chat]()
    @Published var chats = [Chat]()
    
    var allChats = [Chat]()
    
    static let shared = ChatSettingsViewModel()
    
    private init() {}
    
    func addUsersToChat() {
       
        guard let chat = ConversationViewModel.shared.chat else { return }
        guard let user = AuthViewModel.shared.currentUser else {return}
        
        
        var chatMembers = [ChatMember]()
        addedChats.forEach({chatMembers.append(contentsOf: $0.chatMembers)})
        
        chatMembers.removeAll(where: {$0.id == user.id })
        
        var userInfo = [[String:Any]]()
        
        chatMembers.forEach { chatMember in
            
            let info = ["firstName":chatMember.firstName,
                        "lastName":chatMember.lastName,
                        "username":chatMember.username,
                        "profileImage":chatMember.profileImage,
                        "userId":chatMember.id,
                        "fcmToken":chatMember.fcmToken,
                        "pushKitToken": chatMember.pushKitToken]
            
            userInfo.append(info)
        }
        
        ConversationViewModel.shared.chat?.chatMembers.append(contentsOf: chatMembers)
       
        COLLECTION_CONVERSATIONS.document(chat.id).updateData(["users":FieldValue.arrayUnion(userInfo)])
        
        //create dictionary to send to DB
    
        var fcmTokens = [String]()
        chatMembers.forEach({fcmTokens.append($0.fcmToken)})
        
        let data = ["tokens": fcmTokens, "chatId": chat.id] as [String : Any]
        Functions.functions().httpsCallable("subscribeToTopic").call(data) { (result, error) in}
    
        Messaging.messaging().subscribe(toTopic: chat.id)

        
        let groupData = ["lastVisited": Timestamp(date: Date()),
                         "notificationsEnabled": true,
                         "id":chat.id] as [String: Any]
        
        //Update the added users docs
        chatMembers.forEach { chatMember in
            COLLECTION_USERS.document(chatMember.id).updateData(["conversations": FieldValue.arrayUnion([groupData])])
          
            var data = [String:Any]()
            data["token"] = chatMember.fcmToken
            data["body"] = user.firstName + " " + user.lastName + " added you to a group"
            Functions.functions().httpsCallable("sendNotification").call(data) { (result, error) in }
        }
        
        var names = ""
        
        for i in 0..<chatMembers.count {
            
            let member = chatMembers[i]
            let memberName = member.firstName + " " + member.lastName
            
            if i == 0 {
                names = memberName
            } else if i == chatMembers.count - 1 && chatMembers.count > 1 {
                names += " and \(memberName)"
            } else {
                names += ", \(memberName) "
            }
        }
            

        ConversationViewModel.shared.addMessage(text: "Added \(names) to the group", type: .Text, chatId: chat.id)
    }
    
    
    func updateChatName(name: String) {
        
        var chat: Chat?
        
        if ConversationGridViewModel.shared.showConversation {
            chat = ConversationViewModel.shared.chat
        } else if let settingsChat = ConversationGridViewModel.shared.selectedSettingsChat {
            chat = settingsChat
        }
        
        guard let chat = chat else { return }
        
        let chatRef = COLLECTION_CONVERSATIONS.document(chat.id)
        
        if chat.isDm {
            Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
                transaction.updateData(["name" : [AuthViewModel.shared.getUserId():name]], forDocument: chatRef)
                return nil
            }) { (_, error) in }
            
        } else  {
            Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
                transaction.updateData(["name" : name], forDocument: chatRef)
                return nil
            }) { (_, error) in }
            
            
            ConversationViewModel.shared.addMessage(text: "Changed the group name to \(name)", type: .Text, chatId: chat.id)
        }
        
    
        ConversationGridViewModel.shared.selectedSettingsChat?.fullName = name
        ConversationGridViewModel.shared.chats.first(where: {$0.id == chat.id})?.fullName = name
    }
    
    func updateProfileImage(image: UIImage) {
        
        guard let chat = ConversationViewModel.shared.chat else { return }

        MediaUploader.uploadImage(image: image, type: .chat, messageId: UUID().uuidString) { url in
            let chatRef = COLLECTION_CONVERSATIONS.document(chat.id)
            
            Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
                transaction.updateData(["profileImage" : url], forDocument: chatRef)
                return nil
            }) { (_, error) in }
            
            ConversationViewModel.shared.chat?.profileImage = url
            ConversationViewModel.shared.addMessage(text: "Changed the group image", type: .Text, chatId: chat.id)
        }
        

    }
    
    func setChats() {
        guard let chat = ConversationViewModel.shared.chat else { return }
        let currentUserId = AuthViewModel.shared.getUserId()
        let dms = ConversationGridViewModel.shared.chats.filter({$0.isDm})
        
        dms.forEach { dm in
            
            //get user
            if let friend = dm.chatMembers.first(where: { $0.id != currentUserId }) {
                
                //Ensure user is not already in the group
                if !chat.chatMembers.contains(where: { chatMember in
                    chatMember.id == friend.id
                }) {
                    self.chats.append(dm)
                }
            }

        }
       
//        self.chats =
        self.allChats = chats
        
    }
    
    func handleChatSelected(chat: Chat) {

        withAnimation {
            if !addedChats.contains(where: { $0.id == chat.id }) {
                addedChats.append(chat)
            } else {
                addedChats.removeAll(where: { $0.id == chat.id })
            }
        }
    }
    
    func filterUsers(withText text: String) {
                
        withAnimation {
            
            self.chats = self.allChats.filter({
                
                let wordArray = $0.name.components(separatedBy: [" "])
                var contains = false
                
                wordArray.forEach({
                    if $0.starts(with: text) {
                        contains = true
                    }
                })
                
                return contains
            })
        }
    }
    
    func showAllChats() {
        self.chats = self.allChats
    }
    
    func containsChat(_ chat: Chat) -> Bool {
        addedChats.contains(where: { $0.id == chat.id })
    }
    
    func toggleMuteForGroup() {
        
        guard let chat = ConversationViewModel.shared.chat else { return }
        let currentUserId = AuthViewModel.shared.getUserId()
        
        let isMuted = chat.mutedUsers.contains(currentUserId)
                
        if isMuted {
            Messaging.messaging().subscribe(toTopic: chat.id)
            ConversationViewModel.shared.chat?.mutedUsers.removeAll(where: {$0 == currentUserId})
        } else {
            Messaging.messaging().unsubscribe(fromTopic: chat.id)
            ConversationViewModel.shared.chat?.mutedUsers.append(currentUserId)
        }
        
        if isMuted {
            COLLECTION_CONVERSATIONS.document(chat.id).updateData(["mutedUsers":FieldValue.arrayRemove([currentUserId])])
        } else {
            COLLECTION_CONVERSATIONS.document(chat.id).updateData(["mutedUsers":FieldValue.arrayUnion([currentUserId])])
        }
        
    }
    
    
    func muteChat(timeLength: Int) {
        
        guard let chat = ConversationViewModel.shared.chat else { return }

        let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
        var mutedChats = defaults?.object(forKey: "mutedChats") as? [String : Any] ?? [String:Any]()
        
        mutedChats[chat.id] = timeLength
        defaults?.set(mutedChats, forKey: "mutedChats")
    }
    
    func removeFriend(inChat chat: Chat) {
        
        guard let currentUser = AuthViewModel.shared.currentUser else {return}
        guard let friend = chat.chatMembers.first(where: {$0.id != currentUser.id}) else {return}

        AuthViewModel.shared.currentUser?.chats.removeAll(where: {$0.id == chat.id })
        ConversationGridViewModel.shared.chats.removeAll(where: {$0.id == chat.id})
        ConversationGridViewModel.shared.updateFriendsChats()
        removeUserFromDm(userId: currentUser.id, chat: chat)
        removeUserFromDm(userId: friend.id, chat: chat)
        
        
        COLLECTION_USERS.document(friend.id).updateData(["friendRequests": FieldValue.arrayRemove([currentUser.id])])

        //Delete conversation
        
        //***Currently not deleting for security reasons***
        
//        COLLECTION_CONVERSATIONS.document(chat.id).delete()
//        COLLECTION_SAVED_POSTS.document(chat.id).delete()
    }
    
    private func removeUserFromDm(userId: String, chat: Chat) {
        
        COLLECTION_USERS.document(userId).getDocument { snapshot, _ in
            
            if let data = snapshot?.data() {
               
                guard let friend = chat.chatMembers.first(where: {$0.id != userId}) else {return}
                
                var conversations = data["conversations"] as? [[String:Any]] ?? [[String:Any]]()
                conversations.removeAll(where: {$0["id"] as? String == chat.id})

                let userRef = COLLECTION_USERS.document(userId)
                
                Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
                    transaction.updateData(["conversations": conversations,
                                            "friends": FieldValue.arrayRemove([friend.id])], forDocument: userRef)
                    return nil
                }) { (_, error) in
                    if let error = error {
                        print("Error removing user from DM " + error.localizedDescription)
                    }
                }
                
            }
        }
    }
    
    func leaveGroup(chat: Chat) {
        
        guard let currentUser = AuthViewModel.shared.currentUser else {return}

        AuthViewModel.shared.currentUser?.chats.removeAll(where: {$0.id == chat.id })
        ConversationGridViewModel.shared.chats.removeAll(where: {$0.id == chat.id})


        COLLECTION_USERS.document(currentUser.id).getDocument { snapshot, _ in
            
            if let data = snapshot?.data() {
                               
                var conversations = data["conversations"] as? [[String:Any]] ?? [[String:Any]]()
                conversations.removeAll(where: {$0["id"] as? String == chat.id})

                let userRef = COLLECTION_USERS.document(currentUser.id)
                
                
                Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
                    transaction.updateData(["conversations": conversations], forDocument: userRef)
                    return nil
                }) { (_, error) in
                    
                    if let error = error {
                        print("Error removing user from chat " + error.localizedDescription)
                        return
                    }
                    
                    Messaging.messaging().unsubscribe(fromTopic: chat.id)
                    
                    COLLECTION_CONVERSATIONS.document(chat.id).getDocument { snapshot, _ in
                        
                        if let data = snapshot?.data() {
                            
                            var users = data["users"] as? [[String:Any]] ?? [[String:Any]]()
                            
                            users.removeAll(where: {$0["userId"] as? String == currentUser.id })
                            
                            let chatRef = COLLECTION_CONVERSATIONS.document(chat.id)

                            Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
                                transaction.updateData(["users": users], forDocument: chatRef)
                                return nil
                            }) { (_, error) in
                                
                                if let error = error {
                                    print("Error removing user from a chats users field " + error.localizedDescription)
                                    return
                                }
                                
                                ConversationViewModel.shared.addMessage(text: "Left the group", type: .Text, chatId: chat.id)

                            }
                            
                        }
                    }

                }
                
            }
        }

    }
}
