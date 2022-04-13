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

class MainViewModel: ObservableObject {
    
    @Published var videoUrl: URL?
    @Published var photo: UIImage?
    @Published var hasFlash = false
    @Published var isRecording = false
    @Published var isShowingPhotoCamera = false
    @Published var isPlaying = false
    @Published var isFrontFacing = true
    @Published var showAlert = false
    @Published var selectedView: MainViewType = .Video
    @Published var photoBaseHeight = PHOTO_PICKER_SMALL_HEIGHT
    @Published var showPhotos = false
    @Published var showAddFriends: Bool = false
    @Published var showFindFriends: Bool = false
    @Published var showNewChat: Bool = false
    @Published var showSettingsView: Bool = false
    @Published var isCalling: Bool = false
    @Published var chatsViewDragOffset: CGSize = .zero
    @Published var selectedMessage: Message?
    @Published var settingsChat: Chat?
    @Published var showAllowPhotoAccessAlert = false
    
    var audioRecorder = AudioRecorder()
    
    var isCameraAlert = false
    
    var timer: Timer?
    
    var cameraView = MainView()
    
    static let shared = MainViewModel()
    
    private init() {
        
        //        cameraView.setupSession()
    }
    
    
    func playVideo() {
        
        //        guard let videoPlayerView = videoPlayerView else {
        //            return
        //        }
        //
        //        videoPlayerView.player.playWithRate()
        //
        //        if !videoPlayerView.player.isPlaying {
        //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        //                self.playVideo()
        //            }
        //        }
    }
    
    func removeVideo() {
        videoUrl = nil
        isRecording = false
    }
    
    func reset() {
        
        if isRecording {
            selectedView == .Video ? cancelRecording() : audioRecorder.cancelRecording()
        }
        
        videoUrl = nil
        isRecording = false
        photo = nil
    }
    
    
    func startRecording(addDelay: Bool = false) {
        
        self.cameraView.startRecording()
        withAnimation {
            self.isRecording = true
        }
    }
    
    func stopRecording() {
        self.cameraView.stopRecording()
        self.isRecording = false
        
        timer?.invalidate()
    }
    
    func cancelRecording() {
        self.cameraView.cancelRecording()
        self.isRecording = false
        
        timer?.invalidate()
    }
    
    func handleSend() {
        
        withAnimation(.linear(duration: 0.2)) {
            
            let conversationVM = ConversationViewModel.shared
            
            if let chat = conversationVM.chat {
                conversationVM.sendCameraMessage(chatId: chat.id, chat: chat)
            }
            
            videoUrl = nil
            photo = nil
        }
    }
    
    func sendPhoto() {
        guard photo != nil, videoUrl == nil else { return }
        handleSend()
    }
    
    
    func handleAudioTap() {
        
        if self.isRecording {
            audioRecorder.stopRecording()
            self.isRecording = false
        } else {
            audioRecorder.startRecording()
            self.isRecording = true
        }
    }
    
    func handleTap() {
        isRecording ? stopRecording() : startRecording()
    }
    
    func startRunning() {
        cameraView.startRunning()
    }
    
    func takePhoto() {
        self.cameraView.takePhoto()
    }
    
    func setVideoPlayer() {
        //        if let videoUrl = videoUrl {
        //            videoPlayerView = VideoPlayerView(url: videoUrl, showName: false)
        //        }
    }
    
    func showCamera() -> Bool {
        selectedView == .Video  || selectedView == .Photo
    }
    
    func showRecordButton() -> Bool {
        (selectedView == .Video  || selectedView == .Voice) && !showPhotos
    }
    
    func handleRecordButtonTapped() {
        if selectedView == .Video {
            handleTap()
        } else if selectedView == .Voice {
            handleAudioTap()
        }
    }
    
    func handlePhotoButtonTapped() {
        if photo == nil {
            takePhoto()
        } else {
            sendPhoto()
        }
    }
    
    func getCameraWidth() -> CGFloat {
        CAMERA_WIDTH
    }
    
    func getCameraHeight() -> CGFloat {
        CAMERA_HEIGHT
    }
    
    
    func savePhoto() {
        
        guard let photo = photo else {
            return
        }
        
        saveToPhotos(photo: photo)
    }
    
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
    
    
    func getHasCameraAccess() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) != .denied
    }
    
    func getHasMicAccess() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .audio) != .denied
    }
}
