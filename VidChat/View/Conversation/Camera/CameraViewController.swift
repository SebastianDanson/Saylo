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
            //captureMovie(withFlash: self.hasFlash)
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
            
            // write audio buffer
            audioWriterInput?.append(sampleBuffer)
            //print("audio buffering")
        }
        
    }
    
    //TODO saved videos that you record in video playback I.e start recording vide and then make download button work when done
    
    func addAudio() {
        
        let isFirstLoad = CameraViewModel.shared.isFirstLoad
        
        DispatchQueue.global(qos: .userInteractive).async {
            

            if isFirstLoad {
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
        CameraViewModel.shared.isFirstLoad = false
        
    }
    
    public func takePhoto(withFlash hasFlash: Bool) {
        let photoSettings = AVCapturePhotoSettings(format: [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)])
        photoSettings.flashMode = hasFlash ? .on : .off
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
                print(self.outputURL, "OUTPUTURL")
                CameraViewModel.shared.videoUrl = self.outputURL
                //  try! AVAudioSession.sharedInstance().setActive(false)
                self.setUpWriter()
                //  try! AVAudioSession.sharedInstance().setActive(true)
            }
            //              self.audioWriterInput
        }
        
        
        audioCaptureSession.stopRunning()
        
        
        
        //TODO everywhere u have try! replace with dop catch

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

