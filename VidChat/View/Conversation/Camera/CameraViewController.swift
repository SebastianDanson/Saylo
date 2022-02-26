//
//  CameraViewController.swift
//  Saylo
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
    
    var isFrontFacing = true
    var canRun = true
    var outputURL: URL!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupSession()
        self.captureSession.startRunning()
//        if !CameraViewModel.shared.getHasCameraAccess() {
//            showAlert(isCameraAlert: true)
//        }
//
//        if AuthViewModel.shared.isSignedIn {
//
//            if ConversationGridViewModel.shared.hasUnreadMessages {
////                setPreviewLayerSmallFrame()
//                view.backgroundColor = .clear
//            } else {
////                setPreviewLayerFullFrame()
//                view.backgroundColor = .black
//            }
//
//
//            if !CameraViewModel.shared.getHasMicAccess() {
//                showAlert(isCameraAlert: false)
//            }
//        }
//
//        if !canRun {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                if !self.captureSession.isRunning {
//                    self.captureSession.startRunning()
//                }
//            }
//        }
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        captureSession.stopRunning()
        audioCaptureSession.stopRunning()
    }
    
    
    func getTempUrl() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        if directory != "" {
            let path = directory.appendingPathComponent("\(UUID().uuidString).mov")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    
    func stopSession() {
        
        //        videoWriterInput.markAsFinished()
        //        audioWriterInput.markAsFinished()
        //
        //        videoWriter.finishWriting {}
        //
        //        captureSession.stopRunning()
        //        audioCaptureSession.stopRunning()
        
    }
    
    func startRunning() {
        
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    func setPreviewLayerFullFrame() {
        let width = CAMERA_WIDTH
        previewLayer.frame = CGRect(x: (SCREEN_WIDTH - width)/2, y: TOP_PADDING, width: width, height: width * 16/9)
        view.layoutIfNeeded()
    }
    
    func setPreviewLayerSmallFrame() {
        let width = CAMERA_SMALL_WIDTH
        previewLayer.frame = CGRect(x: 0, y: 0, width: width, height: width * 16/9)
        view.layoutIfNeeded()
    }
    
    func stopRunning() {
        captureSession.stopRunning()
    }
    
    func setupAudio() {
        
        guard CameraViewModel.shared.getHasMicAccess() else { return }
        
        DispatchQueue.main.async {
            
            guard let mic = AVCaptureDevice.default(for: .audio) else {
                return
            }
            
            self.audioCaptureSession.beginConfiguration()
            
            do {
                
                let audioInput = try AVCaptureDeviceInput(device: mic)
                
                if self.audioCaptureSession.canAddInput(audioInput) {
                    self.audioCaptureSession.addInput(audioInput)
                }
                
            } catch {
                
            }
            
            let queue1 = DispatchQueue(label: "temp1")
            self.audioDataOutput.setSampleBufferDelegate(self, queue: queue1)
            
            if self.audioCaptureSession.canAddOutput(self.audioDataOutput) {
                self.audioCaptureSession.addOutput(self.audioDataOutput)
            }
            
            self.audioCaptureSession.commitConfiguration()
            
        }
    }
    
    func setupSession(addAudio: Bool = true) {
        
        guard CameraViewModel.shared.getHasCameraAccess() else { return }

        DispatchQueue.main.async {
            
            self.setUpWriter()
            
            self.captureSession.beginConfiguration()
            
            
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                return
            }
            
            
            do {
                
                let videoInput = try AVCaptureDeviceInput(device: camera)
                
                if self.captureSession.canAddInput(videoInput) {
                    self.captureSession.addInput(videoInput)
                }
                
                if ConversationViewModel.shared.showCamera {
                    
                }
                
                self.activeInput = videoInput
                
            } catch {
                print("Error setting device input: \(error)")
                return
            }
            
            
            let queue = DispatchQueue(label: "temp")
            
            self.videoDataOutput.setSampleBufferDelegate(self, queue: queue)
            
            if self.captureSession.canAddOutput(self.videoDataOutput) {
                self.captureSession.addOutput(self.videoDataOutput)
            }
            
            if self.captureSession.canAddOutput(self.photoOutput) {
                self.captureSession.addOutput(self.photoOutput)
            }
            
            self.captureSession.commitConfiguration()
            
            
            //Only add audio if they're not taking profile picture
            
            if addAudio {
                self.setupAudio()
            }
//            }
        }
    }
    
    
    
    func camera(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discovery = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        let devices = discovery.devices.filter {
            $0.position == position
        }
        return devices.first
    }
    
    public func switchCamera() {
        
        DispatchQueue.main.async {
            
            let position: AVCaptureDevice.Position = (self.activeInput.device.position == .back) ? .front : .back
            
            guard let device = self.camera(for: position) else {
                return
            }
                        
            self.isFrontFacing.toggle()
            
            self.captureSession.beginConfiguration()
            
            self.captureSession.removeInput(self.activeInput)
            
            self.captureSession.inputs.forEach { input in
                if let input = input as? AVCaptureDeviceInput {
                    self.captureSession.removeInput(input)
                }
            }
            
            
            do {
                
                self.activeInput = try AVCaptureDeviceInput(device: device)
                
            } catch {
                print("error: \(error.localizedDescription)")
                return
            }
            
            if self.captureSession.canAddInput(self.activeInput) {
                self.captureSession.addInput(self.activeInput)
            } else {
                print("COULD NOT ADD INPUT")
            }
            
            self.captureSession.commitConfiguration()
        }
        
    }
    
    func setupPreview() {
        
        let width = CameraViewModel.shared.getCameraWidth()
        let x = ConversationGridViewModel.shared.hasUnreadMessages ? 0 : (SCREEN_WIDTH - width)/2
        let y = ConversationGridViewModel.shared.hasUnreadMessages ? 0 : TOP_PADDING - 12
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: x, y: y, width: width, height: width * 16/9)
        
        previewLayer.cornerRadius = 14
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.view.layer.masksToBounds = true
        self.view.layer.cornerRadius = 14
        view.layer.addSublayer(previewLayer)
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action:#selector(pinch(_:)))
        self.view.addGestureRecognizer(pinchRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action:#selector(pinch(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(pinchRecognizer)
    }
    
    func startSession() {
        
        
//        DispatchQueue.main.async {
            self.captureSession.startRunning()
//            self.canRun = false
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                self.captureSession.stopRunning()
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    self.canRun = true
//                }
//            }
//        }
        
    }
    
    
    public func captureMovie(withFlash hasFlash: Bool) {
        
        guard CameraViewModel.shared.getHasCameraAccess() && CameraViewModel.shared.getHasMicAccess() else {return}

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
        
        //        audioCaptureSession.beginConfiguration()
        //        audioCaptureSession.inputs.forEach({audioCaptureSession.rem})
        //
        
        DispatchQueue.main.async {
            self.audioCaptureSession.startRunning()
        }
        
        
        sessionAtSourceTime = nil
        
        
        CameraViewModel.shared.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(MAX_VIDEO_LENGTH), repeats: false) { timer in
            CameraViewModel.shared.stopRecording()
        }
        
        // Dispatch.main.async {
        
        //  }
        
        // audioRecorder.startRecording()
        //        movieOutput.startRecording(to: outUrl, recordingDelegate: self)
    }
    
    func setUpWriter() {
        
        do {
            
            let url = getTempUrl()!
            outputURL = url
            videoWriter = try AVAssetWriter(outputURL: url, fileType: AVFileType.mp4)
            
            // add audio input
            let audioSettings : [String : Any] = [
                AVFormatIDKey : kAudioFormatMPEG4AAC,
                AVSampleRateKey : 44100,
                AVEncoderBitRateKey : 64000,
                AVNumberOfChannelsKey: 1
            ]
            
            audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
            audioWriterInput.expectsMediaDataInRealTime = true
            
            if videoWriter.canAdd(audioWriterInput!) {
                videoWriter.add(audioWriterInput!)
            }
            
            // add video input
            videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: [
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
            }
            
            videoWriter.startWriting()
            
            
        } catch let error {
            print("ERROR OCCURED SETTING UP WRITER \(error.localizedDescription)")
        }
    }
    
    func canWrite() -> Bool {
        return CameraViewModel.shared.isRecording && videoWriter != nil && videoWriter?.status == .writing
    }
    
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let writable = canWrite()
        
        
        if writable, sessionAtSourceTime == nil {
            // start writing
            sessionAtSourceTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            videoWriter.startSession(atSourceTime: sessionAtSourceTime!)
        }
        
        if !CameraViewModel.shared.isShowingPhotoCamera, output == videoDataOutput {
            
            connection.videoOrientation = .portrait
            
            if connection.isVideoMirroringSupported, isFrontFacing {
                connection.isVideoMirrored = self.isFrontFacing
            }
        }
        
        
        if writable, output == videoDataOutput,
           (videoWriterInput.isReadyForMoreMediaData) {
            videoWriterInput.append(sampleBuffer)
        } else if writable, output == audioDataOutput,
                  (audioWriterInput.isReadyForMoreMediaData) {
            audioWriterInput.append(sampleBuffer)
        }
        
        
    }
    
    
    func addAudio() {
        
        //        let isFirstLoad = CameraViewModel.shared.isFirstLoad
        
        
        
        //            if isFirstLoad {
        
        
        
        //            } else {
        //                self.audioCaptureSession.startRunning()
        //            }
        
        //        CameraViewModel.shared.isFirstLoad = false
        
    }
    
    public func takePhoto(withFlash hasFlash: Bool) {
        let photoSettings = AVCapturePhotoSettings()
        let previewPixelType = photoSettings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: 160,
            kCVPixelBufferHeightKey as String: 160
        ]
        photoSettings.previewPhotoFormat = previewFormat
        photoSettings.flashMode = hasFlash ? .on : .off
        guard let connection = photoOutput.connection(with: .video) else { return }
        connection.isVideoMirrored = activeInput.device.position == .front
        
        self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func showAlert(isCameraAlert: Bool) {
        
        let title = "Enable \(isCameraAlert ? "Camera" : "Microphone") Access"
        let messsage = "You must enable \(isCameraAlert ? "camera" : "microphone") access to send Saylo's"

        let alert = UIAlertController(title: title, message: messsage, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
            withAnimation {
                CameraViewModel.shared.reset(hideCamera: true)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Enable", style: .default, handler: { _ in
            PhotosViewModel.shared.openSettings()
        }))
        
        
        present(alert, animated: true, completion: nil)
    }
    
    public func stopRecording(showVideo: Bool = true) {
        
        guard CameraViewModel.shared.getHasCameraAccess() && CameraViewModel.shared.getHasMicAccess() else {return}
        
        videoWriterInput.markAsFinished()
        audioWriterInput.markAsFinished()
        
        
        videoWriter.finishWriting {
            self.sessionAtSourceTime = nil
            DispatchQueue.main.async {
                
                if showVideo {
                    CameraViewModel.shared.videoUrl = self.outputURL
                    CameraViewModel.shared.setVideoPlayer()
                    CameraViewModel.shared.handleSend()
                } else {
                    CameraViewModel.shared.videoUrl = nil
                }
                //  try! AVAudioSession.sharedInstance().setActive(false)
                self.setUpWriter()
                //  try! AVAudioSession.sharedInstance().setActive(true)
            }
        }
        
        CameraViewModel.shared.timer?.invalidate()
        audioCaptureSession.stopRunning()
        
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

