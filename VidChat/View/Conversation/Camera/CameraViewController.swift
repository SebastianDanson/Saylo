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
    
    private struct Recording {
        let asset: AVURLAsset
        let isFrontFacing:Bool
    }
    
    //TODO flash on photo
    
    //Zoom propertis
    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 5.0
    var lastZoomFactor: CGFloat = 1.0
    
//    let videoDataOutput = AVCaptureVideoDataOutput()
//    let audioDataOutput = AVCaptureAudioDataOutput()

    private var recordings = [AVURLAsset]()
    
    weak var delegate: CameraViewControllerDelegate?
    
    let captureSession = AVCaptureSession()

    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    let movieOutput = AVCaptureMovieFileOutput()

    let photoOutput = AVCapturePhotoOutput()
    var hasFlash = false
    var hasSwitchedCamera = false
    var isVideo: Bool!
    let audioRecorder = AudioRecorder()
    
    var videoWriter: AVAssetWriter!
    var videoWriterInput: AVAssetWriterInput!
    var audioWriterInput: AVAssetWriterInput!
    var sessionAtSourceTime: CMTime!
    var audioSessionAtSourceTime: CMTime!

    var outputURL: URL!
    
   
    
    override func viewWillDisappear(_ animated: Bool) {
        //TOOD stop session when chat is dismissed
        // stopSession()
        self.recordings = [AVURLAsset]()
    }
    
    func getTempUrl() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        if directory != "" {
            let path = directory.appendingPathComponent("\(UUID().uuidString).mov")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    func setupSession() {
        captureSession.automaticallyConfiguresApplicationAudioSession = false
            captureSession.usesApplicationAudioSession = true

        captureSession.beginConfiguration()

        let audioSession = AVAudioSession.sharedInstance()
       // try! audioSession.setActive(true)

     
        
        guard let mic = AVCaptureDevice.default(for: .audio) else {
            return
        }
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            return
        }

        do {
            
            try audioSession.setCategory(.playAndRecord, options: [.mixWithOthers, .defaultToSpeaker, .allowBluetoothA2DP, .allowAirPlay])
            
            let videoInput = try AVCaptureDeviceInput(device: camera)
            
                if captureSession.canAddInput(videoInput) {
                    captureSession.addInput(videoInput)
                }
                
            let audioInput = try! AVCaptureDeviceInput(device: mic)
                if (self.captureSession.canAddInput(audioInput)) {
                    self.captureSession.addInput(audioInput)
            }
            
            activeInput = videoInput
        
        } catch {
            print("Error setting device input: \(error)")
            return
        }
        
        captureSession.addOutput(movieOutput)
        captureSession.addOutput(photoOutput)

 
        captureSession.commitConfiguration()

       // captureSession.automaticallyConfiguresApplicationAudioSession = false
       // captureSession.usesApplicationAudioSession = true
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
            hasSwitchedCamera = true
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
            print("error switchCamera: \(error.localizedDescription)")
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

        if hasSwitchedCamera {
            print("CAPTURING MOVIE")
            captureMovie(withFlash: self.hasFlash)
        }
        
    }
    
    func setupPreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        view.layer.addSublayer(previewLayer)
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action:#selector(pinch(_:)))
        self.view.addGestureRecognizer(pinchRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action:#selector(pinch(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(pinchRecognizer)
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
            print("error captureMovie: \(error)")
        }
        
        guard let outUrl = getTempUrl() else { return }
        
        guard let connection = movieOutput.connection(with: .video) else { return }
        connection.isVideoMirrored = activeInput.device.position == .front
        print("STARTRECORDING")
        movieOutput.startRecording(to: outUrl, recordingDelegate: self)
    }
    
    
    func mergeVideoWithAudio(videoUrl: URL, audioUrl: URL, success: @escaping ((URL) -> Void), failure: @escaping ((Error?) -> Void)) {


        let mixComposition: AVMutableComposition = AVMutableComposition()
        var mutableCompositionVideoTrack: [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack: [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()

        let aVideoAsset: AVAsset = AVAsset(url: videoUrl)
        let aAudioAsset: AVAsset = AVAsset(url: audioUrl)

        if let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid), let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
            mutableCompositionVideoTrack.append(videoTrack)
            mutableCompositionAudioTrack.append(audioTrack)

        if let aVideoAssetTrack: AVAssetTrack = aVideoAsset.tracks(withMediaType: .video).first, let aAudioAssetTrack: AVAssetTrack = aAudioAsset.tracks(withMediaType: .audio).first {
            do {
                try mutableCompositionVideoTrack.first?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: CMTime.zero)
                try mutableCompositionAudioTrack.first?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: CMTime.zero)
                   videoTrack.preferredTransform = aVideoAssetTrack.preferredTransform

            } catch{
                print(error)
            }


           totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero,duration: aVideoAssetTrack.timeRange.duration)
        }
        }

        let mutableVideoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mutableVideoComposition.renderSize = CGSize(width: 480, height: 640)

      
        if let outputURL = getTempUrl() {

            do {
                if FileManager.default.fileExists(atPath: outputURL.path) {

                    try FileManager.default.removeItem(at: outputURL)
                }
            } catch { }

            if let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) {
                exportSession.outputURL = outputURL
                exportSession.outputFileType = AVFileType.mov
                exportSession.shouldOptimizeForNetworkUse = true

                /// try to export the file and handle the status cases
                exportSession.exportAsynchronously(completionHandler: {
                    switch exportSession.status {
                    case .failed:
                        if let _error = exportSession.error {
                            failure(_error)
                        }

                    case .cancelled:
                        if let _error = exportSession.error {
                            failure(_error)
                        }

                    default:
                        print("finished")
                        success(outputURL)
                    }
                })
            } else {
                failure(nil)
            }
        }
    }
    
    func addAudio() {
       
      //  if CameraViewModel.shared.isFirstLoad {
//        self.previewLayer.isHidden = true
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.previewLayer.isHidden = false
//        }
      //  }
     //   DispatchQueue.main.async {

           

          //  self.captureSession.commitConfiguration()

//        try! session.setActive(false)
//        try! session.setCategory(.playAndRecord, mode: .videoRecording, options: [.mixWithOthers, .defaultToSpeaker, .allowBluetooth, .allowAirPlay])
          //  captureSession.startRunning()
       // }
    }
    
    public func takePhoto(withFlash hasFlash: Bool) {
        let photoSettings = AVCapturePhotoSettings(format: [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)])
        //        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = hasFlash ? .on : .off
        print(hasFlash, "HAS FLASH")
        guard let connection = photoOutput.connection(with: .video) else { return }
        connection.isVideoMirrored = activeInput.device.position == .front
        
        self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    public func stopRecording() {
//
        
        if movieOutput.isRecording {
          //  audioRecorder.stopRecording()
            movieOutput.stopRecording()
            do {
               // try AVAudioSession.sharedInstance().setActive(false)
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
    
    @objc func pinch(_ pinch: UIPinchGestureRecognizer) {
            let device = activeInput.device

            // Return zoom value between the minimum and maximum zoom values
            func minMaxZoom(_ factor: CGFloat) -> CGFloat {
                return min(min(max(factor, minimumZoom), maximumZoom), device.activeFormat.videoMaxZoomFactor)
            }

            func update(scale factor: CGFloat) {
                do {
                    try device.lockForConfiguration()
                    defer { device.unlockForConfiguration() }
                    device.videoZoomFactor = factor
                } catch {
                    print("\(error.localizedDescription)")
                }
            }

            let newScaleFactor = minMaxZoom(pinch.scale * lastZoomFactor)

            switch pinch.state {
            case .began: fallthrough
            case .changed: update(scale: newScaleFactor)
            case .ended:
                lastZoomFactor = minMaxZoom(newScaleFactor)
                update(scale: lastZoomFactor)
            default: break
            }
        }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print(outputFileURL, "URL")
        if let error = error {
            print("error fileOutput: \(error.localizedDescription)")
        } else {
            let recording = AVURLAsset(url: outputFileURL)
            recordings.append(recording)
            
            if hasSwitchedCamera {
                switchCamera()
            } else {
               

                if recordings.count == 1 {
                    CameraViewModel.shared.videoUrl = outputFileURL
                } else {
                    mergeVideos { url in
                        CameraViewModel.shared.videoUrl = url
                    }
                }
                self.recordings = [AVURLAsset]()
            }
            
            hasSwitchedCamera = false
            
        }
    }
    
    func mergeVideos(handler: @escaping (_ url: URL)->()) {
        // 1 - Create AVMutableComposition object. This object
        // will hold your AVMutableCompositionTrack instances.
        let mixComposition = AVMutableComposition()
        let mainInstruction = AVMutableVideoCompositionInstruction()
        var lastTime: CMTime = .zero
        var instructions = [AVMutableVideoCompositionLayerInstruction]()
        
        for recording in recordings {
            guard
                let track = mixComposition.addMutableTrack(
                    withMediaType: .video,
                    preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            else { return }
            
            do {
                try track.insertTimeRange(
                    CMTimeRangeMake(start: .zero, duration: recording.duration),
                    of: recording.tracks(withMediaType: .video)[0],
                    at: lastTime)
            } catch {
                print("Failed to load first track")
                return
            }
            
            let instruction = VideoHelper.videoCompositionInstruction(
                track,
                asset: recording)
            
            lastTime = CMTimeAdd(lastTime, recording.duration)
            instruction.setOpacity(0.0, at: lastTime)
            instructions.append(instruction)
        }
        
        
        // 3 - Composition Instructions
        mainInstruction.timeRange = CMTimeRangeMake(
            start: .zero,
            duration: lastTime)
        
        
        // 5 - Add all instructions together and create a mutable video composition
        mainInstruction.layerInstructions = instructions
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mainComposition.renderSize = CGSize(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.width * 16/9)
        
        // 6 - Audio track
        //            if let loadedAudioAsset = audioAsset {
        //                let audioTrack = mixComposition.addMutableTrack(
        //                    withMediaType: .audio,
        //                    preferredTrackID: 0)
        //                do {
        //                    try audioTrack?.insertTimeRange(
        //                        CMTimeRangeMake(
        //                            start: CMTime.zero,
        //                            duration: CMTimeAdd(
        //                                firstAsset.duration,
        //                                secondAsset.duration)),
        //                        of: loadedAudioAsset.tracks(withMediaType: .audio)[0],
        //                        at: .zero)
        //                } catch {
        //                    print("Failed to load Audio track")
        //                }
        //            }
        
        // 7 - Get path
        guard
            let documentDirectory = FileManager.default.urls(
                for: .documentDirectory,
                   in: .userDomainMask).first
        else { return }
        
        let url = documentDirectory.appendingPathComponent("mergeVideo-\(UUID().uuidString).mov")
        
        // 8 - Create Exporter
        guard let exporter = AVAssetExportSession(
            asset: mixComposition,
            presetName: AVAssetExportPresetHighestQuality)
        else { return }
        exporter.outputURL = url
        exporter.outputFileType = AVFileType.mov
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = mainComposition
        
        // 9 - Perform the Export
        exporter.exportAsynchronously {
            DispatchQueue.main.async {
                handler(exporter.outputURL!)
            }
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        CameraViewModel.shared.isTakingPhoto = false
        if let imageData = photo.fileDataRepresentation() {
            if let uiImage = UIImage(data: imageData){
                CameraViewModel.shared.photo = uiImage
            }
        }
    }
}

