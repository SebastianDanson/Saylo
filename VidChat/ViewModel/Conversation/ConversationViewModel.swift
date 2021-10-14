//
//  ConversationViewModel.swift
//  VidChat
//
//  Created by Student on 2021-10-11.
//

import Foundation
import Firebase

class ConversationViewModel: ObservableObject {
    
    @Published var messages = [Message]()
    @Published var chatId = "Chat"
    
    static let shared = ConversationViewModel()
    
    init() {
        //    fetchMessages()
    }
    
    func addMessage(url: URL? = nil, text: String? = nil, alreadySent: Bool = false) {
        
        //       guard let user = AuthViewModel.shared.currentUser else {return}
        
        let id = NSUUID().uuidString
        
        var dictionary = [
            "id":id,
            "chatId": self.chatId,
            "userProfileImageUrl":"",
            "username": "Seb",
            "timestamp": Timestamp(date: Date())
        ] as [String: Any]
        
        if let url = url {
            dictionary["videoUrl"] = url.absoluteString
            dictionary["type"] = "video"
        }
        
        if let text = text {
            dictionary["text"] = text
            dictionary["type"] = "text"
        }
        
        if !alreadySent {
            let message = Message(dictionary: dictionary, id: id, hasCroppedVideo: !CameraViewModel.shared.hasSentWithoutCrop)
            self.messages.append(message)
        }
        
//        if !CameraViewModel.shared.hasSentWithoutCrop, let url = url {
//            MediaUploader.shared.uploadVideo(url: url) { newURL in
//                
//                dictionary["videoUrl"] = newURL
//                
//                COLLECTION_CONVERSATIONS.document("test").updateData([
//                    "messages" : FieldValue.arrayUnion([dictionary])
//                ]) { error in
//                    if let error = error {
//                        print("DEBUG: error uploading video \(error.localizedDescription)")
//                        return
//                    }
//                    
//                    print("Sent video successfully")
//                }
//            }
//        }
//        
//        if text != nil {
//            COLLECTION_CONVERSATIONS.document("test").updateData([
//                "messages" : FieldValue.arrayUnion([dictionary])
//            ]) { error in
//                if let error = error {
//                    print("DEBUG: error sending message \(error.localizedDescription)")
//                    return
//                }
//                
//                print("Sent message successfully")
//            }
//        }
    }
    
    func fetchMessages() {
        COLLECTION_CONVERSATIONS.document("test").getDocument { snapshot, _ in
            if let data = snapshot?.data() {
                let messages = data["messages"] as? [[String:Any]] ?? [[String:Any]]()
                
                messages.forEach { message in
                    let id = message["id"] as? String ?? ""
                    self.messages.append(Message(dictionary: message, id: id))
                }
            }
        }
    }
}
