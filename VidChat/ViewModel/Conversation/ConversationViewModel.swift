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
import SwiftUI

struct MessagePlayer {
    let player: AVPlayer
    let messageId: String
}

class ConversationViewModel: ObservableObject {
    
    var chat: Chat?
    
    var chatId = ""
    var sendingMessageDic = [String:Any]()
    
    @Published var messages = [Message]()
    @Published var savedMessages = [Message]()
    
    @Published var players = [MessagePlayer]()
    //    @Published var chatId = "Chat"
    
    
    @Published var showConversationPlayer = false
    
    @Published var showSavedPosts = false
    
    @Published var showImageDetailView = false
    @Published var selectedUrl: String?
    @Published var selectedImage: UIImage?
    
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
    
    private init() {
        //CacheManager.removeOldFiles()
        
        //TODO test removeing old files
    }
     
    func setChat(chat: Chat) {
        self.chat = chat
        self.chatId = chat.id
        self.messages = chat.messages
        self.messages.forEach({print($0.id)})
    }
    
    func addMessage(url: URL? = nil, text: String? = nil, image: UIImage? = nil, type: MessageType, isFromPhotoLibrary: Bool = true,shouldExport: Bool = true) {
        
        //       guard let user = AuthViewModel.shared.currentUser else {return}
        
        let id = NSUUID().uuidString
        
        var dictionary = [
            "id":id,
            "chatId": chatId,
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
            
            if !isFromPhotoLibrary {
                dictionary["isFromPhotoLibrary"] = false
            }
        }
        
        if let text = text {
            dictionary["text"] = text
            dictionary["type"] = "text"
        }
        
        if self.chatId != "" {
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
                self.atomicallyUploadMessage(toDocWithId: self.chatId, messageId: id)
            } else if let image = image {
                MediaUploader.uploadImage(image: image, type: .photo) { newURL in
                    self.mediaFinishedUploading(id: id, newUrl: newURL)
                }
            }
        } else {
            self.sendingMessageDic = dictionary
            withAnimation {
                ConversationGridViewModel.shared.isSelectingChats = true
                ConversationGridViewModel.shared.cameraViewZIndex = 1
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
        self.atomicallyUploadMessage(toDocWithId: self.chatId, messageId: id)
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
        ConversationService.fetchMessages(forDocWithId: self.chatId) { messages in
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
    
    func updateIsSaved(atIndex i: Int) {
        self.messages[i].isSaved.toggle()
        self.savedMessages.removeAll(where: {$0.id == self.messages[i].id})
        ConversationService.updateIsSaved(forMessage: self.messages[i], chatId: self.chatId)
    }
    
    func fetchSavedMessages() {
        ConversationService.fetchSavedMessages(forDocWithId: self.chatId) { messages in
            self.setIsSameAsPrevId(messages: messages)
            self.savedMessages = messages
        }
    }
    
    func addReactionToMessage(withId id: String, reaction: Reaction) {
        if let message = self.messages.first(where: {$0.id == id}) {
            message.reactions.append(reaction)
            ConversationService.addReaction(reaction: reaction,  chatId: self.chatId)
        }
    }
    
    func removeReactionFromMessage(withId id: String, reaction: Reaction, completion: @escaping(() -> Void)) {
        if let message = self.messages.first(where: {$0.id == id}) {
            message.reactions.removeAll(where: {$0.userId == reaction.userId})
            ConversationService.removeReaction(reaction: reaction, chatId: self.chatId) {
                completion()
            }
        }
    }
}
