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
    
    var messageId: String?
    
    private var exporter: AVAssetExportSession?
    
    var width: CGFloat = SCREEN_WIDTH
    var height: CGFloat = SCREEN_WIDTH
    var showName: Bool = false
    var name: String?
    var profileImageUrl: String?
    
    init(url: URL, id: String? = nil, showName: Bool = true, date: Date? = nil, name: String? = nil, profileImage: String? = nil) {
        
        let player = AVPlayer(url: url)
        self.player = player
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
                            MessageInfoView(date: viewModel.date ?? Date(), profileImage: profileImageUrl ?? "", name: name ?? "")
                        }
                    },
                    alignment: .bottomLeading)
                .highPriorityGesture(TapGesture()
                                        .onEnded { _ in
                    viewModel.togglePlay()
                })
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
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerQueueView>) {
    }
    
    func makeUIView(context: Context) -> UIView {
        let playerView = PlayerUIView(frame: .zero, player: ConversationPlayerViewModel.shared.player, shouldLoop: false)
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
    private let playbackSlider = UISlider()
    private var shouldLoop = false
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        playerLayer.player?.pause()
        removePeriodicTimeObserver()
    }
    
    init(frame: CGRect, player: AVPlayer, shouldLoop: Bool = true) {
        
        super.init(frame: frame)
        // Setup the player
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspect
        
        layer.addSublayer(playerLayer)
        
        playbackSlider.setDimensions(height: 30, width: ConversationViewModel.shared.showCamera ? SCREEN_WIDTH - 64 : SCREEN_WIDTH - 100)
        playbackSlider.minimumValue = 0
        playbackSlider.maximumValue = 1
        playbackSlider.thumbTintColor = .clear
        
        playbackSlider.isContinuous = true
        playbackSlider.tintColor = UIColor.white
        
        playbackSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
        self.addSubview(playbackSlider)
        playbackSlider.centerX(inView: self)
        playbackSlider.anchor(bottom: bottomAnchor, paddingBottom: 8)
        
        addPeriodicTimeObserver()
        
        // Setup looping
        
        player.actionAtItemEnd = shouldLoop ? .none : .advance
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
        
        self.shouldLoop = shouldLoop
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
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            self.addGestureRecognizer(tap)
            
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            self.addGestureRecognizer(pan)
        }
        
    }
    
    func addPeriodicTimeObserver() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.05, preferredTimescale: timeScale)
        
        timeObserverToken = playerLayer.player?.addPeriodicTimeObserver(forInterval: time,
                                                                        queue: .main) {
            [weak self] time in
            
            if self?.playbackSlider.state ?? .normal == .normal {
                let duration : CMTime = self?.playerLayer.player?.currentItem?.asset.duration ?? .zero
                
                self?.playbackSlider.setValue(Float(CMTimeGetSeconds(time) / CMTimeGetSeconds(duration)), animated: true)
                self?.playbackSlider.thumbTintColor = .clear
            }
        }
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
        print(targetTime)
        playerLayer.player?.seek(to: targetTime)
        
        if playerLayer.player?.rate == 0
        {
            playerLayer.player?.play()
        }
    }
    
    @objc
    func handleTap(_ sender: UITapGestureRecognizer) {
        let xLoc = sender.location(in: self).x
        
        if xLoc > SCREEN_WIDTH/2 {
            ConversationPlayerViewModel.shared.handleShowNextMessage(wasInterrupted: true)
        } else  {
            ConversationPlayerViewModel.shared.handleShowPrevMessage()
        }
    }
    
    @objc
    func playerItemDidReachEnd(notification: Notification) {
        
        if shouldLoop {
            playerLayer.player?.seek(to: CMTime.zero)
        } else {
            ConversationPlayerViewModel.shared.handleShowNextMessage(wasInterrupted: false)
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

