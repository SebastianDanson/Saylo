//
//  VideoPlayerView.swift
//  VidChat
//
//  Created by Student on 2021-09-27.
//

import SwiftUI
import AVKit


import AVKit
import SwiftUI

struct VideoPlayerView: View {
    
    @State var player: AVPlayer
    @ObservedObject var viewModel: VideoPlayerViewModel
    @State var isSaved: Bool = false
    @State var showAlert = false

    var messageId: String?
    
    private var exporter: AVAssetExportSession?
    
    var width: CGFloat = UIScreen.main.bounds.width
    var height: CGFloat = UIScreen.main.bounds.width
    var showName: Bool = false
    
    init(url: URL, id: String? = nil, isSaved: Bool = false, showName: Bool = true, date: Date? = nil) {
        let player = AVPlayer(url: url)
        self.player = player
        self.isSaved = isSaved
        self.messageId = id
        self.viewModel = VideoPlayerViewModel(player: player, date: date)
        self.showName = showName
        
        player.automaticallyWaitsToMinimizeStalling = false
        self.player.play()
        
        if let id = id {
            ConversationViewModel.shared.players.append(MessagePlayer(player: player, messageId: id))
        }
        
        if let size = resolutionForLocalVideo(url: url) {
            let ratio = size.height/size.width
            height = height * ratio
        }
    }
    
    //TODO asynchornously load videos
    //https://bytes.swiggy.com/video-stories-and-caching-mechanism-ios-61fc63cc04f8
    
    var body: some View {
        
        ZStack {
            PlayerView(player: $player)
                .padding(.vertical, -6)
                .frame(width: width, height: height)
                .overlay(
                    HStack {
                        if showName {
                            Image(systemName: "house")
                                .clipped()
                                .scaledToFit()
                                .padding()
                                .background(Color.gray)
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                            Text("Sebastian")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            + Text(" • \((viewModel.date ?? Date()).getFormattedDate())")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(Color.white)
                        }
                    }
                        .padding(12),
                    alignment: .bottomLeading)
                .simultaneousGesture(
                    LongPressGesture()
                        .onEnded { _ in
                            withAnimation {
                                if let i = getMessages().firstIndex(where: {$0.id == messageId}) {
                                    if getMessages()[i].isSaved {
                                        showAlert = true
                                    } else {
                                        ConversationViewModel.shared.updateIsSaved(atIndex: i)
                                        isSaved.toggle()
                                    }
                               
                                }
                            }
                        }
                )
                .highPriorityGesture(TapGesture()
                                        .onEnded { _ in
                    viewModel.togglePlay()
                })
                .overlay(
                    
                    
                    
                    HStack {
                        Spacer()
                        if isSaved {
                            
                            Button {
                                showAlert = true
                            } label: {
                                ZStack {
                                    
                                    Circle()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(Color(white: 0, opacity: 0.3))
                                    
                                    Image(systemName: ConversationViewModel.shared.showSavedPosts ? "trash" : "bookmark")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.white)
                                        .frame(width: 16, height: 16)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                            }.alert(isPresented: $showAlert) {
                                savedPostAlert(mesageIndex: ConversationViewModel.shared.messages.firstIndex(where: {$0.id == messageId}), completion: { isSaved in
                                    self.isSaved = isSaved
                                })
                            }

                            
                        }
                        
                        
                    }
                    ,alignment: .bottomTrailing)
        }
        
        if showName {
            RoundedRectangle(cornerRadius: 24).strokeBorder(Color.white, style: StrokeStyle(lineWidth: 10))
                .frame(width: width + 10, height: height + 20)
        }
    }
    
    
    private func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
    
}

class Host : UIHostingController<VideoPlayerView>{
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        
        return .lightContent
    }
}

struct VideoPlayer : UIViewControllerRepresentable {
    
    @Binding var player : AVPlayer
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<VideoPlayer>) -> AVPlayerViewController {
        
        let controller = AVPlayerViewController()
        controller.player = player
        
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspect
        controller.view.backgroundColor = .clear
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<VideoPlayer>) {
    }
}

