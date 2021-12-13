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
                                if let i = ConversationViewModel.shared.messages
                                    .firstIndex(where: {$0.id == messageId}) {
                                    ConversationViewModel.shared.messages[i].isSaved.toggle()
                                    isSaved.toggle()
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
                            Image(systemName: "bookmark.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.mainBlue)
                                .frame(width: 36, height: 24)
                                .padding(.leading, 8)
                                .transition(.scale)
                        }
                        
                        
                    }
                    ,alignment: .center)
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

class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    private var exporter: AVAssetExportSession?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, player: AVPlayer) {
        super.init(frame: frame)
        // Setup the player
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspect
        
        layer.addSublayer(playerLayer)
        
        // Setup looping
        player.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
        
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
        } catch(let error) {
            print(error.localizedDescription)
        }
        
        player.play()
    }
    
    @objc
    func playerItemDidReachEnd(notification: Notification) {
        playerLayer.player?.seek(to: CMTime.zero)
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

