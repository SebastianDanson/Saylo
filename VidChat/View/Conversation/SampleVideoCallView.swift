//
//  SampleVideoCallView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-05-22.
//

//import UIKit
//import AVKit
//import SwiftUI
//
//class SampleBufferVideoCallView: UIView {
//    override class var layerClass: AnyClass {
//        get { return AVSampleBufferDisplayLayer.self }
//    }
//
//    var sampleBufferDisplayLayer: AVSampleBufferDisplayLayer {
//        return layer as! AVSampleBufferDisplayLayer
//    }
//}
//
//struct AVVideoPlayer: UIViewControllerRepresentable {
//
//    func makeUIViewController(context: Context) -> AVPictureInPictureVideoCallViewController {
//        let pipVideoCallViewController = AVPictureInPictureVideoCallViewController()
//        pipVideoCallViewController.preferredContentSize = CGSize(width: 1080, height: 1920)
//        pipVideoCallViewController.view.addSubview(sampleBufferVideoCallView)
//        return pipVideoCallViewController
//    }
//
//    func updateUIViewController(_ uiViewController: AVPictureInPictureVideoCallViewController, context: Context) { }
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(self)
//    }
//
//    class Coordinator: NSObject, AVPictureInPictureVideoCallViewControllerDelegate {
//        let parent: AVVideoPlayer
//
//        init(_ parent: AVVideoPlayer) {
//            self.parent = parent
//        }
//
//    }
//}
