//
//  ConversationService.swift
//  VidChat
//
//  Created by Student on 2021-11-13.
//


import Foundation
import Firebase

struct ConversationService {
    
    static func uploadMessage(toDocWithId docId: String, data: [String:Any], completion: @escaping((Error?) -> Void)) {
        
    
        COLLECTION_CONVERSATIONS.document(docId).updateData(["messages": FieldValue.arrayUnion([data])]) { error in
            completion(error)
        }
//        let convoRef = COLLECTION_CONVERSATIONS.document(docId)
//
//        Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
//            transaction.updateData(["messages" : FieldValue.arrayUnion([data])], forDocument: convoRef)
//            return nil
//        }) { (_, error) in
//            completion(error)
//        }
    }
    
//    static func fetchMessages(forDocWithId docId: String, completion: @escaping(([Message]) -> Void)) {
//        COLLECTION_CONVERSATIONS.document(docId).getDocument { snapshot, _ in
//
//            if let data = snapshot?.data() {
//
//                let messages = self.getMessagesFromData(data: data)
//                completion(messages)
//            }
//        }
//    }
    
    static func fetchSavedMessages(forDocWithId docId: String, completion: @escaping(([Message]) -> Void)) {
        var messages = [Message]()
        COLLECTION_SAVED_POSTS.document(docId).getDocument { snapshot, _ in
            if let data = snapshot?.data() {
                let messagesDic = data["messages"] as? [[String:Any]] ?? [[String:Any]]()
                
                messagesDic.forEach { message in
                    let id = message["id"] as? String ?? ""
                    messages.append(Message(dictionary: message, id: id, isSaved: true))
                }
                ConversationViewModel.shared.setIsSameId(messages: messages)
            }
            
            completion(messages)
        }
    }
    
    static func getMessagesFromData(data: [String:Any]) -> [Message] {
        
        var messages = [Message]()

        let savedMessages = data["savedMessages"] as? [String] ?? [String]()
        let messagesDic = data["messages"] as? [[String:Any]] ?? [[String:Any]]()
        let reactionsDic = data["reactions"] as? [[String:Any]] ?? [[String:Any]]()

        messagesDic.forEach { message in
            let id = message["id"] as? String ?? ""
            let isSaved = savedMessages.contains(id)
            messages.append(Message(dictionary: message, id: id, isSaved: isSaved))
        }
        
        
        reactionsDic.forEach({
            let reactionType = ReactionType.getReactionType(fromString: $0["reactionType"] as? String ?? "")
            let messageId = $0["messageId"] as? String ?? ""
            let reaction = Reaction(messageId: messageId,
                                    username: $0["username"] as? String ?? "",
                                    userId: $0["userId"] as? String ?? "",
                                    reactionType: reactionType)
            
            messages.first(where: {$0.id == messageId})?.reactions.append(reaction)
        })
        
                
        return messages
    }
    
    static func updateIsSaved(forMessage message: Message, chatId: String) {
        if message.isSaved {
            COLLECTION_CONVERSATIONS.document(chatId).updateData(["savedMessages": FieldValue.arrayUnion([message.id])])
            COLLECTION_SAVED_POSTS.document(chatId).updateData(["messages" : FieldValue.arrayUnion([message.getDictionary()])])
        } else {
            COLLECTION_CONVERSATIONS.document(chatId).updateData(["savedMessages": FieldValue.arrayRemove([message.id])])
            COLLECTION_SAVED_POSTS.document(chatId).updateData(["messages" : FieldValue.arrayRemove([message.getDictionary()])])
        }
    }
    
    static func addReaction(reaction: Reaction, chatId: String) {
        COLLECTION_CONVERSATIONS.document(chatId).updateData(["reactions": FieldValue.arrayUnion([reaction.getDictionary()])])
    }
    
    static func removeReaction(reaction: Reaction, chatId: String, completion: @escaping(() -> Void)) {
        COLLECTION_CONVERSATIONS.document(chatId).updateData(["reactions": FieldValue.arrayRemove([reaction.getDictionary()])]) { error in
            if let error = error { print("ERROR: removing reaction \(error.localizedDescription)")}
            completion()
        }
    }
    
    static func updateLastVisited(forChat chat: Chat) {
        
        guard let user = AuthViewModel.shared.currentUser else {return}
        guard let userChatIndex = user.chats.firstIndex(where: { $0.id == chat.id }) else {return}
        
        let now = Timestamp(date: Date())
        user.chats[userChatIndex].lastVisited = now
        user.conversationsDic[userChatIndex]["lastVisited"] = now
        
        let userRef = COLLECTION_USERS.document(user.id)
        
        Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
            transaction.updateData(["conversations" : user.conversationsDic], forDocument: userRef)
            return nil
        }) { (_, error) in }
        
    }
}
