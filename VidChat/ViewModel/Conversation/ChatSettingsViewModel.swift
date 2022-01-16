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
        guard let chat = ConversationViewModel.shared.chat else { return }
        
        let chatRef = COLLECTION_CONVERSATIONS.document(chat.id)
        
        Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
            transaction.updateData(["name" : name], forDocument: chatRef)
            return nil
        }) { (_, error) in }
        
    }
    
    func updateProfileImage(image: UIImage) {
        
        guard let chat = ConversationViewModel.shared.chat else { return }

        MediaUploader.uploadImage(image: image, type: .chat, messageId: UUID().uuidString) { url in
            let chatRef = COLLECTION_CONVERSATIONS.document(chat.id)
            
            Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
                transaction.updateData(["profileImage" : url], forDocument: chatRef)
                return nil
            }) { (_, error) in }
        }
    }
    
    func setChats() {
        self.chats = ConversationGridViewModel.shared.chats.filter({$0.isDm})
        self.allChats = chats
        
    }
    
    func handleChatSelected(chat: Chat) {
        print("@@@")
        withAnimation {
            if !addedChats.contains(where: { $0.id == chat.id }) {
                print("AAADED")
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
}
