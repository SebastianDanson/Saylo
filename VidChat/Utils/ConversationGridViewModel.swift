//
//  ConversationGridViewModel.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-22.
//

import SwiftUI
import Firebase

class ConversationGridViewModel: ObservableObject {
    
    @Published var isSelectingChats = false
    @Published var cameraViewZIndex: Double = 3
    @Published var hideFeed = false
    @Published var selectedChats = [Chat]()
    @Published var sendingChats = [Chat]()
    @Published var showSearchBar: Bool = false
    @Published var showSettingsView: Bool = false
    @Published var showAddFriends: Bool = false
    @Published var showNewChat: Bool = false
    @Published var chats = [Chat]()
    @Published var showConversation = false
    @Published var isCalling = false
    @Published var temp = false
    
    var allChats = [Chat]()
    
    
    static let shared = ConversationGridViewModel()
    
    private init() {
        
        let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
        let chatDic = defaults?.object(forKey: "chats") as? [[String:Any]]
        let newMessagesArray = defaults?.object(forKey: "messages") as? [[String:Any]] ?? [[String:Any]]()
        print(newMessagesArray, "NEWMES")
        var chats = [Chat]()
        chatDic?.forEach({
            if let id = $0["id"] as? String {
                chats.append(Chat(dictionary: $0, id: id))
            }
        })
        
        
        self.chats = chats.sorted(by: {$0.getDateOfLastPost() > $1.getDateOfLastPost()})
    }
    
    func sharedDirectoryURL() -> URL {
        let fileManager = FileManager.default
        return fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.SebastianDanson.saylo")!
       
    }
    
    func removeSelectedChat(withId id: String) {
        if let index = selectedChats.firstIndex(where: {$0.id == id}) {
            withAnimation {
                //TODO handle isSelected
                selectedChats[index].isSelected = !selectedChats[index].isSelected
                selectedChats.removeAll(where: {$0.id == id})
            }
        }
    }
    
    func toggleSelectedChat(chat: Chat) {
        
        //TODO handle isSelected
        chat.isSelected.toggle()
        if let index = selectedChats.firstIndex(where: {$0.id == chat.id}) {
            selectedChats.remove(at: index)
        } else {
            selectedChats.append(chat)
        }
    }
    
    func isSendingChat(chat: Chat, isSending: Bool) {
        //TODO handle isSelected
        chat.isSending = isSending
        if let index = sendingChats.firstIndex(where: {$0.id == chat.id}) {
            sendingChats.remove(at: index)
        } else {
            sendingChats.append(chat)
        }
    }
    
    func hasSentChat(chat: Chat, hasSent: Bool) {
        //TODO handle isSelected
        
        withAnimation {
            chat.hasSent = hasSent
            chat.isSending = false
            
            
            if let index = sendingChats.firstIndex(where: {$0.id == chat.id}) {
                sendingChats.remove(at: index)
            } else {
                sendingChats.append(chat)
            }
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.hasSentChat(chat: chat, hasSent: false)
        }
    }
    
    func toggleHasSentChat(chatId: String) {
        //TODO handle isSelected
        
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
    
    func addConversation(withId id: String, completion: @escaping([String:Any]) -> Void) {
        
        COLLECTION_CONVERSATIONS.document(id).getDocument { snapshot, _ in
            if let data = snapshot?.data() {
                let chat = Chat(dictionary: data, id: id)
                
                if let index = self.chats.firstIndex(where: {$0.id == chat.id}) {
                    self.chats[index] = chat
                } else {
                    self.chats.append(chat)
                }
            }
            
            completion(snapshot?.data() ?? [String:Any]())
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
        
        var chatDictionary = [[String:Any]]()
        
        
        user.chats.forEach { chat in
            
            addConversation(withId: chat.id) { chatData in
                
                count += 1

                var messages = chatData["messages"] as? [[String:Any]] ?? [[String:Any]]()

                for i in 0..<messages.count {
                    let timeStamp = messages[i]["timestamp"] as? Timestamp
                    messages[i]["timestamp"] = Int(timeStamp?.dateValue().timeIntervalSince1970 ?? 0)
                }

                var chatData = chatData
                 chatData["messages"] = messages
                chatData["id"] = chat.id
                 chatDictionary.append(chatData)

                if count == user.chats.count {

                    let chats = self.chats.sorted(by: {$0.getDateOfLastPost() > $1.getDateOfLastPost()})
                    print("2222")
                    self.allChats = chats

                    withAnimation {
                        self.chats = chats
                    }

                    let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
                    defaults?.set(chatDictionary, forKey: "chats")
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
    
    func fetchConversation(withId chatId: String) {
        
        self.setConversation(withId: chatId) { data in
//            let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
//            var chatDic = defaults?.object(forKey: "chats") as? [[String:Any]]
//            
//            for i in 0..<chatDic?.count {
//                if chatDic[""]
//            }
        }
    }
    
    func sortChats() {
        self.chats = self.chats.sorted(by: {$0.getDateOfLastPost() > $1.getDateOfLastPost()})
    }
    
    
    func updateLastRead() {
        let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
        
        let notificationArray = defaults?.object(forKey: "notifications") as? [String]
        
        notificationArray?.forEach({ chatId in
            print(chatId, "ID YESSIR", chats.count, chats[0].id)
            if let index = chats.firstIndex(where: { return $0.id == chatId }) {
                print("YESSIR")
                DispatchQueue.main.async {
                    withAnimation {
                        let chat = self.chats.remove(at: index)
                        chat.hasUnreadMessage = true
                        self.chats.append(chat)
                    }
                }
            }
        })
    }
}

