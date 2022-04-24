//
//  ConversationGridViewModel.swift
//  Saylo
//
//  Created by Sebastian Danson on 2021-12-22.
//

import SwiftUI
import Firebase
import Photos

class ConversationGridViewModel: ObservableObject {
    
    @Published var isSelectingChats = false
    @Published var cameraViewZIndex: Double = 3
    @Published var hideFeed = false
    @Published var selectedChats = [Chat]()
    @Published var sendingChats = [Chat]()
    @Published var showSearchBar: Bool = false
    @Published var showSettingsView: Bool = false
    @Published var showAddFriends: Bool = false
    @Published var showFindFriends: Bool = false
    @Published var showNewChat: Bool = false
    @Published var chats = [Chat]()
    @Published var unreadChats = [Chat]()
    @Published var showUnreadChats = false
    @Published var showConversation = false
    @Published var isCalling = false
    @Published var temp = false
    @Published var hasUnreadMessages = false
    @Published var showAllFriends = false
    @Published var selectedSettingsChat: Chat?

    var allChats = [Chat]()
    
    static let shared = ConversationGridViewModel()
    
    private init() {
        showCachedChats()
    }
    
    
    func sharedDirectoryURL() -> URL {
        let fileManager = FileManager.default
        return fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.SebastianDanson.saylo")!
        
    }
    
    func removeSelectedChat(withId id: String) {
        
        if let index = selectedChats.firstIndex(where: {$0.id == id}) {
            withAnimation {
                selectedChats[index].isSelected = !selectedChats[index].isSelected
                selectedChats.removeAll(where: {$0.id == id})
            }
        }
    }
    
    func toggleSelectedChat(chat: Chat) {
        
        chat.isSelected.toggle()
        if let index = selectedChats.firstIndex(where: {$0.id == chat.id}) {
            selectedChats.remove(at: index)
        } else {
            selectedChats.append(chat)
        }
    }
    
    func isSendingChat(chat: Chat, isSending: Bool) {
        
        chat.isSending = isSending
        
        DispatchQueue.main.async {
            if let index = self.sendingChats.firstIndex(where: {$0.id == chat.id}) {
                self.sendingChats.remove(at: index)
            } else {
                self.sendingChats.append(chat)
            }
        }
        
    }
    
