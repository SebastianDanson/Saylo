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
import AgoraRtcKit

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
    var agoraKit: AgoraRtcEngineKit?
    
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
    @Published var isSending = false
    @Published var hasSent = false
    
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
    
    
    var hasUnread = false
    var currentPlayer: AVPlayer?
    
    @Published var scrollToBottom = false
    @Published var isPlaying = true
    
    @Published var hideChat = false
    
    private var uploadQueue = [[String:Any]]()
    private var isUploadingMessage = false
    private var listener: ListenerRegistration?
    
    var currentMessageId: String = ""
    @Published var liveUsers = [String]()
    
    var presentUsers = [String]()

    @Published var isLive = false
    @Published var currentlyWatchingId: String?
    
    var selectedChat: Chat?
    var hasSelectedAssets = false
    var isShowingReactions = false
    static let shared = ConversationViewModel()
    
    private init() {
        CacheManager.removeOldFiles()
    }
        
    
    func leaveChannel() {
        agoraKit?.leaveChannel()
    }
    
    func setChat(chat: Chat) {
        ConversationViewModel.shared.currentPlayer = nil
        self.selectedMessageIndexes.removeAll()
        self.chat = chat
        self.chatId = chat.id
        
        
        let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
        defaults?.set(chat.id, forKey: "selectedChatId")
        self.messages = chat.messages
        ConversationGridViewModel.shared.setChatCache()
        self.hasUnread = chat.hasUnreadMessage
        self.addListener()
        chat.hasUnreadMessage = false
        self.setIsOnChat()
    }
    
    func getSavedPosts() {
        
        if ConversationViewModel.shared.savedMessages.count == 0 {
            ConversationViewModel.shared.fetchSavedMessages()
        }
        
        withAnimation {
            MainViewModel.shared.settingsChat = nil
            ConversationViewModel.shared.showSavedPosts = true
            MainViewModel.shared.selectedView = .Saylo
        }
    }
    
    func removeChat() {
        
        if let chat = chat {
            ConversationService.updateLastVisited(forChat: chat)
            ConversationGridViewModel.shared.setChatCache()
            if let index = ConversationGridViewModel.shared.chats.firstIndex(where: {$0.id ==  chat.id}) {
                ConversationGridViewModel.shared.chats[index].lastReadMessageIndex = chat.messages.count - 1
                ConversationGridViewModel.shared.chats[index].hasUnreadMessage = false
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
            ConversationViewModel.shared.isSending = true
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
                //
                //                if let lastMessage = messages.last {
                //                    message.isSameIdAsPrevMessage = isSameIdAsPrevMessage(prevMessage: lastMessage, currentMessage: message)
                //                    lastMessage.isSameIdAsNextMessage = message.isSameIdAsPrevMessage
                //                }
                
                
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
    
    func sendIsTalkingNotification(chat: Chat) {
        
        guard let currentUser = AuthViewModel.shared.currentUser else { return }
        
        var data = [String:Any]()
        
        let body = currentUser.firstName + " is talking"
        
        if chat.isDm {
            
            let chatMember = chat.chatMembers.first(where: {$0.id != currentUser.id})
            data["token"] = chatMember?.fcmToken ?? ""
            data["title"] = ""
            data["body"] = body
            
        } else {
            
            data["topic"] = chat.id
            data["title"] = chat.fullName
            data["body"] = body
        }
        
        Functions.functions().httpsCallable("sendNotification").call(data) { (result, error) in }
    }
    
    func setIsLive(chat: Chat) {
        COLLECTION_CONVERSATIONS.document(chat.id).updateData(["liveUsers":FieldValue.arrayUnion([AuthViewModel.shared.getUserId()])])
    }
    
    func setIsOnChat() {
        
        guard let chat = chat else { return }
        COLLECTION_CONVERSATIONS.document(chat.id).updateData(["presentUsers":FieldValue.arrayUnion([AuthViewModel.shared.getUserId()])])
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
            ConversationViewModel.shared.isSending = true
            
            self.uploadQueue.forEach { data in
                if data["chatId"] as? String == chat.id {
                    if let id = data["id"] as? String {
                        self.messages.removeAll(where: {$0.id == id})
                    }
                }
            }
            
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
    
    func sendMissedCallNotification(token: String) {
        
        guard let currentUser = AuthViewModel.shared.currentUser else { return }
        
        let userFullName = currentUser.firstName + " " + currentUser.lastName
        var data = [String:Any]()
        data["title"] = "Missed Call"
        data["token"] = token
        data["body"] = "from \(userFullName)"
        data["metaData"] = ["isCallNofitication": true]
        
        Functions.functions().httpsCallable("sendNotification").call(data) { (result, error) in }
    }
    
    
    func updateIsSaved(atIndex i: Int) {
        self.messages[i].isSaved.toggle()
        self.savedMessages.removeAll(where: {$0.id == self.messages[i].id})
        ConversationService.updateIsSaved(forMessage: self.messages[i], chatId: self.chatId)
    }
    
    fileprivate func fetchSavedMessages() {
        
        guard let chat = chat else { return }
        
        ConversationService.fetchSavedMessages(forDocWithId: chat.id) { messages in
            //            self.setIsSameId(messages: messages)
            self.savedMessages = messages
            self.index = messages.count - 1
            self.noSavedMessages = messages.count == 0
        }
    }
    
    func handleMessagesSet() {
        if MainViewModel.shared.selectedView != .Saylo {
            if messages.count > 0, let chat = chat {
                
                if chat.hasUnreadMessage {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.showMessage(atIndex: min(chat.lastReadMessageIndex, chat.messages.count - 1))
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
            
            var messageType = ""
            
            switch message.type {
            case .Video:
                messageType = "video"
            case .Audio:
                messageType = "audio"
            case .Text:
                messageType = "text"
            case .Photo:
                messageType = "photo"
            case .NewChat:
                break
            }
            
            
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
        let messages = showSavedPosts ? savedMessages : messages
        
        if let message = messages.first(where: {$0.id == id}) {
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
        
        if self.hasUnread {
            
            COLLECTION_CONVERSATIONS.document(chatId).getDocument { snapshot, _ in
                
                if let data = snapshot?.data() {
                    let chat = Chat(dictionary: data, id: self.chatId)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.selectedMessageIndexes.append(chat.lastReadMessageIndex)
                        self.messages = chat.messages
                        self.showMessage(atIndex: chat.lastReadMessageIndex)
                        
                    }
                }
                
                self.hasUnread = false
                ConversationService.updateLastVisited(forChat: self.chat!)
            }
        } else {
            ConversationService.updateLastVisited(forChat: self.chat!)
        }
        
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
                    
                    //                    if self.hasUnread {
                    //                        let chat = Chat(dictionary: data, id: self.chatId)
                    ////                        if self.index != chat.lastReadMessageIndex {
                    //                            self.showMessage(atIndex: chat.lastReadMessageIndex)
                    ////                        }
                    //                        self.hasUnread = false
                    //                    }
                    
                    //                    ConversationViewModel.shared.setIsSameId(messages: self.messages)
                    
                    
                    self.liveUsers = data["liveUsers"] as? [String] ?? [String]()
                    self.presentUsers = data["presentUsers"] as? [String] ?? [String]()
                    
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
        
        let messages = showSavedPosts ? savedMessages : messages
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
    
    func pause() {
        isPlaying = false
        self.currentPlayer?.pause()
        
    }
    
    func play() {
        isPlaying = true
        self.currentPlayer?.playWithRate()
    }
    
    func showNextMessage() {
        
        let messages = showSavedPosts ? savedMessages : messages
        
        showPlaybackControls = false
        
        if index == messages.count - 1 {
            self.isPlaying = false
            MainViewModel.shared.selectedView = .Video
        } else {
            
            if index < messages.count - 1 {
                
                index += 1
                selectedMessageIndexes.append(index)
                self.isPlaying = true
                
                if !isPlayable(index: index) {
                    setVideoLength()
                }
            }
        }
    }
    
    
    func setVideoLength() {
        
        let messages = showSavedPosts ? savedMessages : messages
        
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
        let messages = showSavedPosts ? savedMessages : messages
        guard index < messages.count && index >= 0 else { return false }
        return messages[index].type == .Video || messages[index].type == .Audio
    }
}
