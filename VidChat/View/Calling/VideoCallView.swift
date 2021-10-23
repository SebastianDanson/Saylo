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
    @Binding var isFrontFacing: Bool
    @Binding var showVideo: Bool

    @EnvironmentObject var callsController: CallManager
    let call: Call
    
    func makeUIViewController(context: Context) -> VideoCallViewController {
        let agoraViewController = VideoCallViewController()
        agoraViewController.callManger = callsController
        agoraViewController.call = call
        agoraViewController.agoraDelegate = context.coordinator
        return agoraViewController
    }
    
    func updateUIViewController(_ uiViewController: VideoCallViewController, context: Context) {
        uiViewController.didTapMuteButton(isMuted: isMuted)
        uiViewController.didTapSwitchCameraButton(isFrontFacing: isFrontFacing)
        uiViewController.didTapVideoButton(showVideo: showVideo)
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
