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

class CameraViewController: UIViewController, AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private struct Recording {
        let asset: AVURLAsset
        let isFrontFacing:Bool
    }
    
    //TODO flash on photo
    
    //Zoom propertis
    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 5.0
    var lastZoomFactor: CGFloat = 1.0
    
    let videoDataOutput = AVCaptureVideoDataOutput()
    let audioDataOutput = AVCaptureAudioDataOutput()

    private var recordings = [AVURLAsset]()
    
    weak var delegate: CameraViewControllerDelegate?
    
    let captureSession = AVCaptureSession()
    let audioCaptureSession = AVCaptureSession()

    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
//    let movieOutput = AVCaptureMovieFileOutput()
//    let audioOutput = AVCaptureMovieFileOutput()

    let photoOutput = AVCapturePhotoOutput()
    var hasFlash = false
    var hasSwitchedCamera = false
    var isVideo: Bool!
    let audioRecorder = AudioRecorder()

    //    override func viewDidLoad() {
    //        super.viewDidLoad()
    //        setupSession()
    //        setupPreview()
    //    }
    
    var videoWriter: AVAssetWriter!
    var videoWriterInput: AVAssetWriterInput!
    var audioWriterInput: AVAssetWriterInput!
    var sessionAtSourceTime: CMTime!
    var audioSessionAtSourceTime: CMTime!

    var outputURL: URL!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         startSession()
    }
    
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

        setUpWriter()

        captureSession.beginConfiguration()
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            return
        }
        
        
        do {

            let videoInput = try AVCaptureDeviceInput(device: camera)
            
                if captureSession.canAddInput(videoInput) {
                    captureSession.addInput(videoInput)
                }
                
            activeInput = videoInput
        
        } catch {
            print("Error setting device input: \(error)")
            return
        }
        

        let queue = DispatchQueue(label: "temp")
        let queue1 = DispatchQueue(label: "temp1")
        
        videoDataOutput.setSampleBufferDelegate(self, queue: queue)
        audioDataOutput.setSampleBufferDelegate(self, queue: queue1)
        captureSession.addOutput(videoDataOutput)
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
//        if movieOutput.isRecording {
//            hasSwitchedCamera = true
//            stopRecording()
//            return
//        }
        
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
        
//        if hasFlash && movieOutput.isRecording {
//            do {
//                let device = activeInput.device
//                try device.lockForConfiguration()
//                if device.position == .back {
//                    try device.setTorchModeOn(level:1.0)
//                }
//                device.unlockForConfiguration()
//            } catch {
//
//            }
//        }
//
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
        
       // guard let outUrl = getTempUrl() else { return }
        
//        guard let connection = movieOutput.connection(with: .video) else { return }
//        connection.isVideoMirrored = activeInput.device.position == .front
        
       
        sessionAtSourceTime = nil
        

       

       // Dispatch.main.async {
       
      //  }
      
        
       // audioRecorder.startRecording()
