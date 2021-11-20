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
    
    private var uploadQueue = [[String:Any]]()
    private var isUploadingMessage = false
    
    static let shared = ConversationViewModel()
    
    init() {
        fetchMessages()
        //CacheManager.removeOldFiles()
        
        //TODO test removeing old files
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
                dictionary["userStoredUrl"] = url.absoluteString
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
        
        if let lastMessage = messages.last {
            message.isSameIdAsPrevMessage = getIsSameAsPrevId(prevMessage: lastMessage, nextMessage: message)
        }
        self.messages.append(message)
        uploadQueue.append(dictionary)

        if let url = url {
            if type == .Video {
                MediaUploader.shared.uploadVideo(url: url) { newURL in
                    self.mediaFinishedUploading(id: id, newUrl: newURL)
                }
            } else {
                MediaUploader.shared.uploadAudio(url: url) { newURL in
                    self.mediaFinishedUploading(id: id, newUrl: newURL)
                }
            }
        } else if text != nil {
            self.atomicallyUploadMessage(toDocWithId: "test", messageId: id)
        } else if let image = image {
            MediaUploader.uploadImage(image: image, type: .photo) { newURL in
                self.mediaFinishedUploading(id: id, newUrl: newURL)
            }
        }
    }
    
    func atomicallyUploadMessage(toDocWithId id: String, messageId: String) {
        let index = uploadQueue.firstIndex(where:{$0["id"] as? String == messageId})
        if index == 0 {
            uploadMessage(toDocWithId: id)
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.atomicallyUploadMessage(toDocWithId: id, messageId: messageId)
        }
    }
    
    func mediaFinishedUploading(id: String, newUrl: String) {
        let index = uploadQueue.firstIndex(where:{$0["id"] as? String == id})
        self.uploadQueue[index!]["url"] = newUrl
        self.atomicallyUploadMessage(toDocWithId: "test", messageId: id)
    }
    
    func uploadMessage(toDocWithId docId: String) {
        if !isUploadingMessage {
            self.isUploadingMessage = true
            let data = uploadQueue[0]
            ConversationService.uploadMessage(toDocWithId: docId, data: data) { error in
                if let error = error {
                    print("ERROR uploading message \(error.localizedDescription)")
                } else {
                    print("Message uploaded successfully")
                }
                
                self.isUploadingMessage = false
                self.uploadQueue.remove(at: 0)
                
                if self.uploadQueue.count > 0 {
                    self.uploadMessage(toDocWithId: docId)
                }
            }
        }
    }
    
    func fetchMessages() {
        ConversationService.fetchMessages(forDocWithId: "test") { messages in
            self.setIsSameAsPrevId(messages: messages)
            self.messages = messages
        }
    }
    
    func setIsSameAsPrevId(messages: [Message]) {
        guard messages.count > 1 else {return}
        for i in 1..<messages.count  {
            messages[i].isSameIdAsPrevMessage = getIsSameAsPrevId(prevMessage: messages[i - 1],
                                                                  nextMessage: messages[i])
        }
    }
    
    func getIsSameAsPrevId(prevMessage: Message, nextMessage: Message) -> Bool {
        return prevMessage.type == .Text && nextMessage.type == .Text
        && prevMessage.userId == nextMessage.userId
    }
}
