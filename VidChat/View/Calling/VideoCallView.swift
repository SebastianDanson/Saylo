//
//  ViewCallView.swift
//  Saylo
//
//  Created by Student on 2021-10-20.
//

import Foundation
import SwiftUI
import AgoraRtcKit

struct VideoCallView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = VideoCallViewController
    
    @Binding var isMuted: Bool
    @Binding var isFrontFacing: Bool
    @Binding var showVideo: Bool
    @Binding var showCallOptions: Bool
    
    @StateObject var callsController = CallManager.shared
    
    func makeUIViewController(context: Context) -> VideoCallViewController {
        let agoraViewController = VideoCallViewController()
        return agoraViewController
    }
    
    func updateUIViewController(_ uiViewController: VideoCallViewController, context: Context) {
        uiViewController.didTapMuteButton(isMuted: isMuted)
        uiViewController.didTapSwitchCameraButton(isFrontFacing: isFrontFacing)
        uiViewController.didTapVideoButton(showVideo: showVideo)
        uiViewController.toggleShowOptions(showOptions: showCallOptions)
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
