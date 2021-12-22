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
    
    static func fetchMessages(forDocWithId docId: String, completion: @escaping(([Message]) -> Void)) {
        var messages = [Message]()
        COLLECTION_CONVERSATIONS.document(docId).getDocument { snapshot, _ in
            if let data = snapshot?.data() {
                let messagesDic = data["messages"] as? [[String:Any]] ?? [[String:Any]]()
                
                messagesDic.forEach { message in
                    let id = message["id"] as? String ?? ""
                    messages.append(Message(dictionary: message, id: id))
                }
                
                completion(messages)
            }
        }
    }
    
    static func updateIsSaved(forMessage message: Message) {
        if message.isSaved {
            COLLECTION_CONVERSATIONS.document("test").updateData(["savedPosts": FieldValue.arrayUnion([message.id])])
            COLLECTION_SAVED_POSTS.document("test").updateData(["posts" : FieldValue.arrayUnion([message.getDictionary()])])
        } else {
            COLLECTION_CONVERSATIONS.document("test").updateData(["savedPosts": FieldValue.arrayRemove([message.id])])
            COLLECTION_SAVED_POSTS.document("test").updateData(["posts" : FieldValue.arrayRemove([message.getDictionary()])])
        }
    }
    
}
