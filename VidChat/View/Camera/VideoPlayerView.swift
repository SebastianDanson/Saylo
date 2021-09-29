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
    @EnvironmentObject var viewModel: CameraViewModel

    init(url: URL) {
        player = AVPlayer(url: url)
        player.automaticallyWaitsToMinimizeStalling = false
        self.player.play()
    }
    
    var body: some View {
        ZStack {
            PlayerView(player: $player)
            .scaleEffect(x: -1, y: 1, anchor: .center)
            .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {viewModel.url = nil}, label: {
                        ActionView(image: Image("x"),
                                   imageDimension: 16, circleDimension: 36)
                    })
                   
                        
                }
                Spacer()
                
                HStack {
                    ActionView(image: Image(systemName: "square.and.arrow.down"),
                               imageDimension: 28, circleDimension: 60)
                    Spacer()
                Button(action: {}, label: {
                    HStack {
                        Rectangle()
                            .frame(width: 130, height: 40)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .overlay(
                                HStack(spacing: 10) {
                                    Text("Send To")
                                        .foregroundColor(.black)
                                        .font(.system(size: 18, weight: .bold))
                                    
                                    Image(systemName: "location.north.fill")
                                        .resizable()
                                        .rotationEffect(Angle(degrees: 90))
                                        .foregroundColor(.black)
                                        .frame(width: 20, height: 20)
                                        .scaledToFit()
                                }
                            )
                    }
                   
                })
                }.padding(20)
            }
        }
    }
}

//struct VideoPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoPlayerView()
//    }
//}


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
        controller.videoGravity = .resizeAspectFill
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
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(frame: CGRect, player: AVPlayer) {
        super.init(frame: frame)
        
        
        // Setup the player
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
        // Setup looping
        player.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)

        // Start the movie
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
