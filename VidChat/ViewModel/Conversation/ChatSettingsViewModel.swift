//
//  ChatSettingsViewModel.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-14.
//

import SwiftUI
import Firebase

class ChatSettingsViewModel: ObservableObject {
    
    @Published var addedChats = [Chat]()
    @Published var chats = [Chat]()
    
    static let shared = ChatSettingsViewModel()
    
    private init() {}
    
    func setChats() {
        self.chats = ConversationGridViewModel.shared.chats.filter({$0.isDm})
    }
    
    func handleChatSelected(chat: Chat) {
        
        withAnimation {
            if !addedChats.contains(where: { $0.id == chat.id }) {
                addedChats.append(chat)
            } else {
                addedChats.removeAll(where: { $0.id == chat.id })
            }
        }
    }
    
    func filterUsers(withText text: String) {
        
        let allChats = self.chats
        
        withAnimation {
            
            self.chats = allChats.filter({
                
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
}
