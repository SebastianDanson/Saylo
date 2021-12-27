//
//  ConversationPlayerViewModel.swift
//  VidChat
//
//  Created by Student on 2021-12-19.
//

import SwiftUI
import AVFoundation

class ConversationPlayerViewModel: ObservableObject {
    
    @Published var dateString = ""
    @Published var dragOffset: CGSize = .zero
    @Published var index: Int = 0
    @Published var player = AVQueuePlayer()
    @Published var audioPlayer = AudioPlayer()

    var playerItems = [AVPlayerItem]()
    
    var hasGoneBack = false
    var canAdvance = true
    
    var dates = [Date]() {
        didSet {
            if let date = dates.first {
                self.dateString = date.getFormattedDate()
            }
        }
    }
    
    static let shared = ConversationPlayerViewModel()
    private init() {}
    
    func handleShowNextMessage(wasInterrupted: Bool) {
                
        incrementIndex()

        print(index, "INDEX", player.items().count)
                    
        if !isPlayable() {
            
            if !wasInterrupted {
                canAdvance = false
                player.advanceToNextItem()
            }
            player.pause()
            player.seek(to: .zero)
            
        } else {
            if hasGoneBack || !canAdvance {
                player.play()
                print("PLAY")
                canAdvance = true
            } else {
                print("ADVANCE")
                player.advanceToNextItem()
            }
            player.seek(to: .zero)
        }
        
        
        if index == 0 && player.items().count == 0 {
            addAllVideosToPlayer()
        }
        
        hasGoneBack = false
        setDateString()
    }
    
    func incrementIndex() {
        index = (index + 1) % ConversationViewModel.shared.messages.count
    }
    
    
    func handleShowPrevMessage() {
        
        let messages = ConversationViewModel.shared.messages
        let wasPlayable = isPlayable()
        index = max(0, index - 1)
        
        //if the current message and next message are both videos -> replace current video with previous
        if let currentItem = player.currentItem, isPlayable(), wasPlayable || isPlayable() && hasGoneBack {
            
            if let currentIndex = playerItems.firstIndex(of: currentItem) {
                
                if currentIndex > 0 {
                    print(currentIndex, "INDEX")
                    let prevItem = playerItems[currentIndex - 1]
                    player.replaceCurrentItem(with: prevItem)
                    player.insert(playerItems[currentIndex], after: prevItem)
                }
                
                player.seek(to: .zero)
            }
            
        } else {

            if messages[index].type != .Video {
                hasGoneBack = true
                player.pause()
            } else {
                player.seek(to: .zero)
                player.play()
            }
        }
        
        setDateString()
    }
    
    func addAllVideosToPlayer() {
        print("ADDDD")
        for item in playerItems {
            if player.canInsert(item, after: player.items().last) {
                player.insert(item, after: player.items().last)
            }
        }
        
        player.seek(to: .zero)
        
    }
    
    func setDateString() {
        if let playerItem = player.items().first, let index = playerItems.firstIndex(where: {$0 == playerItem}) {
            dateString = dates[index].getFormattedDate()
        }
    }
    
    func removePlayerView() {
        index = 0
        player.removeAllItems()
        player.pause()
        ConversationViewModel.shared.showConversationPlayer = false
    }
    
    func isPlayable() -> Bool {
        
        let messages = ConversationViewModel.shared.messages
        
        return messages[index].type == .Video || messages[index].type == .Audio
    }
}

