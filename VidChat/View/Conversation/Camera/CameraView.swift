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
        //        cameraViewController.isVideo = MainViewModel.shared.isRecording
        return cameraViewController
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
    }
    
    public func switchCamera() {
        cameraViewController.switchCamera()
    }
    
    public func startRecording() {
//        cameraViewController.startMovieRecording()
    }
    
    public func stopRecording() {
//        cameraViewController.stopMovieRecording()
    }
    
    public func takephoto(withFlash hasFlash: Bool) {
        //        cameraViewController.takePhoto(withFlash: hasFlash)
    }
    
    public func cancelRecording() {
//        cameraViewController.stopMovieRecording(sendVideo: false)
        ConversationViewModel.shared.didCancelRecording = true
    }
    
//    public func addAudio() {
//        //        cameraViewController.setUpWriter()
//        //         cameraViewController.addAudio()
//    }
    
    public func setFilter(_ filter: Filter?) {
        cameraViewController.setVideoFilter(filter)
    }
    
    
    public func setupSession() {
        //        cameraViewController.setupSession()
        //        cameraViewController.setupPreview()
        //        cameraViewController.startSession()
        //        cameraViewController.setupAudio()
    }
    
    public func setupProfileImageCamera() {
        //        cameraViewController.setupSession(addAudio: false)
        //        cameraViewController.setupPreview()
        //        cameraViewController.startRunning()
    }
    
    public func startRunning() {
        //        cameraViewController.startRunning()
    }
    
    public func stopRunning() {
        //        cameraViewController.stopRunning()
    }
    
    
    public func stopSession() {
        //        cameraViewController.stopSession()
    }
    
//    public func setupWriter() {
        //        cameraViewController.setUpWriter()
//    }
}


