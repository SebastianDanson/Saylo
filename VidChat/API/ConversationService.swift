//
//  ConversationService.swift
//  Saylo
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
    }
    
    
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
    
    static func getMessagesFromData(data: [String:Any], chatId: String) -> [Message] {
        
        var messages = [Message]()

        let savedMessages = data["savedMessages"] as? [[String:Any]] ?? [[String:Any]]()
        let messagesDic = data["messages"] as? [[String:Any]] ?? [[String:Any]]()
        let reactionsDic = data["reactions"] as? [[String:Any]] ?? [[String:Any]]()

        var shouldRemoveMessages = false
        
        messagesDic.forEach { message in
            let id = message["id"] as? String ?? ""
             
            let savedData = savedMessages.first(where: { $0["messageId"] as? String == id })
            let isSaved = savedData != nil
            let savedByUid = savedData?["userId"] as? String ?? ""
            
            let message = Message(dictionary: message, id: id, isSaved: isSaved, savedByUid: savedByUid)
            
            if Int(message.timestamp.dateValue().timeIntervalSince1970) > Int(Date().timeIntervalSince1970) - 86400 {
                messages.append(message)
            } else {
                shouldRemoveMessages = true
            }
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
        
        if shouldRemoveMessages {
            removeOldMessages(chatData: data, chatId: chatId)
        }
        
                
        return messages
    }
    
    static func updateIsSaved(forMessage message: Message, chatId: String) {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let data = ["messageId":message.id, "userId":uid]
        
        if message.isSaved {
            COLLECTION_CONVERSATIONS.document(chatId).updateData(["savedMessages": FieldValue.arrayUnion([data])])
            COLLECTION_SAVED_POSTS.document(chatId).updateData(["messages" : FieldValue.arrayUnion([message.getDictionary()])])
        } else {
            COLLECTION_CONVERSATIONS.document(chatId).updateData(["savedMessages": FieldValue.arrayRemove([data])])
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
    
   static func removeOldMessages(chatData data: [String:Any], chatId: String) {
        
        let messagesDic = data["messages"] as? [[String:Any]] ?? [[String:Any]]()
        var reactionsDic = data["reactions"] as? [[String:Any]] ?? [[String:Any]]()
        var savedMessagesDic = data["savedMessages"] as? [[String:Any]] ?? [[String:Any]]()

        var updatedMessageDic = [[String:Any]]()

        for messageDic in messagesDic {
            if let timeStamp = messageDic["timestamp"] as? Timestamp {
                if Int(timeStamp.dateValue().timeIntervalSince1970) > Int(Date().timeIntervalSince1970) - 86400 {
                    
                    updatedMessageDic.append(messageDic)
                } else {
                    
                    let id = messageDic["id"] as? String ?? ""
                    let message = Message(dictionary: messageDic, id: id)
                    reactionsDic.removeAll(where: {$0["messageId"] as? String == id})
                    savedMessagesDic.removeAll(where: {$0["messageId"] as? String == id})
                    
                    if message.type != .Text && !message.isSaved {
                        if message.type == .Video {
                            
                           let storageRef = UploadType.video.getFilePath(messageId: id)
                            storageRef.delete { error in
                                if let error = error {
                                    print("ERROR deleting storage ref: \(error.localizedDescription)")
                                }
                            }
                        } else if message.type == .Audio {
                            let storageRef = UploadType.audio.getFilePath(messageId: id)
                             storageRef.delete { error in
                                 if let error = error {
                                     print("ERROR deleting storage ref: \(error.localizedDescription)")
                                 }
                             }
                        } else if message.type == .Photo {
                            let storageRef = UploadType.photo.getFilePath(messageId: id)
                             storageRef.delete { error in
                                 if let error = error {
                                     print("ERROR deleting storage ref: \(error.localizedDescription)")
                                 }
                             }
                        }
                    }
                }
            }
        }
        
        let chatRef = COLLECTION_CONVERSATIONS.document(chatId)
        
        Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
            transaction.updateData(["messages" : updatedMessageDic, "reactions":reactionsDic, "savedMessaged":savedMessagesDic], forDocument: chatRef)
            return nil
        }) { (_, error) in }
        
    }
}
