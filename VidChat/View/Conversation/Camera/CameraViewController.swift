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
    
    var isFrontFacing = true
    
    var outputURL: URL!
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //        startSession()
    //    }
    
    
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
    
    func setupSession() {
        
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
                
                self.activeInput = videoInput
                
            } catch {
                print("Error setting device input: \(error)")
                return
            }
            
            
            let queue = DispatchQueue(label: "temp")
            let queue1 = DispatchQueue(label: "temp1")
            
            self.videoDataOutput.setSampleBufferDelegate(self, queue: queue)
            self.audioDataOutput.setSampleBufferDelegate(self, queue: queue1)
            
            if self.captureSession.canAddOutput(self.videoDataOutput) {
                self.captureSession.addOutput(self.videoDataOutput)
            }
            
            if self.captureSession.canAddOutput(self.photoOutput) {
                self.captureSession.addOutput(self.photoOutput)
            }
            
            self.captureSession.commitConfiguration()
            
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
        
        let position: AVCaptureDevice.Position = (activeInput.device.position == .back) ? .front : .back
        
        guard let device = camera(for: position) else {
            return
        }
        
        //        captureSession.stopRunning()
        
        isFrontFacing.toggle()
        
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
        
        
        //        self.previewLayer.isHidden = true
        //
        //
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
        //            self.previewLayer.isHidden = false
        //        }
    }
    
    func setupPreview() {
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: (SCREEN_WIDTH - CAMERA_WIDTH)/2, y: TOP_PADDING, width: CAMERA_WIDTH, height: CAMERA_WIDTH * 16/9)
        
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
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
        
        
//        sessionAtSourceTime = nil
        
        
        
        
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
                    AVVideoAverageBitRateKey : 1024 * 1024 * 3,
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
                print("audio input added")
            } else {
                print("no audio input added")
            }
            
            videoWriter.startWriting()
            
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    func canWrite() -> Bool {
        return CameraViewModel.shared.isRecording && videoWriter != nil && videoWriter?.status == .writing
    }
    
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let writable = canWrite()
        
        //           guard writable else {return}
        
        //        print(output, videoDataOutput, audioDataOutput)
        if writable, sessionAtSourceTime == nil {
            // start writing
            sessionAtSourceTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            videoWriter.startSession(atSourceTime: sessionAtSourceTime!)
            print("Writing")
        }
        
        if !CameraViewModel.shared.isShowingPhotoCamera, output == videoDataOutput {
            
            connection.videoOrientation = .portrait
            
            
            if connection.isVideoMirroringSupported, isFrontFacing {
                DispatchQueue.global().async {
                    connection.isVideoMirrored = self.isFrontFacing
                }
            }
        }
        
        //        print(videoDataOutput, output)
        
        if writable, output == videoDataOutput,
           (videoWriterInput.isReadyForMoreMediaData) {
            // write video buffer
            //
            videoWriterInput.append(sampleBuffer)
            //               print(connection, "VIDEO")
            
                           print("video buffering")
            
        } else if writable, output == audioDataOutput,
                  (audioWriterInput.isReadyForMoreMediaData) {
            // write audio buffer
            //               print(connection, "AUDIO")
            
            audioWriterInput?.append(sampleBuffer)
            
                           print("audio buffering")
        }
        
        
    }
    
    //TODO saved videos that you record in video playback I.e start recording vide and then make download button work when done
    
    func addAudio() {
        
        let isFirstLoad = CameraViewModel.shared.isFirstLoad
        
//        DispatchQueue.main.async {
            
            
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
                
                
                if self.audioCaptureSession.canAddOutput(self.audioDataOutput) {
                    self.audioCaptureSession.addOutput(self.audioDataOutput)
                }
                
                self.audioCaptureSession.commitConfiguration()
                self.audioCaptureSession.startRunning()
                
            } else {
                self.audioCaptureSession.startRunning()
            }
//        }
        
        CameraViewModel.shared.isFirstLoad = false
        
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
    
    public func stopRecording(showVideo: Bool = true) {
        
        videoWriterInput.markAsFinished()
        audioWriterInput.markAsFinished()
        
        audioCaptureSession.stopRunning()

        videoWriter.finishWriting {
            self.sessionAtSourceTime = nil
            DispatchQueue.main.async {
                if showVideo {
                    CameraViewModel.shared.videoUrl = self.outputURL
                    CameraViewModel.shared.setVideoPlayer()
                }
                //  try! AVAudioSession.sharedInstance().setActive(false)
                self.setUpWriter()
                self.addAudio()
                //  try! AVAudioSession.sharedInstance().setActive(true)
            }
        }
        
        
        
        
        
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

