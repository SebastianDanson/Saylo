//
//  NewConversationViewModel.swift
//  Saylo
//
//  Created by Sebastian Danson on 2021-12-28.
//


import SwiftUI
import Firebase

class NewConversationViewModel: ObservableObject {
    
    @Published var isCreatingNewChat: Bool = false
    @Published var isSearching: Bool = true
    @Published var isTypingName: Bool = false
    @Published var addedChats = [Chat]()

    static let shared = NewConversationViewModel()
    
    private init() {}
    
    func handleChatSelected(chat: Chat) {
        
        withAnimation {
            if !addedChats.contains(where: { $0.id == chat.id }) {
                addedChats.append(chat)
            } else {
                addedChats.removeAll(where: { $0.id == chat.id })
            }
        }
    }
    
    func containsChat(_ chat: Chat) -> Bool {
        addedChats.contains(where: { $0.id == chat.id })
    }
    
    
    func removeDuplicateChatMembers(chatMembers: [ChatMember]) -> [ChatMember] {
        
        var chatMemberSet = [ChatMember]()
                
        chatMembers.forEach { member in
            if !chatMemberSet.contains(where: { $0.id == member.id }) {
                chatMemberSet.append(member)
            }
        }
        
        return chatMemberSet
    }
    
    func createChat(name: String) {
        

        guard let user = AuthViewModel.shared.currentUser else {return}
        
        
        var ref: DocumentReference? = nil
      
        
        var chatMembers = [ChatMember]()
        addedChats.forEach({chatMembers.append(contentsOf: $0.chatMembers)})
        
        chatMembers = removeDuplicateChatMembers(chatMembers: chatMembers)
        
        

        
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
       
                
        //create dictionary to send to DB
        let data = [
            "admin": [user.id],
            "name": name,
            "users":userInfo,
        ] as [String : Any]
        
        
        //Add group info to DB
        
        ref = COLLECTION_CONVERSATIONS.addDocument(data: data) { _ in
            
            //Once finished add the group data to the user doc
            
            guard let id = ref?.documentID else {return}
            
            let chat = Chat(dictionary: data, id: id)
            
            ConversationViewModel.shared.addMessage(text: "Created the group", type: .Text, chatId: id)
            ConversationViewModel.shared.setChat(chat: chat)
            
            ConversationGridViewModel.shared.allChats.append(chat)
            ConversationGridViewModel.shared.chats.append(chat)
            ConversationGridViewModel.shared.showConversation = true

            COLLECTION_SAVED_POSTS.document(id).setData([:])
            
            let groupData = ["lastVisited": Timestamp(date: Date()),
                             "notificationsEnabled": true,
                             "id":id] as [String: Any]
            
            Messaging.messaging().subscribe(toTopic: id)

            var fcmTokens = [String]()
            chatMembers.forEach({fcmTokens.append($0.fcmToken)})
            
            let data = ["tokens": fcmTokens, "chatId": id] as [String : Any]
            Functions.functions().httpsCallable("subscribeToTopic").call(data) { (result, error) in}
            
            //Update Current User doc with new group
            COLLECTION_USERS.document(user.id).updateData(["conversations": FieldValue.arrayUnion([groupData])])

            //Update other users docs
            chatMembers.forEach { chatMember in
                COLLECTION_USERS.document(chatMember.id).updateData(["conversations": FieldValue.arrayUnion([groupData])])
            }
        }
    }
    
    func getSelectedChat() -> Chat? {
                
        let allChats = ConversationGridViewModel.shared.allChats
        
        var chatMembers = [ChatMember]()
        
        addedChats.forEach({chatMembers.append(contentsOf: $0.chatMembers)})
        
        chatMembers = removeDuplicateChatMembers(chatMembers: chatMembers)
        chatMembers = sortedChatMembers(chatMembers)
                
        for chat in allChats {
            
            if hasTheSameChatMembers(members1: chatMembers, members2: sortedChatMembers(chat.chatMembers)) {
                return chat
            }
        }
        
        return nil
    }
    
    func hasTheSameChatMembers(members1: [ChatMember], members2: [ChatMember]) -> Bool {
        
        print(members1.count, members2.count)
        if members1.count != members2.count {
            return false
        }
                
        
        for i in 0..<members1.count {
                        
            if members1[i].id != members2[i].id {
                return false
            }
            
        }
            
         return true
    }
    
    func sortedChatMembers(_ members: [ChatMember]) -> [ChatMember] {
        return members.sorted(by: {$0.id < $1.id})
    }
}
