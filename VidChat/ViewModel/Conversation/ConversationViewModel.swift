//
//  ConversationViewModel.swift
//  VidChat
//
//  Created by Student on 2021-10-11.
//

import Foundation
import Firebase
import AVFoundation
import UIKit

struct MessagePlayer {
    let player: AVPlayer
    let messageId: String
}

class ConversationViewModel: ObservableObject {
    
    @Published var messages = [Message]()
    @Published var players = [MessagePlayer]()
    @Published var chatId = "Chat"
    
    //Texting
    @Published var showKeyboard = false
    
    //Audio
    @Published var showAudio = false
    
    //Photos
    @Published var showPhotos = false
    
    //Camera
    @Published var showCamera = false
    
    //Calling
    @Published var showCall = false
    
    
    static let shared = ConversationViewModel()
    
    init() {
        fetchMessages()
        CacheManager.removeOldFiles()
    }
    
    func addMessage(url: URL? = nil, text: String? = nil, image: UIImage? = nil, type: MessageType, shouldExport: Bool = true) {
        
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
            dictionary["url"] = url.absoluteString
            
            if type == .Video {
                dictionary["type"] = "video"
            } else {
                dictionary["type"] = "audio"
            }
        }
        
        if type == .Photo {
            dictionary["type"] = "photo"
        }
        
        if let text = text {
            dictionary["text"] = text
            dictionary["type"] = "text"
        }
        
        let message = Message(dictionary: dictionary, id: id, exportVideo: shouldExport)
        message.image = image
        self.messages.append(message)
        
        if let url = url {
            if type == .Video {
                MediaUploader.shared.uploadVideo(url: url) { newURL in
                    
                    dictionary["url"] = newURL
                    
                    COLLECTION_CONVERSATIONS.document("test").updateData([
                        "messages" : FieldValue.arrayUnion([dictionary])
                    ]) { error in
                        if let error = error {
                            print("DEBUG: error uploading video \(error.localizedDescription)")
                            return
                        }
                        
                        print("Sent video successfully")
                    }
                }
            } else {
                MediaUploader.shared.uploadAudio(url: url) { newUrl in
                    dictionary["url"] = newUrl

                    COLLECTION_CONVERSATIONS.document("test").updateData([
                        "messages" : FieldValue.arrayUnion([dictionary])
                    ]) { error in
                        if let error = error {
                            print("DEBUG: error uploading video \(error.localizedDescription)")
                            return
                        }
                        
                        print("Sent Audio successfully")
                    }
                }
            }
            
        }
        
        if text != nil {
            COLLECTION_CONVERSATIONS.document("test").updateData([
                "messages" : FieldValue.arrayUnion([dictionary])
            ]) { error in
                if let error = error {
                    print("DEBUG: error sending message \(error.localizedDescription)")
                    return
                }
                
                print("Sent message successfully")
            }
        }
        
        if let image = image {
            
            MediaUploader.uploadImage(image: image, type: .photo) { newURL in
                dictionary["url"] = newURL
                
                COLLECTION_CONVERSATIONS.document("test").updateData([
                    "messages" : FieldValue.arrayUnion([dictionary])
                ]) { error in
                    if let error = error {
                        print("DEBUG: error uploading video \(error.localizedDescription)")
                        return
                    }
                    
                    print("Sent Image successfully")
                }
            }
        }
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
