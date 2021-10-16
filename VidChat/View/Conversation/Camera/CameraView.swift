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
    
    func makeUIViewController(context: Context) -> CameraViewController {
      //  cameraViewController.delegate = context.coordinator
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
}


