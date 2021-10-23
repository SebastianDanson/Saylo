//
//  VideoCallViewController.swift
//  VidChat
//
//  Created by Student on 2021-10-20.
//


import Foundation
import AgoraRtcKit
import UIKit

class VideoCallViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var callManger: CallManager!
    var call: Call!
    
    var agoraKit: AgoraRtcEngineKit?
    var agoraDelegate: AgoraRtcEngineDelegate?
    var inCall = false
    let tempToken: String? = nil //If you have a token, put it here.
    var callID: UInt = 0 //This tells Agora to generate an id for you. We have user IDs from Firebase, but they aren't Ints, and therefore won't work with Agora.
    var channelName: String?
    var remoteUserIDs: [UInt] = [] {
        didSet {
            if remoteUserIDs.count == 0 {
                callManger.end(call: call)
                callManger.removeCall(call)
            } else {
                shrinkLocalView()
            }
        }
    }
    
    var collectionView: UICollectionView!
    private var reuseIdentifier = "VideoCollectionViewCell"
    private let localView = UIView()
    var localViewWidthAnchor: NSLayoutConstraint!
    var localViewHeightAnchor: NSLayoutConstraint!
    var localViewRightAnchor: NSLayoutConstraint!
    var localViewTopAnchor: NSLayoutConstraint!
    
    let localWidth = UIScreen.main.bounds.width * 0.22
    let localHeight = UIScreen.main.bounds.height * 0.22
    var isFrontFacing = true
    
    private let topPadding = UIApplication.shared.windows[0].safeAreaInsets.top
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white
        collectionView.allowsMultipleSelection = true
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.frame = view.bounds
        collectionView.insetsLayoutMarginsFromSafeArea = false
        collectionView.contentInsetAdjustmentBehavior = .never
        getAgoraEngine().setChannelProfile(.communication)
        setUpVideo()
        
        view.backgroundColor = .green
        
        view.addSubview(localView)
        localView.translatesAutoresizingMaskIntoConstraints = false
        localViewTopAnchor = localView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        localViewRightAnchor = localView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0)
        localViewHeightAnchor = localView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height)
        localViewWidthAnchor = localView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        
        localViewTopAnchor.isActive = true
        localViewRightAnchor.isActive = true
        localViewHeightAnchor.isActive = true
        localViewWidthAnchor.isActive = true
        
        localView.layer.cornerRadius = 8
        localView.clipsToBounds = true
        
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = callID
        videoCanvas.view = localView
        getAgoraEngine().setupLocalVideo(videoCanvas)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.joinChannel(channelName: call.uuid.uuidString)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        leaveChannel()
        destroyInstance()
    }
    
    private func getAgoraEngine() -> AgoraRtcEngineKit {
        if agoraKit == nil {
            agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppId, delegate: self)
        }
        return agoraKit!
    }
    
    func shrinkLocalView() {
        localViewTopAnchor.constant = 20 + topPadding
        localViewRightAnchor.constant = -20
        localViewHeightAnchor.constant = localHeight
        localViewWidthAnchor.constant = localWidth
        
        UIView.animate(withDuration: 0.5) {
            self.localView.layoutIfNeeded()
        }
    }
    
    func setUpVideo() {
        getAgoraEngine().enableVideo()
        let configuration = AgoraVideoEncoderConfiguration(size:
                                                            AgoraVideoDimension840x480, frameRate: .fps30, bitrate: 800,
                                                           orientationMode: .fixedPortrait)
        getAgoraEngine().setVideoEncoderConfiguration(configuration)
    }
    
    func initializeAgoraEngine() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppId, delegate: agoraDelegate)
    }
    
    func joinChannel(channelName: String) {
        getAgoraEngine().joinChannel(byToken: tempToken, channelId: channelName, info: nil, uid: callID) { [weak self] (sid, uid, elapsed) in
            self?.inCall = true
            self?.callID = uid
            self?.channelName = channelName
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if self.remoteUserIDs.count == 0 {
                self.callManger.end(call: self.call)
                self.callManger.removeCall(self.call)
            }
        }
    }
    
    func leaveChannel() {
        agoraKit?.leaveChannel(nil)
    }
    
    func destroyInstance() {
        AgoraRtcEngineKit.destroy()
    }
    
    func didTapMuteButton(isMuted: Bool) {
        print(isMuted,"MUTED")
        isMuted ? agoraKit?.muteLocalAudioStream(true) : agoraKit?.muteLocalAudioStream(false)
    }
    
    func didTapVideoButton(showVideo: Bool) {
        showVideo ? agoraKit?.enableVideo() : agoraKit?.disableVideo()
        localView.isHidden = !showVideo
    }
    
    func didTapSwitchCameraButton(isFrontFacing: Bool) {
        if self.isFrontFacing != isFrontFacing {
            agoraKit?.switchCamera()
        }
        self.isFrontFacing = isFrontFacing
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return remoteUserIDs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        let remoteID = remoteUserIDs[indexPath.row]
        if let videoCell = cell as? VideoCollectionViewCell {
            let videoCanvas = AgoraRtcVideoCanvas()
            videoCanvas.uid = remoteID
            videoCanvas.view = videoCell.videoView
            
            getAgoraEngine().setupRemoteVideo(videoCanvas)
            print("Creating remote view of uid: \(remoteID)")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numFeeds = remoteUserIDs.count
        
        let totalWidth = collectionView.frame.width - collectionView.adjustedContentInset.left - collectionView.adjustedContentInset.right
        let totalHeight = collectionView.frame.height - collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom
        
        if numFeeds == 1 {
            print(totalWidth, totalHeight)
            return CGSize(width: totalWidth, height: totalHeight)
        } else if numFeeds == 2 {
            return CGSize(width: totalWidth, height: totalHeight / 2)
        } else {
            if indexPath.row == numFeeds {
                return CGSize(width: totalWidth, height: totalHeight / 2)
            } else {
                return CGSize(width: totalWidth / CGFloat(numFeeds - 1), height: totalHeight / 2)
            }
        }
    }
}

extension VideoCallViewController: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        print("JOINED 1")
        callID = uid
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        print("Joined call of uid: \(uid)")
        remoteUserIDs.append(uid)
        
        collectionView.reloadData()
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        if let index = remoteUserIDs.firstIndex(where: { $0 == uid }) {
            remoteUserIDs.remove(at: index)
            collectionView.reloadData()
        }
    }
}
