//
//  ConversationPlayerView.swift
//  VidChat
//
//  Created by Student on 2021-12-13.
//

import SwiftUI
import AVFoundation

struct ConversationPlayerView: View {
    
    @State var player: AVQueuePlayer
    private var token: NSKeyValueObservation?
    private var urls: [AVPlayerItem]?

    init() {
       
        var playerItems = [AVPlayerItem]()
        
        ConversationViewModel.shared.messages.forEach({
            if $0.type == .Video, let urlString = $0.url, let url = URL(string: urlString) {
                let playerItem = AVPlayerItem(asset: AVAsset(url: url))
                playerItems.append(playerItem)
            }
        })
        
        let player = AVQueuePlayer(items: playerItems)
        player.automaticallyWaitsToMinimizeStalling = false
        self.player = player
        self.player.play()
        self.player.items().forEach { item in
            print(item.asset.duration.seconds)
        }
        
    }

    
    var body: some View {
        
        ZStack {
            PlayerQueueView(player: $player)
                .frame(width: SCREEN_WIDTH, height: SCREEN_WIDTH * 16/9)
               
            RoundedRectangle(cornerRadius: 24).strokeBorder(Color.black, style: StrokeStyle(lineWidth: 10))
                .frame(width: SCREEN_WIDTH + 10, height: (SCREEN_WIDTH * 16/9) + 20)
        }
        .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        .background(Color.black)

 
    }
    
    func restartPlayer(){
//        let playerItems = player.items()
//            player.removeAllItems()
//            playerItems.forEach{
//                player.insert($0, after:nil)
//            }
            player.seek(to: .zero)
            
        }
    
//    func getPlayerItems() -> [AVPlayerItem] {
//
//
//
//        print(playerItems.count, "COUNTER")
//        return playerItems
//    }
}

//struct VideoPlayerView: View {
//
//    @State var player: AVPlayer
//    @ObservedObject var viewModel: VideoPlayerViewModel
//    @State var isSaved: Bool = false
//
//    var messageId: String?
//
//    private var exporter: AVAssetExportSession?
//
//    var width: CGFloat = UIScreen.main.bounds.width
//    var height: CGFloat = UIScreen.main.bounds.width
//    var showName: Bool = false
//
//    init(url: URL, id: String? = nil, isSaved: Bool = false, showName: Bool = true, date: Date? = nil) {
//        let player = AVPlayer(url: url)
//        self.player = player
//        self.isSaved = isSaved
//        self.messageId = id
//        self.viewModel = VideoPlayerViewModel(player: player, date: date)
//        self.showName = showName
//
//        player.automaticallyWaitsToMinimizeStalling = false
//        self.player.play()
//
//        if let id = id {
//            ConversationViewModel.shared.players.append(MessagePlayer(player: player, messageId: id))
//        }
//
//        if let size = resolutionForLocalVideo(url: url) {
//            let ratio = size.height/size.width
//            height = height * ratio
//        }
//    }
//
//    //TODO asynchornously load videos
//    //https://bytes.swiggy.com/video-stories-and-caching-mechanism-ios-61fc63cc04f8
//
//    var body: some View {
//
//        ZStack {
//            PlayerView(player: $player)
//                .padding(.vertical, -6)
//                .frame(width: width, height: height)
//                .overlay(
//                    HStack {
//                        if showName {
//                            Image(systemName: "house")
//                                .clipped()
//                                .scaledToFit()
//                                .padding()
//                                .background(Color.gray)
//                                .frame(width: 30, height: 30)
//                                .clipShape(Circle())
//                            Text("Sebastian")
//                                .font(.system(size: 14, weight: .semibold))
//                                .foregroundColor(.white)
//                            + Text(" • \((viewModel.date ?? Date()).getFormattedDate())")
//                                .font(.system(size: 12, weight: .regular))
//                                .foregroundColor(Color.white)
//                        }
//                    }
//                        .padding(12),
//                    alignment: .bottomLeading)
//                .simultaneousGesture(
//                    LongPressGesture()
//                        .onEnded { _ in
//                            withAnimation {
//                                if let i = ConversationViewModel.shared.messages
//                                    .firstIndex(where: {$0.id == messageId}) {
//                                    ConversationViewModel.shared.messages[i].isSaved.toggle()
//                                    isSaved.toggle()
//                                }
//                            }
//                        }
//                )
//                .highPriorityGesture(TapGesture()
//                                        .onEnded { _ in
//                    viewModel.togglePlay()
//                })
//                .overlay(
//
//
//
//                    HStack {
//                        Spacer()
//                        if isSaved {
//                            Image(systemName: "bookmark.fill")
//                                .resizable()
//                                .scaledToFit()
//                                .foregroundColor(.mainBlue)
//                                .frame(width: 36, height: 24)
//                                .padding(.leading, 8)
//                                .transition(.scale)
//                        }
//
//
//                    }
//                    ,alignment: .center)
//        }
//
//        if showName {
//            RoundedRectangle(cornerRadius: 24).strokeBorder(Color.white, style: StrokeStyle(lineWidth: 10))
//                .frame(width: width + 10, height: height + 20)
//        }
//    }
//
//struct ConversationPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        ConversationPlayerView()
//    }
//}
