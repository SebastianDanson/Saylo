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
    @Published var isTakingPhoto = false
    @Published var showCamera = false
    @Published var cameraView = CameraMainView()
    @Published var hasSentWithoutCrop = false
    
    static let shared = CameraViewModel()
    
    private init() {}
    
    func removeVideo() {
        videoUrl = nil
        progress = 0.0
        isRecording = false
    }
    
    func reset() {
        videoUrl = nil
        progress = 0.0
        isRecording = false
        showCamera = false
        isTakingPhoto = false
        photo = nil
    }
    
    func startRecording(addDelay: Bool = false) {
       
        withAnimation {
            self.showCamera = true
            self.isRecording = true
            self.progress = 1
        }
        
        if addDelay {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
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
        if showCamera {
            if CameraViewModel.shared.isTakingPhoto {
                takePhoto()
            } else {
                isRecording ? stopRecording() : startRecording()
            }
        } else {
            startRecording(addDelay: true)
        }
    }
    
    func takePhoto() {
        self.cameraView.takePhoto()
    }
}
