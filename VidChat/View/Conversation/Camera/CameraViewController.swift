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
    
    //    override func viewDidLoad() {
    //        super.viewDidLoad()
    //        setupSession()
    //        setupPreview()
    //    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // startSession()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //TOOD stop session when chat is dismissed
        // stopSession()
        self.recordings = [AVURLAsset]()
        
    }
    
    func getTempUrl() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        if directory != "" {
            let path = directory.appendingPathComponent("video\(UUID().uuidString).mov")
            return URL(fileURLWithPath: path)
        }
        return nil
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
        captureSession.addOutput(photoOutput)
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
        movieOutput.startRecording(to: outUrl, recordingDelegate: self)
    }
    
    public func takePhoto() {
        let photoSettings = AVCapturePhotoSettings(format: [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)])
        //        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = self.hasFlash ? .on : .off
        self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
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
        if let imageData = photo.fileDataRepresentation() {
            if let uiImage = UIImage(data: imageData){
                CameraViewModel.shared.photo = uiImage
            }
        }
    }
}

