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

struct AudioMessagePlayer {
    var player: AudioPlayer
    let messageId: String
}

class ConversationViewModel: ObservableObject {
    
    var chat: Chat?
    
    var chatId = ""
    var sendingMessageDic = [String:Any]()
    
    @Published var messages = [Message]()
    @Published var savedMessages = [Message]()
    @Published var noSavedMessages = false
    @Published var noMessages = false

    @Published var players = [MessagePlayer]()
    @Published var audioPlayers = [AudioMessagePlayer]()

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
    
    @Published var isSending = false
    @Published var hasSent = false
    
    @Published var index = 0
    @Published var currentPlayer: AVPlayer?
    
    @Published var scrollToBottom = false
    @Published var isPlaying = false

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
        self.setIsSameId(messages: chat.messages)
        self.messages = chat.messages
        self.addListener()
        self.updateNoticationsArray()
        self.chat?.hasUnreadMessage = false
        self.noMessages = false
        ConversationService.updateLastVisited(forChat: chat)
    }
    
    func removeChat() {
        let chat = self.chat!
        ConversationService.updateLastVisited(forChat: chat)
        self.players = [MessagePlayer]()
        self.chat = nil
        self.chatId = ""
        self.messages = [Message]()
        self.removeListener()
        
        withAnimation {
            self.showKeyboard = false
            self.showPhotos = false
            self.showAudio = false
        }
    }
    
    func addPlayer(_ player: MessagePlayer) {
        
        if !self.players.contains(where: {$0.messageId == player.messageId}) {
            self.players.append(player)
        }
    }
    
    func addAudioPlayer(_ player: AudioMessagePlayer) {
        
        if !self.audioPlayers.contains(where: {$0.messageId == player.messageId}) {
            self.audioPlayers.append(player)
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
                message.isSameIdAsPrevMessage = isSameIdAsPrevMessage(prevMessage: lastMessage, currentMessage: message)
                lastMessage.isSameIdAsNextMessage = message.isSameIdAsPrevMessage
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
                        
                        if self.chatId.isEmpty {
                            ConversationGridViewModel.shared.hasSentChat(chat: chat, hasSent: true)
                        } else {
                            self.isSending = false
                            self.hasSent = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.hasSent = false
                            }
                        }
                        self.sendMessageNotification(chat: chat, messageData: data)
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

    func sendMessageNotification(chat: Chat, messageData: [String:Any]) {
        
        guard let currentUser = AuthViewModel.shared.currentUser else { return }
        let userFullName = currentUser.firstName + " " + currentUser.lastName
        let message = Message(dictionary: messageData, id: "")
        
        var data = [String:Any]()

        if chat.isDm {
            
            let chatMember = chat.chatMembers.first(where: {$0.id != currentUser.id})
            data["token"] = chatMember?.fcmToken ?? ""
            data["title"] = message.type == .Text ? userFullName : ""
            data["body"] = message.type == .Text ? (message.text ?? "") : "from \(userFullName)"
            data["metaData"] = ["chatId": chat.id]

        } else {
            
            data["topic"] = chat.id
            data["title"] = message.type == .Text ? "\(userFullName)\nTo \(chat.fullName)" : chat.fullName
            data["body"] = message.type == .Text ? (message.text ?? "") : "from \(userFullName)"
            data["metaData"] = ["chatId": chat.id, "userId": currentUser.id]
        }
        
            
        Functions.functions().httpsCallable("sendNotification").call(data) { (result, error) in }
    }
    
    func setIsSameId(messages: [Message]) {
        
        guard messages.count > 1 else {return}
        for i in 1..<messages.count  {
            
            messages[i].isSameIdAsPrevMessage = isSameIdAsPrevMessage(prevMessage: messages[i - 1],
                                                                      currentMessage: messages[i])
            
            if i == 1 {
                messages[i].isSameIdAsNextMessage = isSameIdAsNextMessage(currentMessage: messages[i - 1],
                                                                          nextMessage: messages[i])
            } else {
                messages[i-1].isSameIdAsNextMessage = messages[i].isSameIdAsPrevMessage
            }
        }
    }
    
    func isSameIdAsPrevMessage(prevMessage: Message, currentMessage: Message) -> Bool {
        return prevMessage.type == .Text && currentMessage.type == .Text && prevMessage.userId == currentMessage.userId
    }
    
    func isSameIdAsNextMessage(currentMessage: Message, nextMessage: Message) -> Bool {
        return currentMessage.type == .Text && nextMessage.type == .Text && currentMessage.userId == nextMessage.userId
    }
    
    func updateIsSaved(atIndex i: Int) {
        self.messages[i].isSaved.toggle()
        self.savedMessages.removeAll(where: {$0.id == self.messages[i].id})
        ConversationService.updateIsSaved(forMessage: self.messages[i], chatId: self.chatId)
    }
    
    func fetchSavedMessages() {
        print("STARTED")
        ConversationService.fetchSavedMessages(forDocWithId: self.chatId) { messages in
            print("FINISHED")
            self.setIsSameId(messages: messages)
            self.savedMessages = messages
            self.noSavedMessages = messages.count == 0
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
                    let messages = ConversationService.getMessagesFromData(data: data)

                    //TODO handle reactions
                    
                    self.messages = messages
                    ConversationViewModel.shared.setIsSameId(messages: self.messages)
                    
                    self.noMessages = messages.count == 0
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
            isSending = true
            addMessage(url: url, text: text, image: image, type: type, isFromPhotoLibrary: isFromPhotoLibrary, shouldExport: shouldExport, chatId: chatId)
        }
    }
    
    func updateNoticationsArray() {
        
        let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
        
        let notificationArray = defaults?.object(forKey: "notifications") as? [String]
        
        if var notificationArray = notificationArray {
            notificationArray.removeAll { notif in
                notif == chatId
            }
            
            defaults?.set(notificationArray, forKey: "notifications")
            UIApplication.shared.applicationIconBadgeNumber = notificationArray.count
        }
    }
    
    func scrollToBottomOfFeed() {
        scrollToBottom.toggle()
    }
}
