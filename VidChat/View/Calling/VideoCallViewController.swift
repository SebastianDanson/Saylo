//
//  VideoCallViewController.swift
//  Saylo
//
//  Created by Student on 2021-10-20.
//


import Foundation
import UIKit
import AgoraRtcKit
import AVFoundation

class VideoCallViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var callManger = CallManager.shared
    
    var collectionView: UICollectionView!
    private var reuseIdentifier = "VideoCollectionViewCell"
    let localView = UIView()
    var localViewWidthAnchor: NSLayoutConstraint!
    var localViewHeightAnchor: NSLayoutConstraint!
    var localViewRightAnchor: NSLayoutConstraint!
    var localViewTopAnchor: NSLayoutConstraint!
    var player: AVAudioPlayer?

    var isFrontFacing = true
    var isShowingOptions = true
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .black
//        collectionView.allowsMultipleSelection = true
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.frame = view.bounds
//        collectionView.insetsLayoutMarginsFromSafeArea = false
//        collectionView.contentInsetAdjustmentBehavior = .never
        
        callManger.setUpVideo()
        callManger.delegate = self
        
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
        videoCanvas.uid = callManger.callID
        videoCanvas.view = localView
        videoCanvas.mirrorMode = .auto

        callManger.getAgoraEngine().setupLocalVideo(videoCanvas)
        
        localView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ConversationViewModel.shared.showCall {
            
            callManger.joinChannel()
            
            if callManger.remoteUserIDs.count == 0 {
                playRingTone()
            }
        } else {
            callManger.joinChatChannel()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        callManger.endCalling()
    }
    
    func playRingTone() {
        
        let path = Bundle.main.path(forResource: "ringtone.wav", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = 2
            player?.playWithRate()
        } catch {
            print("COULD NOT PLAY")
        }
    }
    
    func getLocalViewDimensions() -> CGSize {
        let numFeeds = callManger.remoteUserIDs.count
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        let ratio = numFeeds > 3 ? 0.17 : 0.22
        
        switch numFeeds {
        case 0:
            return CGSize(width: width, height: height)
        case 1:
            return CGSize(width: width * ratio, height: height * ratio)
        case 2:
            return CGSize(width: width * ratio, height: height/2 * ratio)
        case 3, 4:
            return CGSize(width: width*ratio, height: height*ratio)
        case 5...8:
            return CGSize(width: width*ratio, height: height/ceil(CGFloat(numFeeds/2))*ratio * 2)
        default:
            return CGSize(width: width*ratio, height: width*ratio)
        }
    }
    
    func shrinkLocalView() {
        
        let size = getLocalViewDimensions()
        localViewHeightAnchor.constant = size.height
        localViewWidthAnchor.constant = size.width
        
        let showOptionsPadding: CGFloat = isShowingOptions ? 112 + BOTTOM_PADDING : 54
        let addedPadding = callManger.remoteUserIDs.count > 2 ? UIScreen.main.bounds.height - showOptionsPadding - size.height : TOP_PADDING
        localViewTopAnchor.constant = 20 + addedPadding
        localViewRightAnchor.constant = -20
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func didTapMuteButton(isMuted: Bool) {
        let kit = callManger.getAgoraEngine()
        isMuted ? kit.muteLocalAudioStream(true) : kit.muteLocalAudioStream(false)
    }
    
    func didTapVideoButton(showVideo: Bool) {
        let kit = callManger.getAgoraEngine()
        showVideo ? kit.enableVideo() : kit.disableVideo()
        localView.isHidden = !showVideo
    }
    
    func didTapSwitchCameraButton(isFrontFacing: Bool) {
        
        if self.isFrontFacing != isFrontFacing {
            callManger.getAgoraEngine().switchCamera()
        }
        self.isFrontFacing = isFrontFacing
    }
    
    func toggleShowOptions(showOptions: Bool) {
        if callManger.remoteUserIDs.count > 2 {
            if showOptions != isShowingOptions {
                let dif = 58 + BOTTOM_PADDING
                showOptions ? (localViewTopAnchor.constant -= dif) : (localViewTopAnchor.constant += dif)
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }
        
        isShowingOptions = showOptions
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return callManger.remoteUserIDs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! VideoCollectionViewCell
        
        let remoteID = callManger.remoteUserIDs[indexPath.row]
        if let videoCell = cell as? VideoCollectionViewCell {
            let videoCanvas = AgoraRtcVideoCanvas()
            videoCanvas.uid = remoteID
            videoCanvas.view = videoCell.videoView
            videoCanvas.mirrorMode = .auto
            callManger.getAgoraEngine().setupRemoteVideo(videoCanvas)
        }
        
        if callManger.remoteUserIDs.count > 2 {
            cell.layer.cornerRadius = 5
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if callManger.remoteUserIDs.count > 2 {
            return 4
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if callManger.remoteUserIDs.count > 2 {
            return 4
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numFeeds = callManger.remoteUserIDs.count
        let offset:CGFloat = numFeeds > 2 ? 4 : 0
        let width = UIScreen.main.bounds.width - offset
        let height = UIScreen.main.bounds.height - offset
        
        switch numFeeds {
        case 1:
            return CGSize(width: width, height: height)
        case 2:
            return CGSize(width: width, height: height/2)
        case 3, 4:
            return CGSize(width: width/2, height: height/2)
        case 5...8:
            return CGSize(width: width/2, height: height/ceil(CGFloat((numFeeds+1)/2)))
        default:
            return CGSize(width: width/2, height: width/2)
        }
    }
}

extension VideoCallViewController: CallManagerDelegate {
   
    func remoteUserToggledVideo() {
        
    }
    
    func remoteUserIDsUpdated() {
        collectionView.reloadData()
        shrinkLocalView()
        
        localView.isHidden = true
        if CallManager.shared.remoteUserIDs.count > 0 {
            player?.stop()
        }
    }
}

extension AVAudioPlayer {
    
    func playWithRate() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch(let error) {
            print(error.localizedDescription)
        }
        
        self.play()
        self.rate = ConversationViewModel.shared.isTwoTimesSpeed ? 2 : 1
    }
}