//        movieOutput.startRecording(to: outUrl, recordingDelegate: self)
    }
    
    func setUpWriter() {

        do {
            let url = getTempUrl()!
            outputURL = url
            videoWriter = try AVAssetWriter(outputURL: url, fileType: AVFileType.mov)
            // add video input
            videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: [
                AVVideoCodecKey : AVVideoCodecType.h264,
                AVVideoWidthKey : 720,
                AVVideoHeightKey : 1280,
                AVVideoCompressionPropertiesKey : [
                    AVVideoAverageBitRateKey : 1024 * 1024 * 4,
                    ],
                ])

            videoWriterInput.expectsMediaDataInRealTime = true

            if videoWriter.canAdd(videoWriterInput) {
                videoWriter.add(videoWriterInput)
                print("video input added")
            } else {
                print("no input added")
            }
            
            let audioReaderSettings: [String : Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: 44100,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsBigEndianKey: 0,
                AVLinearPCMIsFloatKey: 0,
                AVNumberOfChannelsKey: 2,
                AVLinearPCMIsNonInterleaved: 0,
            ]
            
            // add audio input
            audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: nil)

            audioWriterInput.expectsMediaDataInRealTime = true

            if videoWriter.canAdd(audioWriterInput!) {
                videoWriter.add(audioWriterInput!)
                print("audio input added")
            }


            videoWriter.startWriting()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }

    func canWrite() -> Bool {
        return CameraViewModel.shared.isRecording && videoWriter != nil && videoWriter?.status == .writing
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let writable = canWrite()

        if writable,
            sessionAtSourceTime == nil {
            // start writing
            sessionAtSourceTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            videoWriter.startSession(atSourceTime: sessionAtSourceTime!)
            //print("Writing")
        }

//        if output == videoDataOutput {
//            connection.videoOrientation = .portrait
//
//            if connection.isVideoMirroringSupported {
//                connection.isVideoMirrored = true
//            }
//        }
//        if writable,
//            output == videoDataOutput,
//            (videoWriterInput.isReadyForMoreMediaData) {
//            print("VIDEO 2")
//            // write video buffer
//            videoWriterInput.append(sampleBuffer)
//            //print("video buffering")
//        } else if writable,
//            output == audioDataOutput,
//            (audioWriterInput.isReadyForMoreMediaData) {
//            print("AUDIO 2")
//
//            // write audio buffer
//            audioWriterInput?.append(sampleBuffer)
//            //print("audio buffering")
//        }
    }
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        let writable = canWrite()

        if writable,
            sessionAtSourceTime == nil {
            // start writing
            sessionAtSourceTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            videoWriter.startSession(atSourceTime: sessionAtSourceTime!)
            //print("Writing")
        }

        if output == videoDataOutput {
            connection.videoOrientation = .portrait

            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = true
            }
        }
        
        if writable,
            output == videoDataOutput,
            (videoWriterInput.isReadyForMoreMediaData) {
            print("VIDEO")
            // write video buffer
            videoWriterInput.append(sampleBuffer)
            //print("video buffering")
        } else if writable,
            output == audioDataOutput,
            (audioWriterInput.isReadyForMoreMediaData) {
            print("AUDIO")

            // write audio buffer
            audioWriterInput?.append(sampleBuffer)
            //print("audio buffering")
        }

    }
    
    func addAudio() {
        
        DispatchQueue.global(qos: .userInteractive).async {
           
            
        if CameraViewModel.shared.isFirstLoad {
        

            self.audioCaptureSession.beginConfiguration()
        
        guard let mic = AVCaptureDevice.default(for: .audio) else {
            return
        }
        
        do {
           

            let audioInput = try AVCaptureDeviceInput(device: mic)
            
            
            if self.audioCaptureSession.canAddInput(audioInput) {
                self.audioCaptureSession.addInput(audioInput)
            }
                        
        } catch {
            print("Error setting device input: \(error)")
            return
        }
        
     
            self.audioCaptureSession.addOutput(self.audioDataOutput)
            self.audioCaptureSession.commitConfiguration()
            self.audioCaptureSession.startRunning()

        } else {
            self.audioCaptureSession.startRunning()

        }
        }
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
        videoWriterInput.markAsFinished()
        audioWriterInput.markAsFinished()

        
          print("marked as finished")
          videoWriter.finishWriting {
              self.sessionAtSourceTime = nil
              DispatchQueue.main.async {
                  print(self.outputURL, "URL")
                  CameraViewModel.shared.videoUrl = self.outputURL
                //  try! AVAudioSession.sharedInstance().setActive(false)
              
                //  try! AVAudioSession.sharedInstance().setActive(true)
              }
              self.setUpWriter()
//              self.audioWriterInput
          }
        

        audioCaptureSession.stopRunning()
        
      
        
        //TODO everywhere u have try! replace with dop catch
        
        //  try! AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)

       // audioCaptureSession.stopRunning()
        
//        if movieOutput.isRecording {
//          //  audioRecorder.stopRecording()
//            movieOutput.stopRecording()
//            do {
//                let device = activeInput.device
//                try device.lockForConfiguration()
//                if device.position == .back {
//                    device.torchMode = .off
//                }
//                device.unlockForConfiguration()
//            } catch {
//
//            }
//        }
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
        
//        try! AVAudioSession.sharedInstance().setActive(false)
//        try! AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
//        try! AVAudioSession.sharedInstance().setActive(true)

        if let error = error {
            print("error fileOutput: \(error.localizedDescription)")
        } else {
            let recording = AVURLAsset(url: outputFileURL)
            recordings.append(recording)
            
            if hasSwitchedCamera {
                switchCamera()
            } else {
                print("YESSIR 1")
//                    self.mergeVideoWithAudio(videoUrl: outputFileURL, audioUrl: self.audioRecorder.audioUrl) { url in
//                        DispatchQueue.main.async {
//                            print("YESSIR 2")
//                            CameraViewModel.shared.videoUrl = url
//                        }
//                    } failure: { error in
//                        print("ERROR: \(error?.localizedDescription)")
//                    }
               

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

