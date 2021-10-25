//
//  VideoCallViewController.swift
//  VidChat
//
//  Created by Student on 2021-10-20.
//


import Foundation
import UIKit
import AgoraRtcKit

class VideoCallViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var callManger: CallManager!
    
    var collectionView: UICollectionView!
    private var reuseIdentifier = "VideoCollectionViewCell"
    private let localView = UIView()
    var localViewWidthAnchor: NSLayoutConstraint!
    var localViewHeightAnchor: NSLayoutConstraint!
    var localViewRightAnchor: NSLayoutConstraint!
    var localViewTopAnchor: NSLayoutConstraint!
    
    var isFrontFacing = true
    var isShowingOptions = true
    
    var numFeeds = 2
    
    private let topPadding = UIApplication.shared.windows[0].safeAreaInsets.top
    private let bottomPadding = UIApplication.shared.windows[0].safeAreaInsets.bottom
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .black
        collectionView.allowsMultipleSelection = true
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.frame = view.bounds
        collectionView.insetsLayoutMarginsFromSafeArea = false
        collectionView.contentInsetAdjustmentBehavior = .never
        callManger.getAgoraEngine().setChannelProfile(.communication)
        
        // callManger.setUpVideo()
        callManger.delegate = self
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
        localView.backgroundColor = .mainBlue
        
        shrinkLocalView()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.numFeeds += 1
            self.collectionView.reloadData()
            self.shrinkLocalView()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.numFeeds += 1
            self.collectionView.reloadData()
            self.shrinkLocalView()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 9) {
            self.numFeeds += 1
            self.collectionView.reloadData()
            self.shrinkLocalView()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
            self.numFeeds += 1
            self.collectionView.reloadData()
            self.shrinkLocalView()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            self.numFeeds += 1
            self.collectionView.reloadData()
            self.shrinkLocalView()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 18) {
            self.numFeeds += 1
            self.collectionView.reloadData()
            self.shrinkLocalView()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 21) {
            self.numFeeds += 1
            self.collectionView.reloadData()
            self.shrinkLocalView()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 24) {
            self.numFeeds += 1
            self.collectionView.reloadData()
            self.shrinkLocalView()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 27) {
            self.numFeeds += 1
            self.collectionView.reloadData()
            self.shrinkLocalView()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            self.numFeeds += 1
            self.collectionView.reloadData()
            self.shrinkLocalView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callManger.joinChannel()
    }
    
    func getLocalViewDimensions() -> CGSize {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        let ratio = numFeeds - 1 > 3 ? 0.15 : 0.22
        
        switch numFeeds - 1 {
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
        
        let showOptionsPadding: CGFloat = isShowingOptions ? 112 + bottomPadding : 54
        let addedPadding = numFeeds > 3 ? UIScreen.main.bounds.height - showOptionsPadding - size.height : topPadding
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
        if numFeeds > 3 {
            if showOptions != isShowingOptions {
                let dif = 58 + bottomPadding
                showOptions ? (localViewTopAnchor.constant -= dif) : (localViewTopAnchor.constant += dif)
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }
        
        isShowingOptions = showOptions
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numFeeds - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! VideoCollectionViewCell
        
        //        let remoteID = callManger.remoteUserIDs[indexPath.row]
        //        if let videoCell = cell as? VideoCollectionViewCell {
        //            let videoCanvas = AgoraRtcVideoCanvas()
        //            videoCanvas.uid = remoteID
        //            videoCanvas.view = videoCell.videoView
        //
        //            callManger.getAgoraEngine().setupRemoteVideo(videoCanvas)
        //
        //            print("Creating remote view of uid: \(remoteID)")
        //        }
        
        if indexPath.row == 0 {
            cell.backgroundColor = UIColor.systemRed
        } else if indexPath.row == 1 {
            cell.backgroundColor = UIColor.systemOrange
        } else if indexPath.row == 2 {
            cell.backgroundColor = UIColor.systemPurple
        } else if indexPath.row == 3 {
            cell.backgroundColor = UIColor.systemGreen
        } else if indexPath.row == 4 {
            cell.backgroundColor = UIColor.systemYellow
        } else if indexPath.row == 5 {
            cell.backgroundColor = UIColor.systemOrange
        } else if indexPath.row == 6 {
            cell.backgroundColor = UIColor.systemPurple
        } else if indexPath.row == 7 {
            cell.backgroundColor = UIColor.systemGreen
        } else if indexPath.row == 8 {
            cell.backgroundColor = UIColor.systemYellow
        } else if indexPath.row == 9 {
            cell.backgroundColor = UIColor.systemOrange
        } else if indexPath.row == 10 {
            cell.backgroundColor = UIColor.systemPurple
        } else if indexPath.row == 11 {
            cell.backgroundColor = UIColor.systemGreen
        } else if indexPath.row == 12 {
            cell.backgroundColor = UIColor.systemYellow
        }
        
        if numFeeds - 1 > 2 {
            cell.layer.cornerRadius = 5
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if numFeeds - 1 > 2 {
            return 4
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if numFeeds - 1 > 2 {
            return 4
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let offset:CGFloat = numFeeds - 1 > 2 ? 4 : 0
        let width = UIScreen.main.bounds.width - offset
        let height = UIScreen.main.bounds.height - offset
        
        switch numFeeds - 1 {
        case 1:
            return CGSize(width: width, height: height)
        case 2:
            return CGSize(width: width, height: height/2)
        case 3, 4:
            return CGSize(width: width/2, height: height/2)
        case 5...8:
            return CGSize(width: width/2, height: height/ceil(CGFloat(numFeeds/2)))
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
    }
}
