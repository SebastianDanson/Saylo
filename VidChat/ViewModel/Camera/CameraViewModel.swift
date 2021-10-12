//
//  CameraViewModel.swift
//  VidChat
//
//  Created by Student on 2021-09-27.
//

import Foundation
import Firebase

class CameraViewModel: ObservableObject {
    
    @Published var url: URL?
    @Published var croppedUrl: URL?
    @Published var hasFlash = false
    @Published var progress = 0.0
    @Published var isRecording = false
    @Published var showCamera = false
    @Published var cameraView = CameraMainView()

    static let shared = CameraViewModel()
    
    private init() {}
    
    func removeVideo() {
        url = nil
        progress = 0.0
        isRecording = false
        croppedUrl = nil
    }
    
    func reset() {
        url = nil
        croppedUrl = nil
        progress = 0.0
        isRecording = false
        showCamera = false
    }
    
    func startRecording(addDelay: Bool = false) {
        self.showCamera = true
        self.isRecording = true
        self.progress = 1
        
        if addDelay {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
            if isRecording {
               stopRecording()
            } else {
                startRecording()
            }
        } else {
            startRecording(addDelay: true)
        }
    }
}
