//
//  CameraViewController.swift
//  VidChat
//
//  Created by Student on 2021-09-27.
//

import UIKit
import AVFoundation
import SwiftUI
import PhotosUI

protocol CameraViewControllerDelegate: AnyObject {
    func setVideo(withUrl url: URL)
}

class CameraViewController: UIViewController {
    
    weak var delegate: CameraViewControllerDelegate?
    
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    let movieOutput = AVCaptureMovieFileOutput()
    var hasFlash = false
    
    var tempURL: URL? {
        let directory = NSTemporaryDirectory() as NSString
        if directory != "" {
            let path = directory.appendingPathComponent("video.mov")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       setupSession()
        setupPreview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //TOOD stop session when chat is dismissed
       // stopSession()
    }
    
    func setupSession() {
        captureSession.beginConfiguration()
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            return
        }
        guard let mic = AVCaptureDevice.default(for: .audio) else {
            return
        }
        
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: camera)
            let audioInput = try AVCaptureDeviceInput(device: mic)
            for input in [videoInput, audioInput] {
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            }
            activeInput = videoInput
            
        } catch {
            print("Error setting device input: \(error)")
            return
        }
        captureSession.addOutput(movieOutput)
        captureSession.commitConfiguration()
        
    }
    
    func camera(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discovery = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        let devices = discovery.devices.filter {
            $0.position == position
        }
        return devices.first
    }
    
    public func switchCamera() {
        if movieOutput.isRecording {
            stopRecording()
            return
        }
        let position: AVCaptureDevice.Position = (activeInput.device.position == .back) ? .front : .back
        
        guard let device = camera(for: position) else {
            return
        }
        captureSession.beginConfiguration()
        captureSession.removeInput(activeInput)

        do {
            activeInput = try AVCaptureDeviceInput(device: device)

        } catch {
            print("error: \(error.localizedDescription)")
            return
        }
      
        captureSession.addInput(activeInput)
        captureSession.commitConfiguration()
        
        if hasFlash && movieOutput.isRecording {
            do {
                let device = activeInput.device
                try device.lockForConfiguration()
                if device.position == .back {
                    try device.setTorchModeOn(level:1.0)
                }
                device.unlockForConfiguration()
            } catch {
                
            }
        }
    }
    
    func setupPreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        let width = UIScreen.main.bounds.width
        let height = width * 1.25

        previewLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }
    
    func startSession() {
      if !captureSession.isRunning {
        DispatchQueue.global(qos: .default).async { [weak self] in
            print("RUNNING STARTED")
          self?.captureSession.startRunning()
        }
      }
    }
    
    func stopSession() {
//      if captureSession.isRunning {
//        DispatchQueue.global(qos: .default).async() { [weak self] in
//          self?.captureSession.stopRunning()
//            print("RUNNING ENDED")
//        }
//      }
    }
    
    public func captureMovie(withFlash hasFlash: Bool) {
        self.hasFlash = hasFlash

        let device = activeInput.device
        do {
            try device.lockForConfiguration()
            if device.isSmoothAutoFocusEnabled {
                device.isSmoothAutoFocusEnabled = true
            }
            
            if hasFlash && device.position == .back {
                try device.setTorchModeOn(level:1.0)
                device.torchMode = .on
            }
            
            device.unlockForConfiguration()
        
        } catch {
            print("error: \(error)")
        }

        guard let outUrl = tempURL else { return }
        
        movieOutput.startRecording(to: outUrl, recordingDelegate: self)
        
    }
    
    public func stopRecording() {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
            do {
                let device = activeInput.device
                try device.lockForConfiguration()
                if device.position == .back {
                    device.torchMode = .off
                }
                device.unlockForConfiguration()
            } catch {
                
            }
        }
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("error: \(error.localizedDescription)")
        } else {
            CameraViewModel.shared.url = outputFileURL

            cropVideo(outputFileURL, completion: { croppedURL in
                CameraViewModel.shared.croppedUrl = croppedURL
            })
              
           // delegate?.setVideo(withUrl: outputFileURL)
        }
    }
    
    func cropVideo( _ outputFileUrl: URL, completion: @escaping ( _ newUrl: URL ) -> () )
       {
           // Get input clip
           let videoAsset: AVAsset = AVAsset( url: outputFileUrl )
           let clipVideoTrack = videoAsset.tracks( withMediaType: AVMediaType.video ).first! as AVAssetTrack

           // Make video to square
           let videoComposition = AVMutableVideoComposition()
           videoComposition.renderSize = CGSize( width: clipVideoTrack.naturalSize.height, height: clipVideoTrack.naturalSize.height * 1.25 )
           videoComposition.frameDuration = CMTimeMake( value: 1, timescale: 30 )

           // Rotate to portrait
           let transformer = AVMutableVideoCompositionLayerInstruction( assetTrack: clipVideoTrack )
           let transform1 = CGAffineTransform( translationX: clipVideoTrack.naturalSize.height, y: -( clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height * 1.25 ) / 2 )
           let transform2 = transform1.rotated(by: .pi/2 )
           transformer.setTransform( transform2, at: CMTime.zero)

           let instruction = AVMutableVideoCompositionInstruction()
           instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTimeMakeWithSeconds( 20, preferredTimescale: 30 ) )

           instruction.layerInstructions = [transformer]
           videoComposition.instructions = [instruction]

           // Export
           let croppedOutputFileUrl = URL( fileURLWithPath: getOutputPath(NSUUID().uuidString))
           let exporter = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetHighestQuality)!
           exporter.videoComposition = videoComposition
           exporter.outputURL = croppedOutputFileUrl
           exporter.outputFileType = AVFileType.mov

           exporter.exportAsynchronously( completionHandler: { () -> Void in
               DispatchQueue.main.async(execute: {
                   completion( croppedOutputFileUrl )
               })
           })
       }
    
    func getOutputPath( _ name: String ) -> String
    {
        let documentPath = NSSearchPathForDirectoriesInDomains(      .documentDirectory, .userDomainMask, true )[ 0 ] as NSString
        let outputPath = "\(documentPath)/\(name).mov"
        return outputPath
    }
}
