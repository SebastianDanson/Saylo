//
//  CameraViewModel.swift
//  Saylo
//
//  Created by Student on 2021-09-27.
//

import Foundation
import Firebase
import SwiftUI
import Photos

class CameraViewModel: ObservableObject {
    
    @Published var videoUrl: URL?
    @Published var photo: UIImage?
    @Published var hasFlash = false
    @Published var progress = 0.0
    @Published var isRecording = false
    @Published var isShowingPhotoCamera = false
    @Published var isTakingPhoto = false
    @Published var hasSentWithoutCrop = false
    @Published var isPlaying = false
    @Published var isFirstLoad = true
    @Published var isFrontFacing = true
    @Published var isRotating = false
    
    var timer: Timer?
    
    var cameraView = CameraMainView()
    var videoPlayerView: VideoPlayerView? {
        didSet {
            playVideo()
        }
    }
    
    static let shared = CameraViewModel()
    
    private init() {
        //        cameraView.setupSession()
    }
    
    
    func playVideo() {
        
        guard let videoPlayerView = videoPlayerView else {
            return
        }
        
        videoPlayerView.player.play()
        
        if !videoPlayerView.player.isPlaying {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.playVideo()
            }
        }
    }
    
    func removeVideo() {
        videoUrl = nil
        progress = 0.0
        isRecording = false
    }
    
    func reset(hideCamera: Bool = false) {
        
        if !isRecording && videoUrl == nil && photo == nil || hideCamera {
            closeCamera()
            isShowingPhotoCamera = false
            
            if ConversationViewModel.shared.selectedChat != nil {
                ConversationViewModel.shared.selectedChat = nil
                ConversationViewModel.shared.chatId = ""
            }
            
            //            cameraView.cancelRecording()
            //            cameraView.addAudio()
        }
        
        videoPlayerView = nil
        videoUrl = nil
        progress = 0.0
        isRecording = false
        photo = nil
        
        
        ConversationGridViewModel.shared.stopSelectingChats()
        ConversationGridViewModel.shared.selectedChats = [Chat]()
    }
    
    func closeCamera() {
        withAnimation(.linear(duration: 0.15)) {
            ConversationViewModel.shared.showCamera = false
        }
    }
    
    func startRecording(addDelay: Bool = false) {
        
        if addDelay {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    self.isRecording = true
                    self.progress = 1
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.cameraView.startRecording()
                
            }
            
        } else {
            self.cameraView.startRecording()
            withAnimation {
                self.isRecording = true
                self.progress = 1
            }
        }
        
    }
    
    func stopRecording() {
        self.cameraView.stopRecording()
        self.isRecording = false
        self.progress = 0
        
        timer?.invalidate()
    }
    
    func handleTap() {
        

        if ConversationViewModel.shared.showCamera {
            if CameraViewModel.shared.isShowingPhotoCamera {
                takePhoto()
            } else {
                isRecording ? stopRecording() : startRecording()
            }
        } else {
            cameraView.addAudio()
            cameraView.startRunning()
            startRecording(addDelay: true)
        }
    }
    
    func startRunning() {
        cameraView.startRunning()
    }
    
    func takePhoto() {
        self.cameraView.takePhoto()
    }
    
    func toggleIsFrontFacing() {
        
        
        withAnimation {
            
            self.isRotating = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.isFrontFacing.toggle()
                self.isRotating = false
            }
        }
        self.cameraView.switchCamera()
    }
    
    func setVideoPlayer() {
        if let videoUrl = videoUrl {
            videoPlayerView = VideoPlayerView(url: videoUrl, showName: false)
        }
        
        
    }
    
    //    func requestAuthorization(completion: @escaping ()->Void) {
    //            if PHPhotoLibrary.authorizationStatus() == .notDetermined {
    //                PHPhotoLibrary.requestAuthorization { (status) in
    //                    DispatchQueue.main.async {
    //                        completion()
    //                    }
    //                }
    //            } else if PHPhotoLibrary.authorizationStatus() == .authorized{
    //                completion()
    //            }
    //        }
    
    func saveToPhotos(url: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { saved, error in
            print(saved, "SAVED", error, "ERROR")
        }
    }
    
    func saveToPhotos(photo: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: photo)
        }) { saved, error in
            print(saved, "SAVED", error, "ERROR")
        }
    }
}