struct PlayerView: UIViewRepresentable {
    
    @Binding var player : AVPlayer
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
    }
    
    func makeUIView(context: Context) -> UIView {
        let playerView = PlayerUIView(frame: .zero, player: player)
        return playerView
    }
}

struct PlayerQueueView: UIViewRepresentable {
    
    @Binding var player : AVQueuePlayer
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerQueueView>) {
    }
    
    func makeUIView(context: Context) -> UIView {
        let playerView = PlayerUIView(frame: .zero, player: player, shouldLoop: false)
        return playerView
    }
}

class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    private var exporter: AVAssetExportSession?
    private var items = [AVPlayerItem]()
    private var token: NSKeyValueObservation?
    private var prevTranslation: CGPoint = .zero

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, player: AVPlayer, shouldLoop: Bool = true) {
        super.init(frame: frame)
        // Setup the player
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspect
        
        layer.addSublayer(playerLayer)
        
        // Setup looping
        
        player.actionAtItemEnd = shouldLoop ? .none : .advance
        
        
        if shouldLoop {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(playerItemDidReachEnd(notification:)),
                                                   name: .AVPlayerItemDidPlayToEndTime,
                                                   object: player.currentItem)
        }
        
        if !shouldLoop, let player = player as? AVQueuePlayer {
            items = player.items()
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
        } catch(let error) {
            print(error.localizedDescription)
        }
        
        player.play()
        
        if !shouldLoop {
            token = player.observe(\.currentItem) { [weak self] player, _ in
                self?.updateDateString()
                if let player = player as? AVQueuePlayer, player.items().count == 0 {
                    self?.addAllVideosToPlayer()
                }
            }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            self.addGestureRecognizer(tap)
            
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            self.addGestureRecognizer(pan)
        }
    }
    
    
    @objc
    func handleTap(_ sender: UITapGestureRecognizer) {
        if let player = playerLayer.player as? AVQueuePlayer {
            let xLoc = sender.location(in: self).x
            
            if xLoc > SCREEN_WIDTH/2 {
                player.advanceToNextItem()
            } else if let currentItem = player.currentItem {
               
                let currentIndex = items.firstIndex(of: currentItem)
                
                if let currentIndex = currentIndex {
                    
                    if currentIndex > 0 {
                        let prevItem = items[currentIndex - 1]
                        player.replaceCurrentItem(with: prevItem)
                    }
                    
                    player.seek(to: .zero)

                }
            }
        }
    }
    
    @objc
    func handlePan(_ gesture: UIPanGestureRecognizer) {
      
        let playerViewModel = ConversationPlayerViewModel.shared

        if gesture.state == .changed {
            let translation = gesture.translation(in: self)
            let diff = translation.y - prevTranslation.y
            prevTranslation = translation

            playerViewModel.dragOffset.height = max(0, playerViewModel.dragOffset.height + diff)
            
        } else if gesture.state == .ended {
            
            self.prevTranslation = .zero
            withAnimation(.linear(duration: 0.15)) {
                if playerViewModel.dragOffset.height > SCREEN_HEIGHT / 4 {
                    ConversationViewModel.shared.showConversationPlayer = false
                    playerViewModel.dragOffset = .zero
                } else {
                    playerViewModel.dragOffset = .zero
                }
            }
        }
    }
    
    @objc
    func playerItemDidReachEnd(notification: Notification) {
        playerLayer.player?.seek(to: CMTime.zero)
    }
    
    private func addAllVideosToPlayer() {
        
        if let player = playerLayer.player as? AVQueuePlayer {
            for item in items {
                if player.canInsert(item, after: player.items().last) {
                    player.insert(item, after: player.items().last)
                }
            }
            
            player.seek(to: .zero)

        }
    }
    
    private func updateDateString() {
        let viewModel = ConversationPlayerViewModel.shared
        if let playerItem = (playerLayer.player as? AVQueuePlayer)?.items().first, let index = items.firstIndex(where: {$0 == playerItem}) {
            viewModel.dateString = viewModel.dates[index].getFormattedDate()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    
    
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

