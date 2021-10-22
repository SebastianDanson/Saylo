//
//  ViewCallView.swift
//  VidChat
//
//  Created by Student on 2021-10-20.
//

import Foundation
import SwiftUI
import AgoraRtcKit

struct VideoCallView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = VideoCallViewController
    
    @Binding var isMuted: Bool

    func makeUIViewController(context: Context) -> VideoCallViewController {
        let agoraViewController = VideoCallViewController()
        agoraViewController.agoraDelegate = context.coordinator
        return agoraViewController
    }
    
    func updateUIViewController(_ uiViewController: VideoCallViewController, context: Context) {
        isMuted ? (uiViewController.didClickMuteButton(isMuted: true)) : (uiViewController.didClickMuteButton(isMuted: false))
      }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, AgoraRtcEngineDelegate {
        var parent: VideoCallView
        init(_ agoraRep: VideoCallView) {
            parent = agoraRep
        }
      
    }
}
