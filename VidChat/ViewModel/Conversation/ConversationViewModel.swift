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
    var player: AVPlayer
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
    @Published var isRecordingAudio = false
    @Published var audioProgress = 0.0

    //Photos
    @Published var showPhotos = false
    
    //TODO ensure that this shows 3 vertical photos when on chat and 2 otherwise
    @Published var photoBaseHeight = PHOTO_PICKER_SMALL_HEIGHT
    
    //Camera
    @Published var showCamera = false
    
    //Calling
    @Published var showCall = false
    
    private var uploadQueue = [[String:Any]]()
    private var isUploadingMessage = false
    private var listener: ListenerRegistration?
    
    var selectedChat: Chat?
    var hasSelectedAssets = false

    static let shared = ConversationViewModel()
    
    private init() {
        //CacheManager.removeOldFiles()
        
        //TODO test removeing old files
    }
    
    func setChat(chat: Chat) {
        self.chat = chat
        self.chatId = chat.id
        self.setIsSameAsPrevId(messages: chat.messages)
        self.messages = chat.messages
        self.addListener()
    }
    
    func removeChat() {
        self.players = [MessagePlayer]()
        self.chat = nil
        self.chatId = ""
        self.messages = [Message]()
        self.removeListener()
    }
    
    func addPlayer(_ player: MessagePlayer) {
        
        if !self.players.contains(where: {$0.messageId == player.messageId}) {
            self.players.append(player)
        }
    }
    
    func addMessage(url: URL? = nil, text: String? = nil, image: UIImage? = nil, type: MessageType, isFromPhotoLibrary: Bool = true,shouldExport: Bool = true, chatId: String? = nil) {
        
        //       guard let user = AuthViewModel.shared.currentUser else {return}
        
        let id = NSUUID().uuidString
        
        let chatId = chatId ?? self.chatId
        
        var dictionary = [
            "id":id,
            "chatId": chatId,
            "userProfileImageUrl":AuthViewModel.shared.currentUser?.profileImageUrl ?? "",
            "username": AuthViewModel.shared.currentUser?.firstName ?? "",
            "timestamp": Timestamp(date: Date()),
            "userId": AuthViewModel.shared.currentUser?.id
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
        
        if chatId != "" {
            
            if !self.chatId.isEmpty {
            let message = Message(dictionary: dictionary, id: id, exportVideo: shouldExport)
            message.image = image
            
            if let lastMessage = messages.last {
                message.isSameIdAsPrevMessage = getIsSameAsPrevId(prevMessage: lastMessage, nextMessage: message)
            }
            self.messages.append(message)
            }
            
            uploadQueue.append(dictionary)
            
            if let url = url {
                if type == .Video {
                    MediaUploader.shared.uploadVideo(url: url) { newURL in
                        self.mediaFinishedUploading(chatId: chatId, messageId: id, newUrl: newURL)
                    }
                } else {
                    MediaUploader.shared.uploadAudio(url: url) { newURL in
                        self.mediaFinishedUploading(chatId: chatId, messageId: id, newUrl: newURL)
                    }
                }
            } else if text != nil {
                self.atomicallyUploadMessage(toDocWithId: chatId, messageId: id)
            } else if let image = image {
                MediaUploader.uploadImage(image: image, type: .photo) { newURL in
                    self.mediaFinishedUploading(chatId: chatId, messageId: id, newUrl: newURL)
                }
            }
        } 
    }
    
    func sendCameraMessage(chatId: String?, chat: Chat?) {
        let cameraViewModel = CameraViewModel.shared
        addMessage(url: cameraViewModel.videoUrl, image: cameraViewModel.photo,
                   type: cameraViewModel.videoUrl == nil ? .Photo : .Video,
                   isFromPhotoLibrary: false, shouldExport: false, chatId: chatId)
        
        
        if let chat = chat {
            ConversationGridViewModel.shared.isSendingChat(chat: chat, isSending: true)
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
    
    func mediaFinishedUploading(chatId: String, messageId: String, newUrl: String) {
        let index = uploadQueue.firstIndex(where:{$0["id"] as? String == messageId})
        self.uploadQueue[index!]["url"] = newUrl
        self.atomicallyUploadMessage(toDocWithId: chatId, messageId: messageId)
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
                    if let chat = ConversationGridViewModel.shared.chats.first(where: {$0.id == docId}) {
                        ConversationGridViewModel.shared.hasSentChat(chat: chat, hasSent: true)
                    }
                }
                
                self.isUploadingMessage = false
                self.uploadQueue.remove(at: 0)
                
                if self.uploadQueue.count > 0, let chatId = self.uploadQueue.first?["chatId"] as? String {
                    self.uploadMessage(toDocWithId: chatId)
                }
            }
        }
    }
    
//    func fetchMessages() {
//        ConversationService.fetchMessages(forDocWithId: self.chatId) { messages in
//            self.setIsSameAsPrevId(messages: messages)
//            self.messages = messages
//        }
//    }
    
    func setIsSameAsPrevId(messages: [Message]) {
        guard messages.count > 1 else {return}
        for i in 1..<messages.count  {
            messages[i].isSameIdAsPrevMessage = getIsSameAsPrevId(prevMessage: messages[i - 1],
                                                                  nextMessage: messages[i])
        }
    }
    
    func getIsSameAsPrevId(prevMessage: Message, nextMessage: Message) -> Bool {
        return prevMessage.type == .Text && nextMessage.type == .Text && prevMessage.userId == nextMessage.userId
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
    
    func addListener() {
        listener = COLLECTION_CONVERSATIONS.document(chatId)
            .addSnapshotListener { snapshot, _ in
                if let data = snapshot?.data() {
                    print("1")
                    let messages = ConversationService.getMessagesFromData(data: data)

                    //TODO handle reactions
                    
                    self.messages = messages
                }
            }
        
        //TODO ensure mic symbol is not in the top left of the screen of ur phone when ur not on the app
    }
    
    func removeListener() {
        listener?.remove()
    }
    
    func pauseVideos() {
        players.forEach({$0.player.pause()})
    }
    
    func sendMessage(url: URL? = nil, text: String? = nil, image: UIImage? = nil, type: MessageType, isFromPhotoLibrary: Bool = true,shouldExport: Bool = true, chatId: String? = nil) {
        
        if self.chatId.isEmpty {
            
            ConversationGridViewModel.shared.selectedChats.forEach { chat in
                addMessage(url: url, text: text, image: image, type: type, isFromPhotoLibrary: isFromPhotoLibrary, shouldExport: shouldExport, chatId: chat.id)
                ConversationGridViewModel.shared.isSendingChat(chat: chat, isSending: true)
            }

        } else {
            addMessage(url: url, text: text, image: image, type: type, isFromPhotoLibrary: isFromPhotoLibrary, shouldExport: shouldExport, chatId: chatId)
        }
    }
}
