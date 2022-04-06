//
//  ConversationViewModel.swift
//  Saylo
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
    
    @Published var index: Int = 0 {
        didSet {
            self.hasChanged.toggle()
        }
    }
    
    @Published var hasChanged = false
    @Published var chatId = ""
    @Published var isTyping = false
    var sendingMessageDic = [String:Any]()
    
    @Published var messages = [Message]() {
        didSet {
            handleMessagesSet()
        }
    }
    @Published var savedMessages = [Message]()
    @Published var noSavedMessages = false
    @Published var noMessages = false
    @Published var showUnreadMessages = false
    @Published var seenLastPost = [String]()
    
    @Published var videoLength = 0.0
    @Published var players = [MessagePlayer]()
    @Published var audioPlayers = [AudioMessagePlayer]()
    @Published var isTwoTimesSpeed = false {
        didSet {
            ConversationViewModel.shared.currentPlayer?.rate = isTwoTimesSpeed ? 2 : 1
        }
    }
    
    @Published var selectedMessageIndexes = [Int]()
    @Published var uploadProgress = 0.0
    
    @Published var showConversationPlayer = false
    
    @Published var showSavedPosts = false
    
    @Published var showImageDetailView = false
    @Published var selectedUrl: String?
    @Published var selectedImage: UIImage?
    @Published var showPlaybackControls = false
    
    //Texting
    @Published var showKeyboard = false
    
    //Audio
    @Published var showAudio = false
    @Published var isRecordingAudio = false
    @Published var audioProgress = 0.0
    
    //Photos
    @Published var showPhotos = false
    
    //Camera
    @Published var showCamera = false
    
    //Calling
    @Published var showCall = false
    
    
    var currentPlayer: AVPlayer?
    
    @Published var scrollToBottom = false
    @Published var isPlaying = true
    
    @Published var hideChat = false
    
    private var uploadQueue = [[String:Any]]()
    private var isUploadingMessage = false
    private var listener: ListenerRegistration?
    
    var selectedChat: Chat?
    var hasSelectedAssets = false
    var isShowingReactions = false
    static let shared = ConversationViewModel()
    
    private init() {
        CacheManager.removeOldFiles()
    }
    
    
    func setChat(chat: Chat) {
        
        self.selectedMessageIndexes.removeAll()
        self.chat = chat
        self.chatId = chat.id
        
        let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
        defaults?.set(chat.id, forKey: "selectedChatId")
        self.addListener()
        self.messages = chat.messages
        self.index = max(0, chat.messages.count - 1)
        ConversationService.updateLastVisited(forChat: chat)
        chat.hasUnreadMessage = false
        
        print(chat.id, "IDIDI")
        //        self.setIsSameId(messages: chat.messages)
        //        self.seenLastPost = chat.seenLastPost
        //        self.chat?.hasUnreadMessage = false
        //        self.noMessages = false
    }
    
    func removeChat() {
        
        if let chat = chat {
            ConversationService.updateLastVisited(forChat: chat)
            if let index = ConversationGridViewModel.shared.chats.firstIndex(where: {$0.id ==  chat.id}) {
                ConversationGridViewModel.shared.chats[index].lastReadMessageIndex = chat.messages.count - 1
            }
        }
        
        self.currentPlayer = nil
        self.players = [MessagePlayer]()
        
        //        self.chat = nil
        //        self.chatId = ""
        //        self.messages = [Message]()
        self.removeListener()
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
    
    func addMessage(url: URL? = nil, text: String? = nil, image: UIImage? = nil, type: MessageType, isFromPhotoLibrary: Bool = false,shouldExport: Bool = true, chatId: String? = nil, hasNotification: Bool = true, isAcceptingFrienRequest: Bool = false) {
        
        
        if let chat = ConversationViewModel.shared.chat {
            chat.isSending = true
        }
        
        let id = NSUUID().uuidString
        
        let chatId = chatId ?? self.chatId
        
        var dictionary = [
            "id":id,
            "chatId": chatId,
            "userProfileImage":AuthViewModel.shared.currentUser?.profileImage ?? "",
            "username": isAcceptingFrienRequest ? "" : AuthViewModel.shared.currentUser?.firstName ?? "",
            "timestamp": Timestamp(date: Date()),
            "userId": isAcceptingFrienRequest ? "" : AuthViewModel.shared.currentUser?.id
        ] as [String: Any]
        
        if let url = url {
            
            dictionary["url"] = url.absoluteString
            
            if type == .Video {
                
                if !isFromPhotoLibrary {
                    dictionary["userStoredUrl"] = url.absoluteString
                }
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
        
        if isFromPhotoLibrary {
            dictionary["isFromPhotoLibrary"] = true
        }
        
        let message = Message(dictionary: dictionary, id: id, exportVideo: shouldExport)
        
        let messageParams = ["userId":AuthViewModel.shared.currentUser?.id, "type": message.type.getString()]
        Flurry.logEvent("MessageSent", withParameters: messageParams)
        
        if chatId != "" {
            
            if !self.chatId.isEmpty {
                
                let message = Message(dictionary: dictionary, id: id, exportVideo: shouldExport)
                message.image = image
                
                if let lastMessage = messages.last {
                    message.isSameIdAsPrevMessage = isSameIdAsPrevMessage(prevMessage: lastMessage, currentMessage: message)
                    lastMessage.isSameIdAsNextMessage = message.isSameIdAsPrevMessage
                }
                
                
                DispatchQueue.main.async {
                    self.messages.append(message)
                }
                
            }
            
            for i in 0..<ConversationGridViewModel.shared.chats.count {
                if ConversationGridViewModel.shared.chats[i].id == chatId {
                    DispatchQueue.main.async {
                        ConversationGridViewModel.shared.chats[i].messages.append(message)
                    }
                }
            }
            
            uploadQueue.append(dictionary)
            
            if let url = url {
                
                if type == .Video {
                    
                    MediaUploader.shared.uploadVideo(url: url, messageId: id, isFromPhotoLibrary: isFromPhotoLibrary) { newUrl in
                        self.mediaFinishedUploading(chatId: chatId, messageId: id, newUrl: newUrl)
                    }
                    
                } else {
                    
                    
                    MediaUploader.shared.uploadAudio(url: url, messageId: id) { newUrl in
                        self.mediaFinishedUploading(chatId: chatId, messageId: id, newUrl: newUrl)
                    }
                    
                }
            } else if text != nil {
                self.atomicallyUploadMessage(toDocWithId: chatId, messageId: id, hasNotification: hasNotification)
            } else if let image = image {
                MediaUploader.uploadImage(image: image, type: .photo, messageId: id) { newURL in
                    self.mediaFinishedUploading(chatId: chatId, messageId: id, newUrl: newURL)
                }
            }
        }
    }
    
    func sendCameraMessage(chatId: String?, chat: Chat?) {
        let cameraViewModel = MainViewModel.shared
        addMessage(url: cameraViewModel.videoUrl, image: cameraViewModel.photo,
                   type: cameraViewModel.videoUrl == nil ? .Photo : .Video,
                   isFromPhotoLibrary: false, shouldExport: false, chatId: chatId)
        
        
        if let chat = chat, self.chat == nil {
            ConversationGridViewModel.shared.isSendingChat(chat: chat, isSending: true)
        }
    }
    
    
    func atomicallyUploadMessage(toDocWithId id: String, messageId: String, hasNotification: Bool) {
        let index = uploadQueue.firstIndex(where:{$0["id"] as? String == messageId})
        if index == 0 {
            uploadMessage(toDocWithId: id, hasNotification: hasNotification)
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.atomicallyUploadMessage(toDocWithId: id, messageId: messageId, hasNotification: hasNotification)
        }
    }
    
    func mediaFinishedUploading(chatId: String, messageId: String, newUrl: String) {
        
        if let index = uploadQueue.firstIndex(where:{$0["id"] as? String == messageId}) {
            self.uploadQueue[index]["url"] = newUrl
            self.atomicallyUploadMessage(toDocWithId: chatId, messageId: messageId, hasNotification: true)
        }
    }
    
    func uploadMessage(toDocWithId docId: String, hasNotification: Bool) {
        if !isUploadingMessage {
            self.isUploadingMessage = true
            let data = uploadQueue[0]
            
            
            ConversationService.uploadMessage(toDocWithId: docId, data: data) { error in
                if let error = error {
                    print("ERROR uploading message \(error.localizedDescription)")
                } else {
                    
                    withAnimation {
                        ConversationGridViewModel.shared.sortChats()
                    }
                    
                    if let chat = ConversationGridViewModel.shared.chats.first(where: {$0.id == docId}) {
                        
                        ConversationGridViewModel.shared.hasSentChat(chat: chat, hasSent: true)
                        
                        if hasNotification {
                            self.sendMessageNotification(chat: chat, messageData: data)
                        }
                    }
                }
                
                self.isUploadingMessage = false
                self.uploadQueue.remove(at: 0)
                
                if self.uploadQueue.count > 0, let chatId = self.uploadQueue.first?["chatId"] as? String {
                    self.uploadMessage(toDocWithId: chatId, hasNotification: hasNotification)
                }
            }
        }
    }
    
    func cancelUpload() {
        
        if let chat = ConversationViewModel.shared.chat {
            chat.isSending = true
            self.uploadQueue.removeAll(where: {$0["chatId"] as? String == chat.id})
            ConversationGridViewModel.shared.hasSentChat(chat: chat, hasSent: false)
        }
    }
    
    func sendMessageNotification(chat: Chat, messageData: [String:Any]) {
        
        guard let currentUser = AuthViewModel.shared.currentUser else { return }
        
        var messageData = messageData
        let userFullName = currentUser.firstName + " " + currentUser.lastName
        let message = Message(dictionary: messageData, id: "")
        messageData["timestamp"] = Int(message.timestamp.dateValue().timeIntervalSince1970)
        var data = [String:Any]()
        
        if chat.isDm {
            
            let chatMember = chat.chatMembers.first(where: {$0.id != currentUser.id})
            data["token"] = chatMember?.fcmToken ?? ""
            data["title"] = userFullName
            data["body"] = message.type == .Text ? (message.text ?? "") : "Sent a Saylo"
            data["metaData"] = ["chatId": chat.id, "messageData":messageData]
            
        } else {
            
            data["topic"] = chat.id
            data["title"] = message.type == .Text ? "\(userFullName)\nTo \(chat.fullName)" : chat.fullName
            data["body"] = message.type == .Text ? (message.text ?? "") : "from \(userFullName)"
            data["metaData"] = ["chatId": chat.id, "userId": currentUser.id, "messageData":messageData]
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
        return prevMessage.type == .Text && currentMessage.type == .Text && prevMessage.userId == currentMessage.userId && isWithin30min(message1: prevMessage,
                                                                                                                                         message2: currentMessage)
    }
    
    func isSameIdAsNextMessage(currentMessage: Message, nextMessage: Message) -> Bool {
        return currentMessage.type == .Text && nextMessage.type == .Text && currentMessage.userId == nextMessage.userId && isWithin30min(message1: currentMessage,
                                                                                                                                         message2: nextMessage)
    }
    
    func isWithin30min(message1: Message, message2: Message) -> Bool {
        abs(message1.timestamp.dateValue().timeIntervalSince1970 - message2.timestamp.dateValue().timeIntervalSince1970) < 1800
    }
    
    func updateIsSaved(atIndex i: Int) {
        self.messages[i].isSaved.toggle()
        self.savedMessages.removeAll(where: {$0.id == self.messages[i].id})
        ConversationService.updateIsSaved(forMessage: self.messages[i], chatId: self.chatId)
    }
    
    func fetchSavedMessages() {
        
        ConversationService.fetchSavedMessages(forDocWithId: self.chatId) { messages in
            self.setIsSameId(messages: messages)
            self.savedMessages = messages
            self.noSavedMessages = messages.count == 0
        }
    }
    
    func handleMessagesSet() {
        if MainViewModel.shared.selectedView != .Saylo {
            if messages.count > 0, let chat = chat {
                
                if chat.hasUnreadMessage {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.showMessage(atIndex: min(chat.lastReadMessageIndex + 1, chat.messages.count - 1))
                    }
                } else {
                    DispatchQueue.main.async {
                        self.index = chat.lastReadMessageIndex
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.index = self.messages.count - 1
                }
            }
        } else if messages.count == 0 {
            MainViewModel.shared.selectedView = .Video
        }
    }
    
    func updateLastSeenPost() {
        
        guard let chat = chat else {return}
        ConversationService.updateSeenLastPost(forChat: chat)
    }
    
    func addReactionToMessage(withId id: String, reaction: Reaction) {
        
        guard let message = self.messages.first(where: {$0.id == id}),
              let user = AuthViewModel.shared.currentUser,
              let chat = ConversationViewModel.shared.chat else {return}
        
        message.reactions.append(reaction)
        ConversationService.addReaction(reaction: reaction,  chatId: self.chatId)
        
        //No notification if u react to your own video
        if message.userId != user.id {
            var data = [String:Any]()
            
            let messageType = message.type == .Video ? "video" : "audio"
            
            if chat.isDm {
                
                if let friend = chat.chatMembers.first(where: {$0.id != user.id}) {
                    data["token"] = friend.fcmToken
                    data["title"] = ""
                    data["body"] = user.firstName + " \"\(reaction.reactionType.getPastTenseString())\" your \(messageType)"
                }
            } else {
                data["topic"] = message.chatId
                data["title"] = ""
                data["body"] = user.firstName + " \"\(reaction.reactionType.getPastTenseString())\" \(message.username)'s \(messageType)"
                data["metaData"] = ["userId":user.id]
            }
            
            
            Functions.functions().httpsCallable("sendNotification").call(data) { (result, error) in }
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
    
    func deleteMessage(message: Message) {
        ConversationService.deleteMessage(toDocWithId: message.chatId, messageId: message.id)
        withAnimation {
            MainViewModel.shared.selectedMessage = nil
        }
        self.index -= 1
    }
    
    func addListener() {
        
        guard !chatId.isEmpty else {return}
        
        listener = COLLECTION_CONVERSATIONS.document(chatId)
            .addSnapshotListener { snapshot, _ in
                
                if let data = snapshot?.data() {
                    
                    let messages = ConversationService.getMessagesFromData(data: data, shouldRemoveMessages: false, chatId: self.chatId)
                    
                    self.messages.forEach { message in
                        if let image = message.image {
                            messages.first(where: {$0.id == message.id})?.image = image
                        }
                    }
                    
                    
                    self.messages = messages
                    ConversationViewModel.shared.setIsSameId(messages: self.messages)
                    
                    self.noMessages = messages.count == 0
                    
                    self.seenLastPost = data["seenLastPost"] as? [String] ?? [String]()
                }
            }
    }
    
    func removeListener() {
        listener?.remove()
    }
    
    func pauseVideos() {
        players.forEach({$0.player.pause()})
        self.isPlaying = false
    }
    
    func sendMessage(url: URL? = nil, text: String? = nil, image: UIImage? = nil, type: MessageType, isFromPhotoLibrary: Bool = false,shouldExport: Bool = true) {
        
        //        if self.chatId.isEmpty {
        
        //            ConversationGridViewModel.shared.selectedChats.forEach { chat in
        if let chat = chat {
            addMessage(url: url, text: text, image: image, type: type, isFromPhotoLibrary: isFromPhotoLibrary, shouldExport: shouldExport, chatId: chat.id)
            ConversationGridViewModel.shared.isSendingChat(chat: chat, isSending: true)
        }
        //            }
        
        //        } else {
        //            addMessage(url: url, text: text, image: image, type: type, isFromPhotoLibrary: isFromPhotoLibrary, shouldExport: shouldExport, chatId: chatId)
        //        }
    }
    
    func updateNoticationsArray(chatId: String) {
        
        let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
        
        let notificationArray = defaults?.object(forKey: "notifications") as? [String]
        
        if var notificationArray = notificationArray {
            
            let chats = ConversationGridViewModel.shared.chats
            
            notificationArray.removeAll(where: {$0 == chatId || !chats.contains(where: { chat in
                chat.id == chatId && chat.hasUnreadMessage
            })})
            
            defaults?.set(notificationArray, forKey: "notifications")
            
        }
        
        UIApplication.shared.applicationIconBadgeNumber = notificationArray?.count ?? 0
    }
    
    func cleanNotificationsArray() {
        
        let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
        
        let notificationArray = defaults?.object(forKey: "notifications") as? [String]
        
        if let notificationArray = notificationArray {
            
            let chats = ConversationGridViewModel.shared.chats
            
            var newNotificationArray = [String]()
            
            notificationArray.forEach { chatId in
                if let chat = chats.first(where: { $0.id == chatId }), chat.hasUnreadMessage {
                    newNotificationArray.append(chatId)
                }
            }
            
            defaults?.set(newNotificationArray, forKey: "notifications")
            
            UIApplication.shared.applicationIconBadgeNumber = newNotificationArray.count
        }
        
    }
    
    func scrollToBottomOfFeed() {
        scrollToBottom.toggle()
    }
    
    func updatePlayer(index: Int) {
        
        self.currentPlayer?.pause()
        self.currentPlayer = self.players.first(where: {$0.messageId == self.messages[index].id})?.player
        self.currentPlayer?.playWithRate()
        self.isPlaying = true
    }
    
    func removeCurrentPlayer() {
        
        if currentPlayer != nil {
            self.currentPlayer?.pause()
            self.currentPlayer = nil
            self.isPlaying = false
        }
    }
    
    func showMessage(atIndex i: Int) {
        
        guard i >= 0 && i < messages.count else { return }
        
        MainViewModel.shared.selectedView = .Saylo
        showPlaybackControls = false
        
        self.index = i
        self.isPlaying = true
        
        if !isPlayable(index: index) {
            setVideoLength()
        }
    }
    
    func toggleIsPlaying() {
        
        isPlaying.toggle()
        showPlaybackControls = !isPlaying
        
        if !isPlaying {
            self.currentPlayer?.pause()
        } else {
            self.currentPlayer?.playWithRate()
        }
    }
    
    func showNextMessage() {
        
        showPlaybackControls = false
        
        if index == messages.count - 1 {
            self.isPlaying = false
        } else {
            
            if index < messages.count - 1 {
                
                index += 1
                self.isPlaying = true
                
                if !isPlayable(index: index) {
                    setVideoLength()
                }
            }
        }
    }
    
    
    func setVideoLength() {
        
        guard index >= 0 && index < messages.count else { return }
        
        let message = messages[index]
        
        if isPlayable(index: index) {
            if let duration = currentPlayer?.currentItem?.asset.duration.seconds {
                videoLength = duration
            }
        } else if message.type == .Text {
            
            let textCount = message.text?.count ?? 0
            
            if textCount > 200 {
                videoLength = 5
            } else {
                videoLength = 3
            }
        } else {
            videoLength = 4
        }
        
    }
    
    func showPreviousMessage() {
        showPlaybackControls = false
        index = max(0, index - 1)
    }
    
    func updateLastVisitedForChat(withId id: String) {
        let viewModel = ConversationGridViewModel.shared
        
        if let index = viewModel.chats.firstIndex(where: {$0.id == id}) {
            viewModel.chats[index].hasUnreadMessage = false
            viewModel.chats[index].lastReadMessageIndex = viewModel.chats[index].messages.count - 1
            ConversationService.updateLastVisited(forChat: viewModel.chats[index])
        }
    }
    
    func isPlayable(index: Int? = nil) -> Bool {
        let index = index ?? self.index
        guard index < messages.count && index >= 0 else { return false }
        return messages[index].type == .Video || messages[index].type == .Audio
    }
}
