//
//  CameraView.swift
//  Saylo
//
//  Created by Student on 2021-09-27.
//

import Foundation
import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = CameraViewController
        
    var cameraViewController = CameraViewController()
    
    func makeUIViewController(context: Context) -> CameraViewController {
      //  cameraViewController.delegate = context.coordinator
        cameraViewController.isVideo = MainViewModel.shared.isRecording
        return cameraViewController
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
    }
    
    public func switchCamera() {
        cameraViewController.switchCamera()
    }
    
    public func startRecording(withFlash hasFlash: Bool = false) {
        cameraViewController.captureMovie(withFlash: hasFlash)
    }
    
    public func stopRecording() {
        cameraViewController.stopRecording()
    }
    
    public func takephoto(withFlash hasFlash: Bool) {
        cameraViewController.takePhoto(withFlash: hasFlash)
    }
    
    public func cancelRecording() {
        cameraViewController.stopRecording(showVideo: false)
    }
    
    public func addAudio() {
        cameraViewController.setUpWriter()
//         cameraViewController.addAudio()
    }
    
    public func setupSession() {
        cameraViewController.setupSession()
        cameraViewController.setupPreview()
        cameraViewController.startSession()
        
//        cameraViewController.setupAudio()
    }
    
    public func setupProfileImageCamera() {
        cameraViewController.setupSession(addAudio: false)
        cameraViewController.setupPreview()
        cameraViewController.startRunning()
    }
    
    public func startRunning() {
        cameraViewController.startRunning()
    }
    
    public func stopRunning() {
        cameraViewController.stopRunning()
    }

    
    public func stopSession() {
        cameraViewController.stopSession()
    }
    
    public func setupWriter() {
        cameraViewController.setUpWriter()
    }
}


