//
//  CameraView.swift
//  VidChat
//
//  Created by Student on 2021-09-27.
//

import Foundation
import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = CameraViewController
    private var cameraViewController = CameraViewController()
    @EnvironmentObject var viewModel: CameraViewModel
    
    func makeUIViewController(context: Context) -> CameraViewController {
        cameraViewController.delegate = context.coordinator
        return cameraViewController
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CameraViewControllerDelegate {
        func setVideo(withUrl url: URL) {
            self.parent.viewModel.url = url
            print(url, "URL")
            self.parent.viewModel.hasRecordedVideo = true
        }
        
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
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
}


