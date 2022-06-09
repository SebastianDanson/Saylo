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
import CoreImage
import CoreImage.CIFilterBuiltins
import Vision

extension CIFilter {
    
    static func attributedTextImageGenerator(inputText: NSAttributedString, inputScaleFactor: NSNumber = 1) -> CIFilter? {
        guard let filter = CIFilter(name: "CIAttributedTextImageGenerator") else {
            return nil
        }
        filter.setDefaults()
        filter.setValue(inputText, forKey: "inputText")
        filter.setValue(inputScaleFactor, forKey: "inputScaleFactor")
        return filter
    }
    
}

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
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    var activeInput: AVCaptureDeviceInput!
    
    
    //    let movieOutput = AVCaptureMovieFileOutput()
    //    let audioOutput = AVCaptureMovieFileOutput()
    
    let photoOutput = AVCapturePhotoOutput()
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
    
    var canRun = true
    var outputURL: URL!
    var imageView = UIImageView()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.startRunning()
        //        self.setupSession()
        
        //        DispatchQueue.global().async {
        //            self.captureSession.startRunning()
        //        }
        
        //        if previewLayer == nil {
        //        }
        
        self.previewLayer?.session = captureSession
        
        
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //        setupPreview()
    
    
    //    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
        audioCaptureSession.stopRunning()
        self.previewLayer?.session = nil
    }
    
    func getTempUrl() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        if directory != "" {
            let path = directory.appendingPathComponent("\(UUID().uuidString).mov")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    
    func startRunning() {
        
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    
    func stopRunning() {
        captureSession.stopRunning()
    }
    
    func setupAudio() {
        
        guard MainViewModel.shared.getHasMicAccess() else {
            showAlert(isCameraAlert: false)
            return
        }
        
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
        
        guard MainViewModel.shared.getHasCameraAccess() else {
            showAlert(isCameraAlert: true)
            return
        }
        
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
                
                let connection = self.videoDataOutput.connection(with: AVMediaType.video)
                if let connection = connection, connection.isVideoOrientationSupported {
                    connection.videoOrientation = AVCaptureVideoOrientation.portrait
                    connection.isVideoMirrored = true
                }
                
            }
            
            if self.captureSession.canAddOutput(self.photoOutput) {
                self.captureSession.addOutput(self.photoOutput)
            }
            
            //            let connection = self.videoDataOutput.connection(with: AVMediaType.video)
            //            if let connection = connection, connection.isVideoOrientationSupported {
            //                connection.videoOrientation = AVCaptureVideoOrientation.portrait
            //            }
            
            
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
            
            MainViewModel.shared.isFrontFacing.toggle()
            
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
            
            self.captureSession.outputs.forEach { output in
                output.connections.forEach({
                    $0.videoOrientation = .portrait
                    if $0.isVideoMirroringSupported {
                        $0.isVideoMirrored = MainViewModel.shared.isFrontFacing
                    }
                })
            }
            
            self.captureSession.commitConfiguration()
        }
        
    }
    
    func setupPreview() {
        
        //        let width = MainViewModel.shared.getCameraWidth()
        //        let x = ConversationGridViewModel.shared.hasUnreadMessages ? 0 : (SCREEN_WIDTH - width)/2
        //        let y = ConversationGridViewModel.shared.hasUnreadMessages ? 0 : TOP_PADDING - 12
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            previewLayer!.frame = CGRect(x: (UIScreen.main.bounds.width - SCREEN_WIDTH) / 2, y: TOP_PADDING_OFFSET, width: SCREEN_WIDTH, height: MESSAGE_HEIGHT)
        } else {
            previewLayer!.frame = CGRect(x: 0, y: TOP_PADDING_OFFSET, width: SCREEN_WIDTH, height: MESSAGE_HEIGHT)
        }
        
        previewLayer!.cornerRadius = 14
        previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.addSubview(imageView)
        imageView.frame = previewLayer!.frame
        //        previewLayer!.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        //        self.imageView.contentMode = .top
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.layer.cornerRadius = 14
        self.imageView.clipsToBounds = true
        
        
        //        self.imageView.addSubview(coverView)
        //        coverView.anchor(bottom: imageView.bottomAnchor)
        //        coverView.centerX(inView: self.imageView)
        //        coverView.setDimensions(height: SCREEN_WIDTH * 16/9 - MESSAGE_HEIGHT, width: SCREEN_WIDTH)
        
        
        self.view.layer.masksToBounds = true
        self.view.layer.cornerRadius = 14
        view.layer.addSublayer(previewLayer!)
        
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
    
    
    public func captureMovie() {
        
        guard MainViewModel.shared.getHasCameraAccess() && MainViewModel.shared.getHasMicAccess(), let chat = ConversationViewModel.shared.chat else {return}
        
        ConversationViewModel.shared.setIsLive()
        
        if !ConversationViewModel.shared.didCancelRecording {
            ConversationViewModel.shared.sendIsTalkingNotification(chat: chat)
        }
        
        let device = activeInput.device
        
        do {
            
            try device.lockForConfiguration()
            
            if device.isSmoothAutoFocusEnabled {
                device.isSmoothAutoFocusEnabled = true
            }
            
            
            if MainViewModel.shared.hasFlash && device.position == .back {
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
        
        
        MainViewModel.shared.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(MAX_VIDEO_LENGTH), repeats: false) { timer in
            MainViewModel.shared.stopRecording()
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
            videoWriter.shouldOptimizeForNetworkUse = true
            
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
                AVVideoWidthKey : 540,
                AVVideoHeightKey : 960,
                AVVideoCompressionPropertiesKey : [
                    AVVideoAverageBitRateKey : 1024 * 1024 * 2,
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
        return MainViewModel.shared.isRecording && videoWriter != nil && videoWriter?.status == .writing
    }
    
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        
        //        DispatchQueue.global().async {
        let writable = self.canWrite()
        
        if writable, self.sessionAtSourceTime == nil {
            // start writing
            self.sessionAtSourceTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            self.videoWriter.startSession(atSourceTime: self.sessionAtSourceTime!)
        }
        
        //
        
        
        
        
        //            if let compositeImage = blend.outputImage {
        //                DispatchQueue.main.async {
        //                    self.imageView.image = UIImage(ciImage: blend.outputImage!)
        //                }
        //            }
        
        
        
        //        var filteredImage: UIImage?
        
        var pixelBuffer: CVPixelBuffer?
        if let filter = ConversationViewModel.shared.selectedFilter {
            
            if let pixelBuffer2 = CMSampleBufferGetImageBuffer(sampleBuffer) {
                let cameraImage = CIImage(cvPixelBuffer: pixelBuffer2)
                
                if let filteredImage = Filter.applyFilter(toImage: cameraImage, filter: filter, sampleBuffer: sampleBuffer) {
//                    previewLayer?.isHidden = true
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(ciImage: filteredImage)
                        self.previewLayer!.isHidden = true
                    }
                }
                //            let textImageGenerator = CIFilter.textImageGenerator()
                //            textImageGenerator.scaleFactor = 1
                //
                //
                //            let attributes: [NSAttributedString.Key: Any] = [
                //                .font: UIFont.systemFont(ofSize: 64, weight: .semibold),
                //                .foregroundColor: UIColor.white,
                //               ]
                //            textImageGenerator.text = "TESTER"
                //
                //            textImageGenerator.
                
                
                
                
                //            let attributedQuote = NSAttributedString(string: "General Kenobi", attributes: attributes)
                //
                //            textImageGenerator.setValue(attributedQuote, forKeyPath: "inputText")
                
                //             = textImageGenerator.outputImage
                //
                //            textImage = textImage!.transformed(by: CGAffineTransform(translationX: 200, y: 300))
                //
                //            let compose = CIFilter.sourceAtopCompositing()
                //            compose.inputImage = textImage
                //            compose.backgroundImage = cameraImage
                
                //            let ciimage = CIImage(data: image.TIFFRepresentation!)!
                //            let uiImage = UIImage(ciImage: cameraImage).addText("HELLO WORLD", atPoint: CGPoint(x: SCREEN_WIDTH/2, y: MESSAGE_HEIGHT/2))
                //            let newCiimage = textImage
                //        let comicEffect = CIFilter(name: "CIComicEffect")
                
                //        comicEffect!.setValue(cameraImage, forKey: kCIInputImageKey)
                //            let ciImage = comicEffect!.value(forKey: kCIOutputImageKey)
                //            if let newCiimage = newCiimage {
                //                let ciContext = CIContext(options: nil)
                //                ciContext.render(newCiimage, to: pixelBuffer2)
                //
                //            let targetSize = CGSize(width: SCREEN_WIDTH, height: MESSAGE_HEIGHT)
                //            let imageSize = newCiimage.extent.size
                //
                //            let widthFactor = targetSize.width / imageSize.width
                //            let heightFactor = targetSize.height / imageSize.height
                //            let scaleFactor = max(widthFactor, heightFactor)
                //
                //            // scale down, retaining the original's aspect ratio
                //            let scaledImage = newCiimage.transformed(by: CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
                //
                //            // crop the center to match the target size
                //            let croppedImage = scaledImage.cropped(to: scaledImage.extent)
                //
                //                DispatchQueue.main.async {
                ////                    let context = CIContext()
                ////                    let cropped = newCiimage.cropped(to: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: MESSAGE_HEIGHT))
                ////                    let final = context.createCGImage(cropped, from: cropped.extent)
                //                    self.imageView.image = UIImage(ciImage: croppedImage)
                //                }
                ////            }
                
                //            if let image = cameraImage.imageBlackAndWhite() {
                
                //            }
                //
                //
                //         filteredImage = UIImage(ciImage: comicEffect!.value(forKey: kCIOutputImageKey) as! CIImage)
                pixelBuffer = pixelBuffer2
                
            }
        } else {
            DispatchQueue.main.async {
                self.previewLayer!.isHidden = false
            }
//            previewLayer?.isHidden = false
        }
        
        //        DispatchQueue.main.async {
        //            self.imageView.image = filteredImage
        //        }
        
        if !MainViewModel.shared.isShowingPhotoCamera, output == self.videoDataOutput {
            
            connection.videoOrientation = .portrait
            if connection.isVideoMirroringSupported, MainViewModel.shared.isFrontFacing {
                connection.isVideoMirrored = MainViewModel.shared.isFrontFacing
            }
        }
        
        
        //once we have the video frame, we can push to agora sdk
        //         agoraKit?.pushExternalVideoFrame(videoFrame)
        
        //TODO ensure proper channel id for live stream
        //
        
        if writable, output == self.videoDataOutput,
           (self.videoWriterInput.isReadyForMoreMediaData) {
            
            if let buffer = pixelBuffer  {
                //                var newSampleBuffer: CMSampleBuffer? = nil
                var info = CMSampleTimingInfo()
                info.presentationTimeStamp = sampleBuffer.presentationTimeStamp
                info.duration = sampleBuffer.duration
                info.decodeTimeStamp = sampleBuffer.decodeTimeStamp
                //
                //                CMSampleBufferCreateReadyWithImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: buffer, formatDescription: sampleBuffer.formatDescription!, sampleTiming: &info, sampleBufferOut: &newSampleBuffer)
                //
                //                print("BUFFER", newSampleBuffer)
                
                
                //                    var info = CMSampleTimingInfo()
                //                    info.presentationTimeStamp = CMTime.zero
                //                    info.duration = CMTime.invalid
                //                    info.decodeTimeStamp = CMTime.invalid
                
                var formatDesc: CMFormatDescription?
                CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                             imageBuffer: buffer,
                                                             formatDescriptionOut: &formatDesc)
                
                var newSampleBuffer: CMSampleBuffer?
                
                CMSampleBufferCreateReadyWithImageBuffer(allocator: kCFAllocatorDefault,
                                                         imageBuffer: buffer,
                                                         formatDescription: formatDesc!,
                                                         sampleTiming: &info,
                                                         sampleBufferOut: &newSampleBuffer)
                if let newSampleBuffer = newSampleBuffer {
                    self.videoWriterInput.append(newSampleBuffer)
                    ConversationViewModel.shared.pushSampleBuffer(sampleBuffer: newSampleBuffer)
                }
            } else {
                self.videoWriterInput.append(sampleBuffer)
                ConversationViewModel.shared.pushSampleBuffer(sampleBuffer: sampleBuffer)
            }
            
            
            
            if ConversationViewModel.shared.presentUsers.count > 1, !ConversationViewModel.shared.isLive {
                DispatchQueue.main.async {
                    ConversationViewModel.shared.isLive = true
                }
            }
        } else if writable, output == self.audioDataOutput,
                  (self.audioWriterInput.isReadyForMoreMediaData) {
            self.audioWriterInput.append(sampleBuffer)
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
        connection.isVideoMirrored = MainViewModel.shared.isFrontFacing
        self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func showAlert(isCameraAlert: Bool) {
        
        let title = "Enable \(isCameraAlert ? "Camera" : "Microphone") Access"
        let messsage = "You must enable \(isCameraAlert ? "camera" : "microphone") access to send Saylo's"
        
        let alert = UIAlertController(title: title, message: messsage, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
            withAnimation {
                MainViewModel.shared.reset()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Enable", style: .default, handler: { _ in
            PhotosViewModel.shared.openSettings()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func addText() {
        
    }
    
    public func stopRecording(showVideo: Bool = true) {
        
        guard MainViewModel.shared.getHasCameraAccess() && MainViewModel.shared.getHasMicAccess() else {return}
        
        videoWriterInput.markAsFinished()
        audioWriterInput.markAsFinished()
        
        
        videoWriter.finishWriting {
            self.sessionAtSourceTime = nil
            DispatchQueue.main.async {
                
                if showVideo {
                    
                    
                    //                    let asset = AVAsset(url: self.outputURL)
                    //                    let titleComposition = AVMutableVideoComposition(asset: asset) { request in
                    //                    //Create a white shadow for the text
                    //                    let whiteShadow = NSShadow()
                    //                    whiteShadow.shadowBlurRadius = 5
                    //                    whiteShadow.shadowColor = UIColor.white
                    //                    let attributes = [
                    //                      NSAttributedString.Key.foregroundColor : UIColor.blue,
                    //                      NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
                    //                      NSAttributedString.Key.shadow : whiteShadow
                    //                    ]
                    //                    //Create an Attributed String
                    //                    let waterfallText = NSAttributedString(string: "Waterfall!", attributes: attributes)
                    //                    //Convert attributed string to a CIImage
                    //                    let textFilter = CIFilter.attributedTextImageGenerator(inputText: waterfallText)!
                    //
                    //                        //Center text and move 200 px from the origin
                    //                    //source image is 720 x 1280
                    //                    let positionedText = textFilter.outputImage!.transformed(by: CGAffineTransform(translationX: (request.renderSize.width - textFilter.outputImage!.extent.width)/2, y: 200))
                    //                    //Compose text over video image
                    //                    request.finish(with: positionedText.composited(over: request.sourceImage), context: nil)
                    //
                    //
                    //                    }
                    
                    //                    guard let export = AVAssetExportSession(
                    //                      asset: asset,
                    //                      presetName: AVAssetExportPresetHighestQuality)
                    //                      else {
                    //                        print("Cannot create export session.")
                    ////                        onComplete(nil)
                    //                        return
                    //                    }
                    //
                    //                    export.videoComposition = titleComposition
                    //                    export.outputFileType = .mov
                    //
                    //                    let urlNew = self.getTempUrl()!
                    //                    export.outputURL = urlNew
                    
                    //                    export.exportAsynchronously {
                    //                      DispatchQueue.main.async {
                    //                        switch export.status {
                    //                        case .completed:
                    MainViewModel.shared.videoUrl = self.outputURL
                    //                    MainViewModel.shared.setVideoPlayer()
                    MainViewModel.shared.handleSend()
                    ConversationViewModel.shared.didCancelRecording = false
                    
                    if ConversationViewModel.shared.presentUsers.count > 1 {
                        ConversationViewModel.shared.setSendingLiveRecordingId(AuthViewModel.shared.getUserId())
                    }
                    //                          onComplete(exportURL)
                    //                        default:
                    //                          print("Something went wrong during export.")
                    //                          print(export.error ?? "unknown error")
                    ////                          onComplete(nil)
                    //                          break
                    //                        }
                    //                      }
                    //                    }
                    
                    //                    let waterFallItem = AVPlayerItem(asset: asset)
                    //                    waterFallItem.videoComposition = titleComposition
                    //                    let player = AVPlayer(playerItem: waterFallItem)
                    //                    ConversationViewModel.shared.currentPlayer = player
                    //                    player.play()
                    //                    AVAssetExportSession(asset: player.currentItem!.asset, presetName: "test")?.exportAsynchronously {
                    
                    //                    }
                    
                    
                    
                } else {
                    MainViewModel.shared.videoUrl = nil
                }
                //  try! AVAudioSession.sharedInstance().setActive(false)
                self.setUpWriter()
                //  try! AVAudioSession.sharedInstance().setActive(true)
                ConversationViewModel.shared.hideLiveView()
            }
        }
        
        ConversationViewModel.shared.leaveChannel()
        ConversationViewModel.shared.setIsNotLive()
        //TODO when host ends broadcast leave channel on audiences devices
        
        MainViewModel.shared.timer?.invalidate()
        audioCaptureSession.stopRunning()
        
        let device = activeInput.device
        
        if device.torchMode == .on {
            do {
                try device.lockForConfiguration()
                device.torchMode = .off
                device.unlockForConfiguration()
                
            } catch {
                print("error captureMovie: \(error)")
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
    
    
    func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    
}



extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        //        MainViewModel.shared.isTakingPhoto = false
        if let imageData = photo.fileDataRepresentation() {
            if let uiImage = UIImage(data: imageData){
                MainViewModel.shared.photo = uiImage
            }
        }
    }
}


