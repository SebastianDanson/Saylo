//
//  LiveStreamViewRepresentable.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-05-17.
//

import UIKit
import AgoraRtcKit
import SwiftUI

struct LiveStreamViewRepresentable: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = LiveStreamUIViewController
        
    func makeUIViewController(context: Context) -> LiveStreamUIViewController {
        let liveSteamView = LiveStreamUIViewController()
//        liveSteamView.setUpVideo(isHost: isHost)
//        liveSteamView.layer.cornerRadius = 14
        return liveSteamView
    }
    
    func updateUIViewController(_ uiViewController: LiveStreamUIViewController, context: Context) {
//        uiViewController.didTapSwitchCameraButton()
//        uiViewController.isHost = isHost
    }
}


class LiveStreamUIViewController: UIViewController {
    
    let localView = UIView()

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        leaveChannel()
        ConversationViewModel.shared.hideLiveView()
    }
    
    func getAgoraEngine() -> AgoraRtcEngineKit! {
        
        if ConversationViewModel.shared.agoraKit == nil {
            ConversationViewModel.shared.agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppId, delegate: self)
        }
        
        return ConversationViewModel.shared.agoraKit!
    }
    
    func didTapSwitchCameraButton() {
       getAgoraEngine().switchCamera()
    }
    
    func leaveChannel() {
        getAgoraEngine().leaveChannel()
    }
    
    func setUpVideo() {
        
        localView.removeFromSuperview()
        
        let isHost = ConversationViewModel.shared.currentlyWatchingId == nil

        self.view.addSubview(localView)
        self.view.layer.cornerRadius = 14
        
        localView.frame = CGRect(x: 0, y: TOP_PADDING_OFFSET, width: SCREEN_WIDTH, height: MESSAGE_HEIGHT)
        localView.layer.cornerRadius = 14
        localView.layer.masksToBounds = true
        

        let uid: UInt = isHost ? 0 : 1
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = localView
        
        if isHost {
            getAgoraEngine().setupLocalVideo(videoCanvas)
        } else {
            getAgoraEngine().setupRemoteVideo(videoCanvas)
        }

        getAgoraEngine().enableVideo()

        let configuration = AgoraVideoEncoderConfiguration(size:
                                                            AgoraVideoDimension1280x720, frameRate: .fps30, bitrate: 1710,
                                                           orientationMode: .fixedPortrait)
        
        getAgoraEngine().setVideoEncoderConfiguration(configuration)
        
        getAgoraEngine().setChannelProfile(.liveBroadcasting)

        let options: AgoraClientRoleOptions = AgoraClientRoleOptions()
        options.audienceLatencyLevel = AgoraAudienceLatencyLevelType.lowLatency
        getAgoraEngine().setClientRole(isHost ? .broadcaster : .audience, options: options)
        getAgoraEngine().setExternalVideoSource(true, useTexture: true, pushMode: true)
        let channelId = isHost ? AuthViewModel.shared.getUserId() : ConversationViewModel.shared.currentlyWatchingId ?? ""
        getAgoraEngine().joinChannel(byToken: nil, channelId: channelId, info: nil, uid: isHost ? 1 : 0)
//        { [weak self] (sid, uid, elapsed) in
//            print("SID:", sid, "UID:", uid, "ELAPSED:",elapsed)
//        }

    }
}

extension LiveStreamUIViewController: AgoraRtcEngineDelegate {
   
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        
        if uid == 1 {
            leaveChannel()
            ConversationViewModel.shared.hideLiveView()
        }
    }
}


