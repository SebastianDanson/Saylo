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
    @Published var index: Int = 0
    @Published var messages = [Message]()

    var playerItems = [AVPlayerItem]()
    
    var hasGoneBack = false
    var canAdvance = true
    
    
    static let shared = ConversationPlayerViewModel()
    
    private init() {
        
        let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)

        let newMessagesArray = defaults?.object(forKey: "messages") as? [[String:Any]] ?? [[String:Any]]()
        
        newMessagesArray.forEach { messageData in
            let id = messageData["id"] as? String ?? ""
            let message = Message(dictionary: messageData, id: id)
            self.messages.append(message)
        }
    }
    
    
    func showNextMessage() {
        if index == messages.count - 1 {
            self.removePlayerView()
        } else {
            index += 1
        }
    }
    
    
    func showPreviousMessage() {
        index = max(0, index - 1)
    }
    
   
    
    func removePlayerView() {
        index = 0
        withAnimation {
            ConversationGridViewModel.shared.hasUnreadMessages = false
        }
    }
    
    func isPlayable() -> Bool {
        return messages[index].type == .Video || messages[index].type == .Audio
    }
}