    func hasSentChat(chat: Chat, hasSent: Bool) {
        
        
        
        //        withAnimation {
        
        
        chat.hasSent = hasSent
        chat.isSending = false
        
        DispatchQueue.main.async {
            
            if let index = self.sendingChats.firstIndex(where: {$0.id == chat.id}) {
                self.sendingChats.remove(at: index)
            } else {
                self.sendingChats.append(chat)
            }
        }
        
        //        }
        
        if hasSent {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.hasSentChat(chat: chat, hasSent: false)
                ConversationViewModel.shared.uploadProgress = 0.0
            }
        }
    }
    
    func toggleHasSentChat(chatId: String) {
        
        selectedChats.first(where: {$0.id == chatId})?.hasSent.toggle()
        temp.toggle()
    }
    
    func showAllChats() {
        self.chats = self.allChats
    }
    
    func filterUsers(withText text: String) {
        
        self.allChats = self.chats
        
        withAnimation {
            self.chats = self.allChats.filter({
                
                let wordArray = $0.name.components(separatedBy: [" "])
                var contains = false
                
                wordArray.forEach({
                    if $0.starts(with: text) {
                        contains = true
                    }
                })
                
                return contains
            })
        }
    }
    
    func addConversation(withId id: String, completion: @escaping(() -> Void)) {
        
        COLLECTION_CONVERSATIONS.document(id).getDocument { snapshot, _ in
            if let data = snapshot?.data() {
                let chat = Chat(dictionary: data, id: id)
                
                chat.messages.forEach { message in
                    if let urlString = message.url, let url = URL(string: urlString) {
                        self.createVideoThumbnail(from: url)
                    }
                }
                if let index = self.chats.firstIndex(where: {$0.id == chat.id}) {
                    self.chats[index] = chat
                } else {
                    self.chats.append(chat)
                }
                
                if chat.isDm, let user = chat.chatMembers.first(where: {$0.id == AuthViewModel.shared.getUserId() }) {
                    if let currentUser = AuthViewModel.shared.currentUser, user.fcmToken != currentUser.fcmToken {
                        AuthViewModel.shared.updateChatsFcmToken()
                    }
                }
            }
            
            completion()
        }
    }
    
    private func createVideoThumbnail(from url: URL) {
        
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.maximumSize = CGSize(width: MINI_MESSAGE_WIDTH * 3, height: MINI_MESSAGE_HEIGHT * 3)
        
        let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
        DispatchQueue.global().async {
            do {
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let thumbnail = UIImage(cgImage: img)
                ImageCache.getImageCache().set(forKey: url.absoluteString, image: thumbnail)
                
            }
            catch {
                print("ERRROR: \(url)"  + error.localizedDescription)
                ImageCache.getImageCache().set(forKey: url.absoluteString, image: UIImage(systemName: "exclamationmark.bubble.fill")!)
            }
        }
    }
    
    func setConversation(withId id: String, completion: @escaping([String:Any]) -> Void) {
        
        COLLECTION_CONVERSATIONS.document(id).getDocument { snapshot, _ in
            if let data = snapshot?.data() {
                
                let chat = Chat(dictionary: data, id: id)
                
                for i in 0..<self.chats.count {
                    
                    if self.chats[i].id == chat.id {
                        
                        self.chats[i] = chat
                        self.allChats = self.chats
                    }
                }
            }
            
            completion(snapshot?.data() ?? [String:Any]())
        }
    }
    
    func fetchConversations() {
        
        guard let user = AuthViewModel.shared.currentUser else {return}
        var count = 0
        
        user.chats.forEach { chat in
            
            addConversation(withId: chat.id) {
                
                count += 1
                
                if count == user.chats.count {
                    
                    
                    self.chats = self.chats.sorted(by: {$0.getDateOfLastPost() > $1.getDateOfLastPost()})
                    
                    if let index = self.chats.firstIndex(where: {$0.isTeamSaylo}) {
                        self.chats.append(self.chats.remove(at: index))
                    }
                    
                    self.allChats = self.chats
                    
                    
                    if self.chats.count > 0 {
                        ConversationViewModel.shared.setChat(chat: self.chats[0])
                    }
                    
                    //                    withAnimation {
                    //                        self.chats = chats
                    //                    }
                    
                    self.setChatCache()
                    
                    self.chats.forEach { chat in
                        
                        if !chat.isDm {
                            Messaging.messaging().subscribe(toTopic: chat.id)
                        }
                    }
                }
            }
        }
    }
    
    func stopSelectingChats() {
        withAnimation {
            isSelectingChats = false
            selectedChats.forEach({$0.isSelected = false})
            selectedChats.removeAll()
        }
    }
    
    func refetchCurrentUser() {
        
        guard let currentUser = AuthViewModel.shared.currentUser else {return}
        
        let numChats = currentUser.chats.count
        
        AuthViewModel.shared.fetchUser {
            
            if let updatedCurrentUser = AuthViewModel.shared.currentUser {
                if updatedCurrentUser.chats.count != numChats {
                    self.fetchConversations()
                }
            }
        }
    }
    
    func fetchConversation(withId chatId: String, completion: @escaping(() -> Void)) {
        
        self.setConversation(withId: chatId) { data in
            ConversationGridViewModel.shared.sortChats()
            completion()
        }
    }
    
    func sortChats(withAnimation: Bool = false) {
        self.chats = self.chats.sorted(by: {$0.getDateOfLastPost() > $1.getDateOfLastPost()})
        
        if let index = self.chats.firstIndex(where: {$0.isTeamSaylo}) {
            self.chats.append(self.chats.remove(at: index))
        }
    }
    
    
    //    func updateLastRead() {
    //        let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
    //
    //        let notificationArray = defaults?.object(forKey: "notifications") as? [String]
    //
    //        notificationArray?.forEach({ chatId in
    //            if let index = chats.firstIndex(where: { return $0.id == chatId }) {
    //                DispatchQueue.main.async {
    //                    withAnimation {
    //                        let chat = self.chats.remove(at: index)
    //                        chat.hasUnreadMessage = true
    //                        self.chats.append(chat)
    //                    }
    //                }
    //            }
    //        })
    //    }
    
    func showCachedChats() {
        
        self.chats = getCachedChats()
        
        let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
        let selectedChatId = defaults?.string(forKey: "selectedChatId")
        
        if let selectedChatId = selectedChatId, let chat = self.chats.first(where: {$0.id == selectedChatId}) {
            ConversationViewModel.shared.setChat(chat: chat)
        } else if chats.count > 0 {
            ConversationViewModel.shared.setChat(chat: chats [0])
        }
    }
    
    func showChat(chat: Chat) {
        DispatchQueue.global().async {
            MainViewModel.shared.startRunning()
        }
        ConversationViewModel.shared.setChat(chat: chat)
        
//        withAnimation {
            self.showConversation = true
//        }
    }
    
    func getCachedChats() -> [Chat] {
        
        let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
        let chatDic = defaults?.object(forKey: "chats") as? [[String:Any]]
        let newMessagesArray = defaults?.object(forKey: "messages") as? [[String:Any]] ?? [[String:Any]]()
        
        
        var chats = [Chat]()
        chatDic?.forEach({
            if let id = $0["id"] as? String {
                let chat = Chat(dictionary: $0, id: id, shouldRemoveOldMessages: false)
                
                chats.append(chat)
            }
        })
        
        newMessagesArray.forEach { messageData in
            
            let id = messageData["id"] as? String ?? ""
            let message = Message(dictionary: messageData, id: id)
            
            if let i = chats.firstIndex(where: {$0.id == message.chatId}) {
                chats[i].messages.append(message)
                chats[i].hasUnreadMessage = true
            }
            
            //            ConversationPlayerViewModel.shared.addMessage(message)
        }
        
        if newMessagesArray.count > 0 {
            self.hasUnreadMessages = true
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            defaults?.set([[String:Any]](), forKey: "messages")
        }
        
        return chats
    }
    
    func setChatCache() {
        
        guard let user = AuthViewModel.shared.currentUser else {return}
        
        var chatDictionary = [[String:Any]]()
        
        self.chats.forEach { chat in
            if user.chats.contains(where: {$0.id == chat.id}) {
                chatDictionary.append(chat.getDictionary())
            } else {
                self.chats.removeAll(where: {$0.id == chat.id})
                self.allChats = chats
            }
        }
        
        let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
        defaults?.set(chatDictionary, forKey: "chats")
    }
}

