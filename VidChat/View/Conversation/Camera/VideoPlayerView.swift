//
//  VideoPlayerView.swift
//  Saylo
//
//  Created by Student on 2021-09-27.
//

import SwiftUI
import AVKit


import AVKit
import SwiftUI

struct VideoPlayerView: View {
    
    @State var player: AVPlayer
        
    private var exporter: AVAssetExportSession?

 
    var showName: Bool = false
    var message: Message?
    
    init(url: URL, showName: Bool = true, message: Message? = nil) {
        let player = AVPlayer(url: url)
        self._player = State(initialValue: player) 
        self.showName = showName
        self.message = message

        player.automaticallyWaitsToMinimizeStalling = false
   
    }
    
  
    var body: some View {
                
        ZStack {
            
            PlayerView(player: $player, shouldLoop: true)
                .frame(width: SCREEN_WIDTH, height: MESSAGE_HEIGHT)
                .overlay(
                    HStack {
                        if showName && !(message?.isTeamSayloMessage ?? false) {
                            MessageInfoView(date: message?.timestamp.dateValue() ?? Date(),
                                            profileImage: message?.userProfileImage ?? "",
                                            name: message?.username ?? "", showTwoTimeSpeed: true)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 26)
                        }
                    },
                    alignment: .bottomLeading)
                .onTapGesture {
                    togglePlay()
                }
                .onAppear {
                    
                    DispatchQueue.main.async {
                        
                        if let id = message?.id {
                            
                             ConversationViewModel.shared.addPlayer(MessagePlayer(player: self.player, messageId: id))
                                                                                    
                            if let chat = ConversationViewModel.shared.chat,
                                chat.messages.count > chat.lastReadMessageIndex,
                                chat.lastReadMessageIndex > -1,
                                chat.messages[chat.lastReadMessageIndex].id == id {
                                
                                ConversationViewModel.shared.currentPlayer = self.player
                                ConversationViewModel.shared.currentPlayer?.playWithRate()
                            }
                        }
                    }
                }
        }
    }
    
    func togglePlay() {
      
        if player.isPlaying {
            player.pause()
        } else {
            player.playWithRate()
            if ConversationViewModel.shared.chat != nil, ConversationViewModel.shared.showCamera == false {
                ConversationViewModel.shared.currentPlayer = self.player
            }
        }
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
    let shouldLoop: Bool
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
    }
    
    func makeUIView(context: Context) -> UIView {
        let playerView = PlayerUIView(frame: .zero, player: player, shouldLoop: shouldLoop)
        return playerView
    }
}


class PlayerUIView: UIView {
    
    private let playerLayer = AVPlayerLayer()
    private var exporter: AVAssetExportSession?
    private var items = [AVPlayerItem]()
    private var token: NSKeyValueObservation?
    private var prevTranslation: CGPoint = .zero
    private var progressBarHighlightedObserver: NSKeyValueObservation?
    private var timeObserverToken: Any?
//    private let playbackSlider = UISlider()
    private var shouldLoop = false
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        playerLayer.player?.pause()
        playerLayer.player = nil
        removePeriodicTimeObserver()
    }
    
    
    init(frame: CGRect, player: AVPlayer, shouldLoop: Bool = true) {
        
        super.init(frame: frame)
        // Setup the player
        playerLayer.player = player

        playerLayer.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: MESSAGE_HEIGHT)

//        playerLayer.cornerRadius = 20
        
        let vm = ConversationViewModel.shared
        let messages = vm.showSavedPosts ? vm.savedMessages : vm.messages
        
        if messages[ConversationViewModel.shared.index].isFromPhotoLibrary {
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        } else {
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        }

        backgroundColor = .clear
//        self.layer.masksToBounds = true
//        self.layer.cornerRadius = 20

        layer.addSublayer(playerLayer)

//        playbackSlider.setDimensions(height: 30, width: ConversationViewModel.shared.showCamera ? SCREEN_WIDTH - 64 : SCREEN_WIDTH - 100)
//        playbackSlider.minimumValue = 0
//        playbackSlider.maximumValue = 1
//        playbackSlider.thumbTintColor = .clear
//
//        playbackSlider.isContinuous = true
//        playbackSlider.tintColor = UIColor.white
//
//        playbackSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
//        self.addSubview(playbackSlider)
//        playbackSlider.centerX(inView: self)
//        playbackSlider.anchor(bottom: bottomAnchor, paddingBottom: 8)
//        addPeriodicTimeObserver()
        
//        if ConversationViewModel.shared.showCamera {
//            playbackSlider.isHidden = true
//        }
//
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(playerItemDidReachEnd(notification:)),
//                                               name: .AVPlayerItemDidPlayToEndTime,
//                                               object: nil)
        
        self.shouldLoop = shouldLoop
        
        if !shouldLoop, let player = player as? AVQueuePlayer {
            items = player.items()
        }
        
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
//        } catch(let error) {
//            print(error.localizedDescription)
//        }
        
        
        if !shouldLoop || ConversationViewModel.shared.showCamera {
            player.playWithRate()
        }
        
//        if !shouldLoop {
//
//            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//            self.addGestureRecognizer(tap)
//            
//            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
//            self.addGestureRecognizer(pan)
//        }
        
    }
    
    func addPeriodicTimeObserver() {
        // Notify every half second
//        let timeScale = CMTimeScale(NSEC_PER_SEC)
//        let time = CMTime(seconds: 0.05, preferredTimescale: timeScale)
//        
//        timeObserverToken = playerLayer.player?.addPeriodicTimeObserver(forInterval: time,
//                                                                        queue: .main) {
//            [weak self] time in
//            
//            if self?.playbackSlider.state ?? .normal == .normal {
//                let duration : CMTime = self?.playerLayer.player?.currentItem?.asset.duration ?? .zero
//                
//                self?.playbackSlider.setValue(Float(CMTimeGetSeconds(time) / CMTimeGetSeconds(duration)), animated: true)
//                self?.playbackSlider.thumbTintColor = .clear
//            }
//        }
    }
    
    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            playerLayer.player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
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
    func playbackSliderValueChanged(_ playbackSlider:UISlider)
    {
        
        playbackSlider.thumbTintColor = .white
        let seconds : Double = Double(playbackSlider.value)
        let duration = playerLayer.player?.currentItem?.asset.duration ?? .zero
        
        let targetTime:CMTime = CMTime(seconds: duration.seconds * seconds, preferredTimescale: 1)
        playerLayer.player?.seek(to: targetTime)
        
        if playerLayer.player?.rate == 0
        {
            playerLayer.player?.playWithRate()
        }
    }
    
    @objc
    func handleTap(_ sender: UITapGestureRecognizer) {
        let xLoc = sender.location(in: self).x
        
        if xLoc > SCREEN_WIDTH/2 {
            ConversationViewModel.shared.showNextMessage()
        } else  {
            ConversationViewModel.shared.showPreviousMessage()
        }
    }
    
    @objc
    func playerItemDidReachEnd(notification: Notification) {
                
//        if shouldLoop {
           
//        ConversationViewModel.shared.showNextMessage()
            

//            
//            if !ConversationViewModel.shared.showCamera {
//            }
//        } else {
//            ConversationViewModel.shared.showNextMessage()
//        }
    }
}

extension AVPlayer {
    
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
    
    func playWithRate() {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch(let error) {
            print("ERROR With .playback " + error.localizedDescription)
        }
        
        self.play()
        self.rate = !ConversationViewModel.shared.showCamera && ConversationViewModel.shared.isTwoTimesSpeed ? 2 : 1
    }
}

