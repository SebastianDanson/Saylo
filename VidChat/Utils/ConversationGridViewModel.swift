//
//  ConversationGridViewModel.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-22.
//

import SwiftUI

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
    
    private init() {}
    
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
    
    func addConversation(withId id: String) {
        
        COLLECTION_CONVERSATIONS.document(id).getDocument { snapshot, _ in
            if let data = snapshot?.data() {
                var chat = Chat(dictionary: data, id: id)
                
                if !self.allChats.contains(where: {$0.id == chat.id}) {
                    self.chats.append(chat)
                    self.allChats.append(chat)
                    
                    //                    chat = Chat(dictionary: data, id: UUID().uuidString)
                    //                    self.chats.append(chat)
                    //                    self.allChats.append(chat)
                    //
                    //
                    //
                    //                    chat = Chat(dictionary: data, id: UUID().uuidString)
                    //                    self.chats.append(chat)
                    //                    self.allChats.append(chat)
                    //
                    //
                    //                    chat = Chat(dictionary: data, id: UUID().uuidString)
                    //                    self.chats.append(chat)
                    //                    self.allChats.append(chat)
                    //
                    //
                    //                    chat = Chat(dictionary: data, id: UUID().uuidString)
                    //                    self.chats.append(chat)
                    //                    self.allChats.append(chat)
                    //
                    //
                    //                    chat = Chat(dictionary: data, id: UUID().uuidString)
                    //                    self.chats.append(chat)
                    //                    self.allChats.append(chat)
                    //
                    //
                    //
                    //                    chat = Chat(dictionary: data, id: UUID().uuidString)
                    //                    self.chats.append(chat)
                    //                    self.allChats.append(chat)
                    //
                    //
                    //                    chat = Chat(dictionary: data, id: UUID().uuidString)
                    //                    self.chats.append(chat)
                    //                    self.allChats.append(chat)
                }
            }
        }
    }
    
    func fetchConversations() {
        
        guard let user = AuthViewModel.shared.currentUser else {return}
        
        user.chats.forEach { chat in
            addConversation(withId: chat.id)
        }
    }
    
    func stopSelectingChats() {
        withAnimation {
            isSelectingChats = false
            selectedChats.forEach({$0.isSelected = false})
            selectedChats.removeAll()
        }
    }
}
