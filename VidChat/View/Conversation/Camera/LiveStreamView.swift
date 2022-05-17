//
//  LiveStreamView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-05-17.
//

import UIKit
import AgoraRtcKit
import SwiftUI

struct LiveStreamView: UIViewRepresentable {
    
    typealias UIViewType = LiveStreamUIView
    
    @Binding var isFrontFacing: Bool
    var isHost: Bool
    
    func makeUIView(context: Context) -> LiveStreamUIView {
        let liveSteamView = LiveStreamUIView()
        liveSteamView.setUpVideo(isHost: isHost)
        liveSteamView.layer.cornerRadius = 14
        return liveSteamView
    }
    
    func updateUIView(_ uiView: LiveStreamUIView, context: Context) {
        uiView.didTapSwitchCameraButton()
    }
}


class LiveStreamUIView: UIView, AgoraRtcEngineDelegate {
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    func getAgoraEngine() -> AgoraRtcEngineKit! {
        
        if ConversationViewModel.shared.agoraKit == nil {
            ConversationViewModel.shared.agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppId, delegate: self)
        }
        
        return ConversationViewModel.shared.agoraKit!
    }
    
    deinit {
        getAgoraEngine().leaveChannel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didTapSwitchCameraButton() {
       getAgoraEngine().switchCamera()
    }
    
    func leaveChannel() {
        getAgoraEngine().leaveChannel()
    }
    
    func setUpVideo(isHost: Bool) {
        
        let uid: UInt = isHost ? 0 : 1
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = self
        
        if isHost {
            getAgoraEngine().setupLocalVideo(videoCanvas)
        } else {
            getAgoraEngine().setupRemoteVideo(videoCanvas)
        }

        getAgoraEngine().enableVideo()

        let configuration = AgoraVideoEncoderConfiguration(size: CGSize(width: 1080, height: 1920), frameRate: .fps30, bitrate: 4000,
                                                           orientationMode: .fixedPortrait)
        getAgoraEngine().setVideoEncoderConfiguration(configuration)
        
        getAgoraEngine().setChannelProfile(.liveBroadcasting)

        let options: AgoraClientRoleOptions = AgoraClientRoleOptions()
        options.audienceLatencyLevel = AgoraAudienceLatencyLevelType.lowLatency
        getAgoraEngine().setClientRole(isHost ? .broadcaster : .audience, options: options)
        
//        let channelId = isHost ? AuthViewModel.shared.getUserId() : ConversationViewModel.shared.currentlyWatchingId ?? ""
        getAgoraEngine().joinChannel(byToken: nil, channelId: ConversationViewModel.shared.chatId, info: nil, uid: isHost ? 1:0)
    }
    
//    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid: UInt, size: CGSize, elapsed: Int) {
//           let videoCanvas = AgoraRtcVideoCanvas()
//           videoCanvas.uid = uid
//           let hostingView = UIView()
//           self.addSubview(hostingView)
//           videoCanvas.view = hostingView
//           videoCanvas.renderMode = .hidden
//           getAgoraEngine().setupRemoteVideo(videoCanvas)
//        print(uid, "IDID")
//       }
}

