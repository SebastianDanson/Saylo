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
    
    var agoraKit: AgoraRtcEngineKit?
    var agoraDelegate: AgoraRtcEngineDelegate?
    var inCall = false
    let tempToken: String? = nil //If you have a token, put it here.
    var callID: UInt = 0 //This tells Agora to generate an id for you. We have user IDs from Firebase, but they aren't Ints, and therefore won't work with Agora.
    var channelName: String?
    var remoteUserIDs: [UInt] = []
    var collectionView: UICollectionView!
    private var reuseIdentifier = "VideoCollectionViewCell"
    private let localView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .blue
        collectionView.allowsMultipleSelection = true
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true

        getAgoraEngine().setChannelProfile(.communication)
        setUpVideo()
        view.backgroundColor = .black
        
//        view.addSubview(localView)
//        localView.translatesAutoresizingMaskIntoConstraints = false
//        localView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
//        localView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
//        localView.heightAnchor.constraint(equalToConstant: width * 16/9).isActive = true
//        localView.widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.joinChannel(channelName: "testChannel")
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
    }
    
    func leaveChannel() {
            agoraKit?.leaveChannel(nil)
        }
    
    func destroyInstance() {
           AgoraRtcEngineKit.destroy()
       }
    
    func didClickMuteButton(isMuted: Bool) {
        isMuted ? agoraKit?.muteLocalAudioStream(true) : agoraKit?.muteLocalAudioStream(false)
      }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return remoteUserIDs.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        if indexPath.row == remoteUserIDs.count { //Put our local video last
            if let videoCell = cell as? VideoCollectionViewCell {
                let videoCanvas = AgoraRtcVideoCanvas()
                videoCanvas.uid = callID
                videoCanvas.view = videoCell.videoView
                videoCanvas.renderMode = .fit
                getAgoraEngine().setupLocalVideo(videoCanvas)
            }
        } else {
            let remoteID = remoteUserIDs[indexPath.row]
            if let videoCell = cell as? VideoCollectionViewCell {
                let videoCanvas = AgoraRtcVideoCanvas()
                videoCanvas.uid = remoteID
                videoCanvas.view = videoCell.videoView
                videoCanvas.renderMode = .fit
                getAgoraEngine().setupRemoteVideo(videoCanvas)
                print("Creating remote view of uid: \(remoteID)")
            }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let numFeeds = remoteUserIDs.count + 1

        let totalWidth = collectionView.frame.width - collectionView.adjustedContentInset.left - collectionView.adjustedContentInset.right
        let totalHeight = collectionView.frame.height - collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom

        if numFeeds == 1 {
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
