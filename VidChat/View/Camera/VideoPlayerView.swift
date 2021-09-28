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
    
    init(url: URL) {
        print(url,"URL")
        player = AVPlayer(url: url)
        self.player.play()
    }
    
    var body: some View {
        VideoPlayer(player: $player).ignoresSafeArea()
            
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
        controller.videoGravity = .resizeAspect
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<VideoPlayer>) {
        
        
    }
}
