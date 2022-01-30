//
//  ConversationPlayerViewModel.swift
//  Saylo
//
//  Created by Student on 2021-12-19.
//

import SwiftUI
import AVFoundation


class ConversationPlayerViewModel: ObservableObject {
    
    @Published var dragOffset: CGSize = .zero
    @Published var index: Int = 0 {
        didSet {
            self.hasChanged.toggle()
        }
    }
    @Published var messages = [Message]()
    @Published var hasChanged = false

    static let shared = ConversationPlayerViewModel()
    
    private init() {
        
        let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
        
        let newMessagesArray = defaults?.object(forKey: "messages") as? [[String:Any]] ?? [[String:Any]]()
        
        newMessagesArray.forEach { messageData in
            let id = messageData["id"] as? String ?? ""
            let message = Message(dictionary: messageData, id: id)
            
            if let index = self.messages.lastIndex(where: {$0.chatId == message.chatId }), index < self.messages.count - 1 {
                self.messages.insert(message, at: index + 1)
            } else {
                self.messages.append(message)
            }
        }
        
        if messages.count > 1 {
            
            for i in 1..<messages.count {
                
                if messages[i - 1].chatId != messages[i].chatId && messages[i-1].isForTakingVideo == false {
                    
                    let videoMessage = Message(dictionary: ["chatId":messages[i-1].chatId], id: UUID().uuidString, isForTakingVideo: true)
                    self.messages.insert(videoMessage, at: i)
                    
                }
            }
        }
        
        if let last = messages.last {
            let endVideoMessage = Message(dictionary: ["chatId":last.chatId], id: UUID().uuidString, isForTakingVideo: true)
            self.messages.append(endVideoMessage)
        }
    }
    
    
    func showNextMessage() {
        
        if index == messages.count - 1 {
            self.removePlayerView()
        } else {
            index += 1
            
            if messages[index].isForTakingVideo {
                
                let lastSeenChatId = messages[index - 1].chatId
                
                let viewModel = ConversationGridViewModel.shared
                
                if let index = viewModel.chats.firstIndex(where: {$0.id == lastSeenChatId}) {
                    viewModel.chats[index].hasUnreadMessage = false
                    viewModel.chats[index].lastReadMessageIndex = viewModel.chats[index].messages.count - 1
                    ConversationService.updateLastVisited(forChat: viewModel.chats[index])
                }
            }
        }
    }
    
    
    func showPreviousMessage() {
        index = max(0, index - 1)
    }
    
    
    func removePlayerView() {
        index = 0
        
        withAnimation {
            ConversationGridViewModel.shared.hasUnreadMessages = false
            CameraViewModel.shared.cameraView.setPreviewLayerFullFrame()
        }
    }
    
    func isPlayable() -> Bool {
        return messages[index].type == .Video || messages[index].type == .Audio
    }
}

