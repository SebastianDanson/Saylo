//
//  CameraViewModel.swift
//  VidChat
//
//  Created by Student on 2021-09-27.
//

import Foundation
import Firebase
import SwiftUI

class CameraViewModel: ObservableObject {
    
    @Published var videoUrl: URL?
    @Published var photo: UIImage?
    @Published var hasFlash = false
    @Published var progress = 0.0
    @Published var isRecording = false
    @Published var isShowingPhotoCamera = false
    @Published var isTakingPhoto = false
    @Published var cameraView = CameraMainView()
    @Published var hasSentWithoutCrop = false
    @Published var isPlaying = false
    @Published var isFirstLoad = true
    
    static let shared = CameraViewModel()
    
    private init() {
        cameraView.setupSession()
    }
    
    func removeVideo() {
        videoUrl = nil
        progress = 0.0
        isRecording = false
    }
    
    func reset() {
        videoUrl = nil
        progress = 0.0
        isRecording = false
        isShowingPhotoCamera = false
        photo = nil
        
        withAnimation(.linear(duration: 0.15)) {
            ConversationViewModel.shared.showCamera = false
        }
        
        cameraView.cancelRecording()
         
        ConversationGridViewModel.shared.isSelectingUsers = false
        ConversationGridViewModel.shared.selectedUsers = [TestUser]()
    }
    
    func startRecording(addDelay: Bool = false) {
        
        withAnimation {
            ConversationViewModel.shared.showCamera = false
            self.isRecording = true
            self.progress = 1
        }
        
        //TODO keep caached if saved
        //  self.cameraView.addAudio()
        
        if addDelay {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.cameraView.startRecording()
            }
        } else {
            self.cameraView.startRecording()
        }
    }
    
    func stopRecording() {
        self.cameraView.stopRecording()
        self.isRecording = false
        self.progress = 0
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
            startRecording(addDelay: true)
        }
    }
    
    func takePhoto() {
        self.cameraView.takePhoto()
    }
}
