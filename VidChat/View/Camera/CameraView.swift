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
  private let cameraViewController = CameraViewController()
  @State var videoUrl: URL? = nil
    //   @Binding var finishedRecording: Bool
  @EnvironmentObject var viewModel: CameraViewModel

//    init(viewModel: CameraViewModel) {
//        self.viewModel = viewModel
//    }
    
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
            print(url, "outputFileURL")
            self.parent.videoUrl = url
            self.parent.viewModel.setUrl(url)
            self.parent.viewModel.setHasRecordedVideo()
        }
        
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
    }
    
  public func switchCamera() {
    cameraViewController.switchCamera()
  }

  public func startRecording() {
    cameraViewController.captureMovie()
  }

  public func stopRecording() {
    cameraViewController.stopRecording()
  }
    
  public func getVideoUrl() -> URL? {
    print(videoUrl, "URL")
     return videoUrl
 }
}


