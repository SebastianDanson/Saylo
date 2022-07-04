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

import MetalKit

class CameraViewController: UIViewController, AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: Properties
    
    private let session = AVCaptureMultiCamSession()
    
    private var isSessionRunning = false
    
    private let sessionQueue = DispatchQueue(label: "session queue") // Communicate with the session and other session objects on this queue.
    
    private let dataOutputQueue = DispatchQueue(label: "data output queue")
    
    private var setupResult: SessionSetupResult = .success
    
    @objc dynamic private(set) var backCameraDeviceInput: AVCaptureDeviceInput?
    
    private let backCameraVideoDataOutput = AVCaptureVideoDataOutput()
    
    private var backCameraVideoPreviewView = PreviewView()
    
    private weak var backCameraVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private var frontCameraDeviceInput: AVCaptureDeviceInput?
    
    private let frontCameraVideoDataOutput = AVCaptureVideoDataOutput()
    
    private var frontCameraVideoPreviewView = PreviewView()
    
    private weak var frontCameraVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private var microphoneDeviceInput: AVCaptureDeviceInput?
    
    private let backMicrophoneAudioDataOutput = AVCaptureAudioDataOutput()
    
    private let frontMicrophoneAudioDataOutput = AVCaptureAudioDataOutput()
    
    //Main Preview view constraints
    private var previewViewWidthAnchor: NSLayoutConstraint!
    private var previewViewHeightAnchor: NSLayoutConstraint!
    private var previewViewTrailingAnchor: NSLayoutConstraint!
    private var previewViewBottomAnchor: NSLayoutConstraint!
    
    //Zoom propertis
    private let minimumZoom: CGFloat = 1.0
    private let maximumZoom: CGFloat = 5.0
    private var lastZoomFactor: CGFloat = 1.0
    
    private var isMultiCamEnabled = false
    private var isBlurFilterEnabled = false {
        didSet {
            previewBlurView.setBlur(enabled: isBlurFilterEnabled)
        }
    }
    private let bottomPadding = CGFloat(TOP_PADDING + CAMERA_HEIGHT - SCREEN_HEIGHT)
    private var videoFilter: FilterRenderer?
    private var blurredBackgroundRenderer: BlurredBackgroundRenderer?
    private var previewView = PreviewMetalView()
    private var previewBlurView = PreviewMetalView()
    private let photoOutput = AVCapturePhotoOutput()
    private var statusBarOrientation: UIInterfaceOrientation = .portrait

    // MARK: View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // Set up the back and front video preview views.
        backCameraVideoPreviewView.videoPreviewLayer.setSessionWithNoConnection(session)
        frontCameraVideoPreviewView.videoPreviewLayer.setSessionWithNoConnection(session)
        
        // Store the back and front video preview layers so we can connect them to their inputs
        backCameraVideoPreviewLayer = backCameraVideoPreviewView.videoPreviewLayer
        frontCameraVideoPreviewLayer = frontCameraVideoPreviewView.videoPreviewLayer
        
        // Store the location of the pip's frame in relation to the full screen video preview
        //        updateNormalizedPiPFrame()
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        /*
         Configure the capture session.
         In general it is not safe to mutate an AVCaptureSession or any of its
         inputs, outputs, or connections from multiple threads at the same time.
         
         Don't do this on the main queue, because AVCaptureMultiCamSession.startRunning()
         is a blocking call, which can take a long time. Dispatch session setup
         to the sessionQueue so as not to block the main queue, which keeps the UI responsive.
         */
        sessionQueue.async {
            self.configureSession()
        }
        
        // Keep the screen awake
        UIApplication.shared.isIdleTimerDisabled = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let interfaceOrientation = UIApplication.shared.statusBarOrientation
        statusBarOrientation = interfaceOrientation
        
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                // Only setup observers and start the session running if setup succeeded.
                self.addObservers()
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
            default:
                print("Something went wrong")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
                self.removeObservers()
            }
        }
        
        super.viewWillDisappear(animated)
    }
    
    //MARK: UI
    
    private func setupUI() {
        
        view.backgroundColor = .black
        
        addBackCameraVideoPreviewView()
        setupMainPreviewView()
        
//        view.addSubview(previewView)
//        previewView.anchor(top: view.topAnchor, left: view.leftAnchor)
//        previewView.setDimensions(height: SCREEN_WIDTH * 16/9, width: SCREEN_WIDTH)
//
//        view.addSubview(previewBlurView)
//        previewBlurView.anchor(top: view.topAnchor, left: view.leftAnchor)
//        previewBlurView.setDimensions(height: SCREEN_WIDTH * 16/9, width: SCREEN_WIDTH)
        
        self.previewView.layer.cornerRadius = 14
        self.previewView.layer.masksToBounds = true
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action:#selector(pinch(_:)))
        self.view.addGestureRecognizer(pinchRecognizer)
        
    }
    
    private func setMainPreviewViewPiP() {
        
        let width = SCREEN_WIDTH/4
        let height = MESSAGE_HEIGHT/4 //iPhone camera is 16x9
        
        previewViewWidthAnchor.constant = width
        previewViewHeightAnchor.constant = height
        previewViewBottomAnchor.constant -= 20
        previewViewTrailingAnchor.constant = -20
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func setMainPreviewViewFull() {
        
        let width = SCREEN_WIDTH
        let height = MESSAGE_HEIGHT
        
        previewViewWidthAnchor.constant = width
        previewViewHeightAnchor.constant = height
        previewViewBottomAnchor.constant = bottomPadding
        previewViewTrailingAnchor.constant = 0
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupMainPreviewView() {
        
        view.addSubview(frontCameraVideoPreviewView)
        
        let width = SCREEN_WIDTH
        let height = MESSAGE_HEIGHT
        
        previewViewWidthAnchor = frontCameraVideoPreviewView.widthAnchor.constraint(equalToConstant: width)
        previewViewWidthAnchor.isActive = true
        
        previewViewHeightAnchor = frontCameraVideoPreviewView.heightAnchor.constraint(equalToConstant: height)
        previewViewHeightAnchor.isActive = true
        
        previewViewBottomAnchor = frontCameraVideoPreviewView.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                                                      constant: bottomPadding)
        previewViewBottomAnchor.isActive = true
        
        previewViewTrailingAnchor = frontCameraVideoPreviewView.rightAnchor.constraint(equalTo: view.rightAnchor,
                                                                                       constant: 0)
        previewViewTrailingAnchor.isActive = true
        
        frontCameraVideoPreviewView.translatesAutoresizingMaskIntoConstraints = false
        frontCameraVideoPreviewView.videoPreviewLayer.videoGravity = .resizeAspectFill
        frontCameraVideoPreviewView.layer.cornerRadius = 14
        frontCameraVideoPreviewView.backgroundColor = .blue
    }
    
    private func addBackCameraVideoPreviewView() {
        
        view.addSubview(backCameraVideoPreviewView)
        
        backCameraVideoPreviewView.setDimensions(height: MESSAGE_HEIGHT, width: SCREEN_WIDTH)
        backCameraVideoPreviewView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor)
        backCameraVideoPreviewView.videoPreviewLayer.videoGravity = .resizeAspectFill
        backCameraVideoPreviewView.layer.cornerRadius = 14
        backCameraVideoPreviewView.backgroundColor = .red
        
        view.sendSubviewToBack(backCameraVideoPreviewView)
    }
    
    func setVideoFilter(_ filter: Filter?) {
        
        dataOutputQueue.async {
            
            
            if let filter = filter {
                
                switch filter {
                case .blur:
                    self.videoFilter = nil
                    if self.blurredBackgroundRenderer == nil {
                        self.blurredBackgroundRenderer = BlurredBackgroundRenderer()
                    }
                case .positiveVibrance:
                    self.videoFilter = VibrantCIRenderer(isPositive: true)
                case .rosy:
                    self.videoFilter = RosyCIRenderer()
                case .negativeVibrance:
                    self.videoFilter = VibrantCIRenderer(isPositive: false)
                }
                
                self.isBlurFilterEnabled = filter == .blur
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.previewView.isHidden = filter == .blur
                    self.previewBlurView.isHidden = filter != .blur
                }
                
            } else {
                self.isBlurFilterEnabled = false
                self.videoFilter = nil
                
                if self.blurredBackgroundRenderer != nil {
                    self.blurredBackgroundRenderer = nil
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.previewView.isHidden = true
                }
            }
        }
    }
    
    @objc // Expose to Objective-C for use with #selector()
    private func didEnterBackground(notification: NSNotification) {
        // Free up resources.
        dataOutputQueue.async {
            self.renderingEnabled = false
            self.videoMixer.reset()
            self.currentPiPSampleBuffer = nil
        }
    }
    
    @objc // Expose to Objective-C for use with #selector()
    func willEnterForground(notification: NSNotification) {
        dataOutputQueue.async {
            self.renderingEnabled = true
        }
    }
    
    // MARK: KVO and Notifications
    
    private var sessionRunningContext = 0
    
    private var keyValueObservations = [NSKeyValueObservation]()
    
    private func addObservers() {
        
        let systemPressureStateObservation = observe(\.self.backCameraDeviceInput?.device.systemPressureState, options: .new) { _, change in
            guard let systemPressureState = change.newValue as? AVCaptureDevice.SystemPressureState else { return }
            self.setRecommendedFrameRateRangeForPressureState(systemPressureState)
        }
        keyValueObservations.append(systemPressureStateObservation)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: .AVCaptureSessionRuntimeError,
                                               object: session)
    }
    
    private func removeObservers() {
        for keyValueObservation in keyValueObservations {
            keyValueObservation.invalidate()
        }
        
        keyValueObservations.removeAll()
    }
    
    // MARK: Video Preview PiP Management
    
    private var pipDevicePosition: AVCaptureDevice.Position = .front
    
    private var normalizedPipFrame = CGRect(x: 0.7016908212560387, y: 0.7228260869565217, width: 0.25, height: 0.25)
    
    
    // MARK: Capture Session Management
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
        case multiCamNotSupported
    }
    
    
    // Must be called on the session queue
    private func configureSession() {
        guard setupResult == .success else { return }
        
        if !AVCaptureMultiCamSession.isMultiCamSupported {
            print("MultiCam not supported on this device")
            setupResult = .multiCamNotSupported
        }
        
        // When using AVCaptureMultiCamSession, it is best to manually add connections from AVCaptureInputs to AVCaptureOutputs
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
            if setupResult == .success {
                checkSystemCost()
            }
        }
        
        guard configureFrontCamera() else {
            setupResult = .configurationFailed
            return
        }
        
        guard configureMicrophone() else {
            setupResult = .configurationFailed
            return
        }
    }
    
    private func addBackCamera() {
        
        guard AVCaptureMultiCamSession.isMultiCamSupported else { return }
        
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
            if setupResult == .success {
                checkSystemCost()
            }
        }
        
        guard configureBackCamera() else {
            setupResult = .configurationFailed
            return
        }
        
        addBackCameraVideoPreviewView()
        setMainPreviewViewPiP()
    }
    
    private func removeBackCamera() {
        
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        
        
        guard let backCameraDeviceInput = backCameraDeviceInput else {
            print("Removing back camera failed")
            return
        }
        
        session.removeInput(backCameraDeviceInput)
        session.removeOutput(backCameraVideoDataOutput)
        
        backCameraVideoDataOutput.setSampleBufferDelegate(nil, queue: nil)
        
        backCameraVideoPreviewView.removeFromSuperview()
        setMainPreviewViewFull()
    }
    
    private func configureBackCamera() -> Bool {
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        
        // Find the back camera
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Could not find the back camera")
            return false
        }
        
        
        // Add the back camera input to the session
        do {
            backCameraDeviceInput = try AVCaptureDeviceInput(device: backCamera)
            
            guard let backCameraDeviceInput = backCameraDeviceInput,
                  session.canAddInput(backCameraDeviceInput) else {
                print("Could not add back camera device input")
                return false
            }
            session.addInputWithNoConnections(backCameraDeviceInput)
        } catch {
            print("Could not create back camera device input: \(error)")
            return false
        }
        
        // Find the back camera device input's video port
        guard let backCameraDeviceInput = backCameraDeviceInput,
              let backCameraVideoPort = backCameraDeviceInput.ports(for: .video,
                                                                    sourceDeviceType: backCamera.deviceType,
                                                                    sourceDevicePosition: backCamera.position).first else {
            print("Could not find the back camera device input's video port")
            return false
        }
        
        // Add the back camera video data output
        guard session.canAddOutput(backCameraVideoDataOutput) else {
            print("Could not add the back camera video data output")
            return false
        }
        session.addOutputWithNoConnections(backCameraVideoDataOutput)
        // Check if CVPixelFormat Lossy or Lossless Compression is supported
        
        if backCameraVideoDataOutput.availableVideoPixelFormatTypes.contains(kCVPixelFormatType_Lossy_32BGRA) {
            // Set the Lossy format
            print("Selecting lossy pixel format")
            backCameraVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_Lossy_32BGRA)]
        } else if backCameraVideoDataOutput.availableVideoPixelFormatTypes.contains(kCVPixelFormatType_Lossless_32BGRA) {
            // Set the Lossless format
            print("Selecting a lossless pixel format")
            backCameraVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_Lossless_32BGRA)]
        } else {
            // Set to the fallback format
            print("Selecting a 32BGRA pixel format")
            backCameraVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        }
        
        backCameraVideoDataOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        
        // Connect the back camera device input to the back camera video data output
        let backCameraVideoDataOutputConnection = AVCaptureConnection(inputPorts: [backCameraVideoPort], output: backCameraVideoDataOutput)
        guard session.canAddConnection(backCameraVideoDataOutputConnection) else {
            print("Could not add a connection to the back camera video data output")
            return false
        }
        
        session.addConnection(backCameraVideoDataOutputConnection)
        backCameraVideoDataOutputConnection.videoOrientation = .portrait
        
        // Connect the back camera device input to the back camera video preview layer
        guard let backCameraVideoPreviewLayer = backCameraVideoPreviewLayer else {
            return false
        }
        let backCameraVideoPreviewLayerConnection = AVCaptureConnection(inputPort: backCameraVideoPort, videoPreviewLayer: backCameraVideoPreviewLayer)
        guard session.canAddConnection(backCameraVideoPreviewLayerConnection) else {
            print("Could not add a connection to the back camera video preview layer")
            return false
        }
        session.addConnection(backCameraVideoPreviewLayerConnection)
        
        self.backCameraDeviceInput = backCameraDeviceInput
        
        return true
    }
    
    private func configureFrontCamera() -> Bool {
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        
        // Find the front camera
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Could not find the front camera")
            return false
        }
        
        // Add the front camera input to the session
        do {
            frontCameraDeviceInput = try AVCaptureDeviceInput(device: frontCamera)
            
            guard let frontCameraDeviceInput = frontCameraDeviceInput,
                  session.canAddInput(frontCameraDeviceInput) else {
                print("Could not add front camera device input")
                return false
            }
            session.addInputWithNoConnections(frontCameraDeviceInput)
        } catch {
            print("Could not create front camera device input: \(error)")
            return false
        }
        
        // Find the front camera device input's video port
        guard let frontCameraDeviceInput = frontCameraDeviceInput,
              let frontCameraVideoPort = frontCameraDeviceInput.ports(for: .video,
                                                                      sourceDeviceType: frontCamera.deviceType,
                                                                      sourceDevicePosition: frontCamera.position).first else {
            print("Could not find the front camera device input's video port")
            return false
        }
        
        // Add the front camera video data output
        guard session.canAddOutput(frontCameraVideoDataOutput) else {
            print("Could not add the front camera video data output")
            return false
        }
        session.addOutputWithNoConnections(frontCameraVideoDataOutput)
        // Check if CVPixelFormat Lossy or Lossless Compression is supported
        
        if frontCameraVideoDataOutput.availableVideoPixelFormatTypes.contains(kCVPixelFormatType_Lossy_32BGRA) {
            // Set the Lossy format
            frontCameraVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_Lossy_32BGRA)]
        } else if frontCameraVideoDataOutput.availableVideoPixelFormatTypes.contains(kCVPixelFormatType_Lossless_32BGRA) {
            // Set the Lossless format
            frontCameraVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_Lossless_32BGRA)]
        } else {
            // Set to the fallback format
            frontCameraVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        }
        
        frontCameraVideoDataOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        
        // Connect the front camera device input to the front camera video data output
        let frontCameraVideoDataOutputConnection = AVCaptureConnection(inputPorts: [frontCameraVideoPort], output: frontCameraVideoDataOutput)
        guard session.canAddConnection(frontCameraVideoDataOutputConnection) else {
            print("Could not add a connection to the front camera video data output")
            return false
        }
        session.addConnection(frontCameraVideoDataOutputConnection)
        frontCameraVideoDataOutputConnection.videoOrientation = .portrait
        frontCameraVideoDataOutputConnection.automaticallyAdjustsVideoMirroring = false
        frontCameraVideoDataOutputConnection.isVideoMirrored = true
        
        // Connect the front camera device input to the front camera video preview layer
        guard let frontCameraVideoPreviewLayer = frontCameraVideoPreviewLayer else {
            return false
        }
        let frontCameraVideoPreviewLayerConnection = AVCaptureConnection(inputPort: frontCameraVideoPort, videoPreviewLayer: frontCameraVideoPreviewLayer)
        guard session.canAddConnection(frontCameraVideoPreviewLayerConnection) else {
            print("Could not add a connection to the front camera video preview layer")
            return false
        }
        session.addConnection(frontCameraVideoPreviewLayerConnection)
        frontCameraVideoPreviewLayerConnection.automaticallyAdjustsVideoMirroring = false
        frontCameraVideoPreviewLayerConnection.isVideoMirrored = true
        
        return true
    }
    
    private func configureMicrophone() -> Bool {
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        
        // Find the microphone
        guard let microphone = AVCaptureDevice.default(for: .audio) else {
            print("Could not find the microphone")
            return false
        }
        
        // Add the microphone input to the session
        do {
            microphoneDeviceInput = try AVCaptureDeviceInput(device: microphone)
            
            guard let microphoneDeviceInput = microphoneDeviceInput,
                  session.canAddInput(microphoneDeviceInput) else {
                print("Could not add microphone device input")
                return false
            }
            session.addInputWithNoConnections(microphoneDeviceInput)
        } catch {
            print("Could not create microphone input: \(error)")
            return false
        }
        
        // Find the audio device input's back audio port
        guard let microphoneDeviceInput = microphoneDeviceInput,
              let backMicrophonePort = microphoneDeviceInput.ports(for: .audio,
                                                                   sourceDeviceType: microphone.deviceType,
                                                                   sourceDevicePosition: .back).first else {
            print("Could not find the back camera device input's audio port")
            return false
        }
        
        // Find the audio device input's front audio port
        guard let frontMicrophonePort = microphoneDeviceInput.ports(for: .audio,
                                                                    sourceDeviceType: microphone.deviceType,
                                                                    sourceDevicePosition: .front).first else {
            print("Could not find the front camera device input's audio port")
            return false
        }
        
        // Add the back microphone audio data output
        guard session.canAddOutput(backMicrophoneAudioDataOutput) else {
            print("Could not add the back microphone audio data output")
            return false
        }
        session.addOutputWithNoConnections(backMicrophoneAudioDataOutput)
        backMicrophoneAudioDataOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        
        // Add the front microphone audio data output
        guard session.canAddOutput(frontMicrophoneAudioDataOutput) else {
            print("Could not add the front microphone audio data output")
            return false
        }
        session.addOutputWithNoConnections(frontMicrophoneAudioDataOutput)
        frontMicrophoneAudioDataOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        
        // Connect the back microphone to the back audio data output
        let backMicrophoneAudioDataOutputConnection = AVCaptureConnection(inputPorts: [backMicrophonePort], output: backMicrophoneAudioDataOutput)
        guard session.canAddConnection(backMicrophoneAudioDataOutputConnection) else {
            print("Could not add a connection to the back microphone audio data output")
            return false
        }
        session.addConnection(backMicrophoneAudioDataOutputConnection)
        
        // Connect the front microphone to the back audio data output
        let frontMicrophoneAudioDataOutputConnection = AVCaptureConnection(inputPorts: [frontMicrophonePort], output: frontMicrophoneAudioDataOutput)
        guard session.canAddConnection(frontMicrophoneAudioDataOutputConnection) else {
            print("Could not add a connection to the front microphone audio data output")
            return false
        }
        
        session.addConnection(frontMicrophoneAudioDataOutputConnection)
        
        return true
    }
    
    @objc // Expose to Objective-C for use with #selector()
    private func sessionRuntimeError(notification: NSNotification) {
        guard let errorValue = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError else {
            return
        }
        
        let error = AVError(_nsError: errorValue)
        print("Capture session runtime error: \(error)")
        
        /*
         Automatically try to restart the session running if media services were
         reset and the last start running succeeded. Otherwise, enable the user
         to try to resume the session running.
         */
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                }
            }
        }
    }
    
    // MARK: Recording Movies
    
    private var movieRecorder: MovieRecorder?
    
    private var currentPiPSampleBuffer: CMSampleBuffer?
    
    private var backgroundRecordingID: UIBackgroundTaskIdentifier?
    
    private var renderingEnabled = true
    
    private var videoMixer = PiPVideoMixer()
    
    private var videoTrackSourceFormatDescription: CMFormatDescription?
    
    private func takePhoto(withFlash hasFlash: Bool) {
        
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
    
    func startMovieRecording() {
        
        ConversationViewModel.shared.setIsLive()
        
        if !ConversationViewModel.shared.didCancelRecording, let chat = ConversationViewModel.shared.chat {
            ConversationViewModel.shared.sendIsTalkingNotification(chat: chat)
        }
        
        MainViewModel.shared.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(MAX_VIDEO_LENGTH), repeats: false) { timer in
            MainViewModel.shared.stopRecording()
        }
        
        
        if UIDevice.current.isMultitaskingSupported {
            self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        }
        
        guard let audioSettings = self.createAudioSettings() else {
            print("Could not create audio settings")
            return
        }
        
        guard let videoSettings = self.createVideoSettings() else {
            print("Could not create video settings")
            return
        }
        
        guard let videoTransform = self.createVideoTransform() else {
            print("Could not create video transform")
            return
        }
        
        self.movieRecorder = MovieRecorder(audioSettings: audioSettings,
                                           videoSettings: videoSettings,
                                           videoTransform: videoTransform)
        
        self.movieRecorder?.startRecording()
        
    }
    
    
    
    func stopMovieRecording(sendVideo: Bool = true) {
        
        self.movieRecorder?.stopRecording { movieURL in
            if sendVideo {
                
                DispatchQueue.main.async {
                    
                    MainViewModel.shared.videoUrl = movieURL
                    //                    MainViewModel.shared.setVideoPlayer()
                    MainViewModel.shared.handleSend()
                    ConversationViewModel.shared.didCancelRecording = false
                    
                    if ConversationViewModel.shared.presentUsers.count > 1 {
                        ConversationViewModel.shared.setSendingLiveRecordingId(AuthViewModel.shared.getUserId())
                    }
                    
                    withAnimation {
                        MainViewModel.shared.showCaption = false
                        MainViewModel.shared.showFilters = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    MainViewModel.shared.videoUrl = nil
                }
            }
        }
        
        ConversationViewModel.shared.hideLiveView()
        
        ConversationViewModel.shared.leaveChannel()
        ConversationViewModel.shared.setIsNotLive()
        
        MainViewModel.shared.timer?.invalidate()
        
    }
    
    //    private func toggleMovieRecording(_ recordButton: UIButton) {
    //
    //        recordButton.isEnabled = false
    //
    //        dataOutputQueue.async {
    //
    //            let isRecording = self.movieRecorder?.isRecording ?? false
    //            if !isRecording {
    //                if UIDevice.current.isMultitaskingSupported {
    //                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
    //                }
    //
    //                guard let audioSettings = self.createAudioSettings() else {
    //                    print("Could not create audio settings")
    //                    return
    //                }
    //
    //                guard let videoSettings = self.createVideoSettings() else {
    //                    print("Could not create video settings")
    //                    return
    //                }
    //
    //                guard let videoTransform = self.createVideoTransform() else {
    //                    print("Could not create video transform")
    //                    return
    //                }
    //
    //                self.movieRecorder = MovieRecorder(audioSettings: audioSettings,
    //                                                   videoSettings: videoSettings,
    //                                                   videoTransform: videoTransform)
    //
    //                self.movieRecorder?.startRecording()
    //            } else {
    //                self.movieRecorder?.stopRecording { _ in }
    //            }
    //        }
    //    }
    
    func camera(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discovery = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        let devices = discovery.devices.filter {
            $0.position == position
        }
        return devices.first
    }
    
    func switchCamera() {
        
        self.isMultiCamEnabled.toggle()
        
        if self.isMultiCamEnabled {
            self.addBackCamera()
        } else {
            self.removeBackCamera()
        }
        
//        sessionQueue.async {
//            self.addBackCamera()
//        }
        
        return
        
        DispatchQueue.main.async {
                   
                   let position: AVCaptureDevice.Position = (self.frontCameraDeviceInput!.device.position == .back) ? .front : .back
                   
                   guard let device = self.camera(for: position) else {
                       return
                   }
                   
                   MainViewModel.shared.isFrontFacing.toggle()
                   
                   self.session.beginConfiguration()
                   self.session.removeInput(self.frontCameraDeviceInput!)
                   
                   self.session.inputs.forEach { input in
                       if let input = input as? AVCaptureDeviceInput {
                           self.session.removeInput(input)
                       }
                   }
                   
                   do {
                       
                       self.frontCameraDeviceInput = try AVCaptureDeviceInput(device: device)
                       
                   } catch {
                       print("error: \(error.localizedDescription)")
                       return
                   }
                   
            if self.session.canAddInput(self.frontCameraDeviceInput!) {
                self.session.addInputWithNoConnections(self.frontCameraDeviceInput!)
                   } else {
                       print("COULD NOT ADD INPUT")
                   }
//
//                   self.session.outputs.forEach { output in
//                       output.connections.forEach({
//                           $0.videoOrientation = .portrait
//                           if $0.isVideoMirroringSupported {
//                               $0.isVideoMirrored = MainViewModel.shared.isFrontFacing
//                           }
//                       })
//                   }
                   
                   self.session.commitConfiguration()
               }
        
        return
        
        
        sessionQueue.async {
            let currentVideoDevice = self.frontCameraDeviceInput!.device
            var preferredPosition = AVCaptureDevice.Position.unspecified
            switch currentVideoDevice.position {
            case .unspecified, .front:
                preferredPosition = .back
                
            case .back:
                preferredPosition = .front
            @unknown default:
                fatalError("Unknown video device position.")
            }
            
            guard let videoDevice = self.camera(for: currentVideoDevice.position) else { return }
                var videoInput: AVCaptureDeviceInput
                do {
                    videoInput = try AVCaptureDeviceInput(device: videoDevice)
                } catch {
                    print("Could not create video device input: \(error)")
                    self.dataOutputQueue.async {
                        self.renderingEnabled = true
                    }
                    return
                }
                self.session.beginConfiguration()
                
                // Remove the existing device input first, since using the front and back camera simultaneously is not supported.
                self.session.removeInput(self.frontCameraDeviceInput!)
                
                if self.session.canAddInput(videoInput) {
                    
                    self.session.addInputWithNoConnections(videoInput)
                    self.frontCameraDeviceInput = videoInput
                } else {
                    print("Could not add video device input to the session")
                    self.session.addInput(self.frontCameraDeviceInput!)
                }
                
//                if let unwrappedPhotoOutputConnection = self.photoOutput.connection(with: .video) {
//                    self.photoOutput.connection(with: .video)!.videoOrientation = unwrappedPhotoOutputConnection.videoOrientation
//                }
              
                
                self.session.commitConfiguration()
            
            
//            let videoPosition = self.frontCameraDeviceInput!.device.position
//
//            if let unwrappedVideoDataOutputConnection = self.frontCameraVideoDataOutput.connection(with: .video) {
//                let rotation = PreviewMetalView.Rotation(with: self.interfaceOrientation,
//                                                         videoOrientation: unwrappedVideoDataOutputConnection.videoOrientation,
//                                                         cameraPosition: videoPosition)
//
//                self.previewView.mirroring = (videoPosition == .front)
//                if let rotation = rotation {
//                    self.previewView.rotation = rotation
//                }
//            }
            
//            self.dataOutputQueue.async {
//                self.renderingEnabled = true
//            }
        }
        
        MainViewModel.shared.isFrontFacing.toggle()

    }
    
    
    @objc private func toggleIsMultiCamEnabled() {
        
        self.isMultiCamEnabled.toggle()
        
        if self.isMultiCamEnabled {
            self.addBackCamera()
        } else {
            self.removeBackCamera()
        }
    }
    
    private func createAudioSettings() -> [String: NSObject]? {
        guard let backMicrophoneAudioSettings = backMicrophoneAudioDataOutput.recommendedAudioSettingsForAssetWriter(writingTo: .mov) as? [String: NSObject] else {
            print("Could not get back microphone audio settings")
            return nil
        }
        guard let frontMicrophoneAudioSettings = frontMicrophoneAudioDataOutput.recommendedAudioSettingsForAssetWriter(writingTo: .mov) as? [String: NSObject] else {
            print("Could not get front microphone audio settings")
            return nil
        }
        
        if backMicrophoneAudioSettings == frontMicrophoneAudioSettings {
            // The front and back microphone audio settings are equal, so return either one
            return backMicrophoneAudioSettings
        } else {
            print("Front and back microphone audio settings are not equal. Check your AVCaptureAudioDataOutput configuration.")
            return nil
        }
    }
    
    private func createVideoSettings() -> [String: NSObject]? {
        
        var backCameraVideoSettings: [String:NSObject]?
        
        if isMultiCamEnabled {
            guard let backCameraVideoSettingsMultiCam = backCameraVideoDataOutput.recommendedVideoSettingsForAssetWriter(writingTo: .mov) as? [String: NSObject] else {
                print("Could not get back camera video settings")
                return nil
            }
            
            backCameraVideoSettings = backCameraVideoSettingsMultiCam
        }
        
        guard let frontCameraVideoSettings = frontCameraVideoDataOutput.recommendedVideoSettingsForAssetWriter(writingTo: .mov) as? [String: NSObject] else {
            print("Could not get front camera video settings")
            return nil
        }
        
        if isMultiCamEnabled {
            if let backCameraVideoSettings = backCameraVideoSettings, backCameraVideoSettings == frontCameraVideoSettings {
                // The front and back camera video settings are equal, so return either one
                return backCameraVideoSettings
            } else {
                print("Front and back camera video settings are not equal. Check your AVCaptureVideoDataOutput configuration.")
                return nil
            }
        }
        
        return frontCameraVideoSettings
        
    }
    
    private func createVideoTransform() -> CGAffineTransform? {
        
        guard let backCameraVideoConnection = backCameraVideoDataOutput.connection(with: .video) else {
            print("Could not find the back and front camera video connections")
            return CGAffineTransform.identity
        }
        
        let deviceOrientation = UIDevice.current.orientation
        let videoOrientation = AVCaptureVideoOrientation(deviceOrientation: deviceOrientation) ?? .portrait
        
        // Compute transforms from the back camera's video orientation to the device's orientation
        let backCameraTransform = backCameraVideoConnection.videoOrientationTransform(relativeTo: videoOrientation)
        
        return backCameraTransform
        
    }
    
    func canWrite() -> Bool {
        return MainViewModel.shared.isRecording
        //        && videoWriter != nil && videoWriter?.status == .writing
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if isBlurFilterEnabled, output as? AVCaptureVideoDataOutput != nil {
            blurSampleBuffer(sampleBuffer)
        } else if let videoDataOutput = output as? AVCaptureVideoDataOutput {
            print(":YESSI")
            processVideoSampleBuffer(sampleBuffer, fromOutput: videoDataOutput)
        } else if let audioDataOutput = output as? AVCaptureAudioDataOutput {
            processsAudioSampleBuffer(sampleBuffer, fromOutput: audioDataOutput)
        }
    }
    
    
    // MARK: - Perform Requests
    
    private func processVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer, fromOutput videoDataOutput: AVCaptureVideoDataOutput) {
        
        if videoTrackSourceFormatDescription == nil {
            videoTrackSourceFormatDescription = CMSampleBufferGetFormatDescription( sampleBuffer )
        }
        
        // Determine:
        // - which camera the sample buffer came from
        // - if the sample buffer is for the PiP
        var fullScreenSampleBuffer: CMSampleBuffer?
        var pipSampleBuffer: CMSampleBuffer?
        
        if !isMultiCamEnabled {
            fullScreenSampleBuffer = sampleBuffer
        } else if pipDevicePosition == .back && videoDataOutput == backCameraVideoDataOutput {
            pipSampleBuffer = sampleBuffer
        } else if pipDevicePosition == .back && videoDataOutput == frontCameraVideoDataOutput {
            fullScreenSampleBuffer = sampleBuffer
        } else if pipDevicePosition == .front && videoDataOutput == backCameraVideoDataOutput {
            fullScreenSampleBuffer = sampleBuffer
        } else if pipDevicePosition == .front && videoDataOutput == frontCameraVideoDataOutput {
            pipSampleBuffer = sampleBuffer
        }
        
        if let fullScreenSampleBuffer = fullScreenSampleBuffer {
            processFullScreenSampleBuffer(fullScreenSampleBuffer)
        }
        
        if let pipSampleBuffer = pipSampleBuffer {
            processPiPSampleBuffer(pipSampleBuffer)
        }
    }
    
    private func processFullScreenSampleBuffer(_ fullScreenSampleBuffer: CMSampleBuffer) {
        guard renderingEnabled else {
            return
        }
        
        guard let videoPixelBuffer = CMSampleBufferGetImageBuffer(fullScreenSampleBuffer),
              let formatDescription = CMSampleBufferGetFormatDescription(fullScreenSampleBuffer) else {
            return
        }
        
        var finalVideoPixelBuffer = videoPixelBuffer
        if let filter = videoFilter {
            if !filter.isPrepared {
                /*
                 outputRetainedBufferCountHint is the number of pixel buffers the renderer retains. This value informs the renderer
                 how to size its buffer pool and how many pixel buffers to preallocate. Allow 3 frames of latency to cover the dispatch_async call.
                 */
                filter.prepare(with: formatDescription, outputRetainedBufferCountHint: 3)
            }
            
            // Send the pixel buffer through the filter
            guard let filteredBuffer = filter.render(pixelBuffer: finalVideoPixelBuffer) else {
                print("Unable to filter video buffer")
                return
            }
            finalVideoPixelBuffer = filteredBuffer
            previewView.pixelBuffer = finalVideoPixelBuffer
        }
        
        
        
        
        if !isMultiCamEnabled && videoFilter == nil && !isBlurFilterEnabled{
            if let recorder = movieRecorder,
               recorder.isRecording {
                
                recorder.recordVideo(sampleBuffer: fullScreenSampleBuffer)
            }
            return
        }
        
        
        
        if videoFilter != nil {
            if let recorder = movieRecorder,
               recorder.isRecording {
                
                guard let formatDescription = CMSampleBufferGetFormatDescription(fullScreenSampleBuffer), let finalVideoSampleBuffer = createVideoSampleBufferWithPixelBuffer(finalVideoPixelBuffer,
                                                                                                                                                                              formatDescription: formatDescription,
                                                                                                                                                                              presentationTime: CMSampleBufferGetPresentationTimeStamp(fullScreenSampleBuffer)) else {
                    print("Error: Unable to create sample buffer from pixelbuffer")
                    return
                }
                
                recorder.recordVideo(sampleBuffer: finalVideoSampleBuffer)
            }
        }
        
        guard let fullScreenPixelBuffer = CMSampleBufferGetImageBuffer(fullScreenSampleBuffer),
              let formatDescription = CMSampleBufferGetFormatDescription(fullScreenSampleBuffer) else {
            return
        }
        
        guard let pipSampleBuffer = currentPiPSampleBuffer,
              let pipPixelBuffer = CMSampleBufferGetImageBuffer(pipSampleBuffer) else {
            return
        }
        
        //        if !videoMixer.isPrepared {
        //            videoMixer.prepare(with: formatDescription, outputRetainedBufferCountHint: 3)
        //        }
        //
        //        videoMixer.pipFrame = normalizedPipFrame
        
        // Mix the full screen pixel buffer with the pip pixel buffer
        // When the PIP is the back camera, the primaryPixelBuffer is the front camera
        //        guard let mixedPixelBuffer = videoMixer.mix(fullScreenPixelBuffer: fullScreenPixelBuffer,
        //                                                    pipPixelBuffer: pipPixelBuffer,
        //                                                    fullScreenPixelBufferIsFrontCamera: pipDevicePosition == .back) else {
        //            print("Unable to combine video")
        //            return
        //        }
        
        guard let outputFormatDescription = videoMixer.outputFormatDescription else { return }
        
        // If we're recording, append this buffer to the movie
        if let recorder = movieRecorder,
           recorder.isRecording {
            
            guard let finalVideoSampleBuffer = createVideoSampleBufferWithPixelBuffer(finalVideoPixelBuffer,
                                                                                      formatDescription: outputFormatDescription,
                                                                                      presentationTime: CMSampleBufferGetPresentationTimeStamp(fullScreenSampleBuffer)) else {
                print("Error: Unable to create sample buffer from pixelbuffer")
                return
            }
            
            recorder.recordVideo(sampleBuffer: finalVideoSampleBuffer)
        }
    }
    
    private func blurSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        dataOutputQueue.async {
            
            guard let pixelBuffer = sampleBuffer.imageBuffer, let ciImage = BlurHelper.processVideoFrame(pixelBuffer) else { return }
            self.previewBlurView.currentCIImage = ciImage
            
            guard let blurredBackgroundRenderer = self.blurredBackgroundRenderer else {
                return
            }
            
            if !blurredBackgroundRenderer.isPrepared {
                /*
                 outputRetainedBufferCountHint is the number of pixel buffers the renderer retains. This value informs the renderer
                 how to size its buffer pool and how many pixel buffers to preallocate. Allow 3 frames of latency to cover the dispatch_async call.
                 */
                guard let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else { return }
                blurredBackgroundRenderer.prepare(with: formatDescription, outputRetainedBufferCountHint: 3)
            }
            
            // Send the pixel buffer through the filter
            guard let blurredBuffer = blurredBackgroundRenderer.render(ciImage: ciImage) else {
                print("Unable to filter video buffer")
                return
            }
            
            if let recorder = self.movieRecorder,
               recorder.isRecording {
                guard let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer), let finalVideoSampleBuffer = self.createVideoSampleBufferWithPixelBuffer(blurredBuffer, formatDescription: formatDescription, presentationTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer)) else {
                    print("Error: Unable to create sample buffer from pixelbuffer")
                    return
                }
                
                
                recorder.recordVideo(sampleBuffer: finalVideoSampleBuffer)
            }
        }
    }
    
    private func processPiPSampleBuffer(_ pipSampleBuffer: CMSampleBuffer) {
        guard renderingEnabled else {
            return
        }
        
        currentPiPSampleBuffer = pipSampleBuffer
    }
    
    private func processsAudioSampleBuffer(_ sampleBuffer: CMSampleBuffer, fromOutput audioDataOutput: AVCaptureAudioDataOutput) {
        guard (pipDevicePosition == .back && audioDataOutput == backMicrophoneAudioDataOutput) ||
                (pipDevicePosition == .front && audioDataOutput == frontMicrophoneAudioDataOutput) else {
            // Ignoring audio sample buffer
            return
        }
        
        // If we're recording, append this buffer to the movie
        if let recorder = movieRecorder,
           recorder.isRecording {
            recorder.recordAudio(sampleBuffer: sampleBuffer)
        }
    }
    
    private func createVideoSampleBufferWithPixelBuffer(_ pixelBuffer: CVPixelBuffer, formatDescription: CMFormatDescription, presentationTime: CMTime) -> CMSampleBuffer? {
        var sampleBuffer: CMSampleBuffer?
        var timingInfo = CMSampleTimingInfo(duration: .invalid, presentationTimeStamp: presentationTime, decodeTimeStamp: .invalid)
        
        let err = CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                     imageBuffer: pixelBuffer,
                                                     dataReady: true,
                                                     makeDataReadyCallback: nil,
                                                     refcon: nil,
                                                     formatDescription: formatDescription,
                                                     sampleTiming: &timingInfo,
                                                     sampleBufferOut: &sampleBuffer)
        if sampleBuffer == nil {
            print("Error: Sample buffer creation failed (error code: \(err))")
        }
        
        return sampleBuffer
    }
    
    // MARK: - Session Cost Check
    
    struct ExceededCaptureSessionCosts: OptionSet {
        let rawValue: Int
        
        static let systemPressureCost = ExceededCaptureSessionCosts(rawValue: 1 << 0)
        static let hardwareCost = ExceededCaptureSessionCosts(rawValue: 1 << 1)
    }
    
    //TODO don't let multi cam option if it's not allowed on device
    func checkSystemCost() {
        var exceededSessionCosts: ExceededCaptureSessionCosts = []
        
        if session.systemPressureCost > 1.0 {
            exceededSessionCosts.insert(.systemPressureCost)
        }
        
        if session.hardwareCost > 1.0 {
            exceededSessionCosts.insert(.hardwareCost)
        }
        
        switch exceededSessionCosts {
            
        case .systemPressureCost:
            // Choice #1: Reduce front camera resolution
            if reduceResolutionForCamera(.front) {
                checkSystemCost()
            }
            
            // Choice 2: Reduce the number of video input ports
            else if reduceVideoInputPorts() {
                checkSystemCost()
            }
            
            // Choice #3: Reduce back camera resolution
            else if reduceResolutionForCamera(.back) {
                checkSystemCost()
            }
            
            // Choice #4: Reduce front camera frame rate
            else if reduceFrameRateForCamera(.front) {
                checkSystemCost()
            }
            
            // Choice #5: Reduce frame rate of back camera
            else if reduceFrameRateForCamera(.back) {
                checkSystemCost()
            } else {
                print("Unable to further reduce session cost.")
            }
            
        case .hardwareCost:
            // Choice #1: Reduce front camera resolution
            if reduceResolutionForCamera(.front) {
                checkSystemCost()
            }
            
            // Choice 2: Reduce back camera resolution
            else if reduceResolutionForCamera(.back) {
                checkSystemCost()
            }
            
            // Choice #3: Reduce front camera frame rate
            else if reduceFrameRateForCamera(.front) {
                checkSystemCost()
            }
            
            // Choice #4: Reduce back camera frame rate
            else if reduceFrameRateForCamera(.back) {
                checkSystemCost()
            } else {
                print("Unable to further reduce session cost.")
            }
            
        case [.systemPressureCost, .hardwareCost]:
            // Choice #1: Reduce front camera resolution
            if reduceResolutionForCamera(.front) {
                checkSystemCost()
            }
            
            // Choice #2: Reduce back camera resolution
            else if reduceResolutionForCamera(.back) {
                checkSystemCost()
            }
            
            // Choice #3: Reduce front camera frame rate
            else if reduceFrameRateForCamera(.front) {
                checkSystemCost()
            }
            
            // Choice #4: Reduce back camera frame rate
            else if reduceFrameRateForCamera(.back) {
                checkSystemCost()
            } else {
                print("Unable to further reduce session cost.")
            }
            
        default:
            break
        }
    }
    
    func reduceResolutionForCamera(_ position: AVCaptureDevice.Position) -> Bool {
        for connection in session.connections {
            for inputPort in connection.inputPorts {
                if inputPort.mediaType == .video && inputPort.sourceDevicePosition == position {
                    guard let videoDeviceInput: AVCaptureDeviceInput = inputPort.input as? AVCaptureDeviceInput else {
                        return false
                    }
                    
                    var dims: CMVideoDimensions
                    
                    var width: Int32
                    var height: Int32
                    var activeWidth: Int32
                    var activeHeight: Int32
                    
                    dims = CMVideoFormatDescriptionGetDimensions(videoDeviceInput.device.activeFormat.formatDescription)
                    activeWidth = dims.width
                    activeHeight = dims.height
                    
                    if ( activeHeight <= 480 ) && ( activeWidth <= 640 ) {
                        return false
                    }
                    
                    let formats = videoDeviceInput.device.formats
                    if let formatIndex = formats.firstIndex(of: videoDeviceInput.device.activeFormat) {
                        
                        for index in (0..<formatIndex).reversed() {
                            let format = videoDeviceInput.device.formats[index]
                            if format.isMultiCamSupported {
                                dims = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
                                width = dims.width
                                height = dims.height
                                
                                if width < activeWidth || height < activeHeight {
                                    do {
                                        try videoDeviceInput.device.lockForConfiguration()
                                        videoDeviceInput.device.activeFormat = format
                                        
                                        videoDeviceInput.device.unlockForConfiguration()
                                        
                                        print("reduced width = \(width), reduced height = \(height)")
                                        
                                        return true
                                    } catch {
                                        print("Could not lock device for configuration: \(error)")
                                        
                                        return false
                                    }
                                    
                                } else {
                                    continue
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return false
    }
    
    func reduceFrameRateForCamera(_ position: AVCaptureDevice.Position) -> Bool {
        for connection in session.connections {
            for inputPort in connection.inputPorts {
                
                if inputPort.mediaType == .video && inputPort.sourceDevicePosition == position {
                    guard let videoDeviceInput: AVCaptureDeviceInput = inputPort.input as? AVCaptureDeviceInput else {
                        return false
                    }
                    let activeMinFrameDuration = videoDeviceInput.device.activeVideoMinFrameDuration
                    var activeMaxFrameRate: Double = Double(activeMinFrameDuration.timescale) / Double(activeMinFrameDuration.value)
                    activeMaxFrameRate -= 10.0
                    
                    // Cap the device frame rate to this new max, never allowing it to go below 15 fps
                    if activeMaxFrameRate >= 15.0 {
                        do {
                            try videoDeviceInput.device.lockForConfiguration()
                            videoDeviceInput.videoMinFrameDurationOverride = CMTimeMake(value: 1, timescale: Int32(activeMaxFrameRate))
                            
                            videoDeviceInput.device.unlockForConfiguration()
                            
                            print("reduced fps = \(activeMaxFrameRate)")
                            
                            return true
                        } catch {
                            print("Could not lock device for configuration: \(error)")
                            return false
                        }
                    } else {
                        return false
                    }
                }
            }
        }
        
        return false
    }
    
    func reduceVideoInputPorts () -> Bool {
        var newConnection: AVCaptureConnection
        var result = false
        
        for connection in session.connections {
            for inputPort in connection.inputPorts where inputPort.sourceDeviceType == .builtInDualCamera {
                print("Changing input from dual to single camera")
                
                guard let videoDeviceInput: AVCaptureDeviceInput = inputPort.input as? AVCaptureDeviceInput,
                      let wideCameraPort: AVCaptureInput.Port = videoDeviceInput.ports(for: .video,
                                                                                       sourceDeviceType: .builtInWideAngleCamera,
                                                                                       sourceDevicePosition: videoDeviceInput.device.position).first else {
                    return false
                }
                
                if let previewLayer = connection.videoPreviewLayer {
                    newConnection = AVCaptureConnection(inputPort: wideCameraPort, videoPreviewLayer: previewLayer)
                } else if let savedOutput = connection.output {
                    newConnection = AVCaptureConnection(inputPorts: [wideCameraPort], output: savedOutput)
                } else {
                    continue
                }
                session.beginConfiguration()
                
                session.removeConnection(connection)
                
                if session.canAddConnection(newConnection) {
                    session.addConnection(newConnection)
                    
                    session.commitConfiguration()
                    result = true
                } else {
                    print("Could not add new connection to the session")
                    session.commitConfiguration()
                    return false
                }
            }
        }
        return result
    }
    
    private func setRecommendedFrameRateRangeForPressureState(_ systemPressureState: AVCaptureDevice.SystemPressureState) {
        // The frame rates used here are for demonstrative purposes only for this app.
        // Your frame rate throttling may be different depending on your app's camera configuration.
        let pressureLevel = systemPressureState.level
        if pressureLevel == .serious || pressureLevel == .critical {
            if self.movieRecorder == nil || self.movieRecorder?.isRecording == false {
                do {
                    try self.backCameraDeviceInput?.device.lockForConfiguration()
                    
                    print("WARNING: Reached elevated system pressure level: \(pressureLevel). Throttling frame rate.")
                    
                    self.backCameraDeviceInput?.device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 20 )
                    self.backCameraDeviceInput?.device.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: 15 )
                    
                    self.backCameraDeviceInput?.device.unlockForConfiguration()
                } catch {
                    print("Could not lock device for configuration: \(error)")
                }
            }
        } else if pressureLevel == .shutdown {
            print("Session stopped running due to system pressure level.")
        }
    }
    
    // MARK: Selectors
    
    @objc func pinch(_ pinch: UIPinchGestureRecognizer) {
        
        guard let device = frontCameraDeviceInput?.device else { return }
        
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
        
        if let imageData = photo.fileDataRepresentation() {
            
            var outputImage: UIImage?
            
            if var ciimage = CIImage(data: imageData) {
                
                ciimage = transformOutputImage(image: ciimage)
                
                if let filter = ConversationViewModel.shared.selectedFilter {
                    
                    if filter != .blur, let filteredImage = Filter.applyFilter(toImage: ciimage, filter: filter, sampleBuffer: nil) {
                        ciimage = filteredImage
                    }
                }
                
                MainViewModel.shared.ciImage = ciimage
                
                if let cgimage = CIContext().createCGImage(ciimage, from: ciimage.extent) {
                    outputImage = UIImage(cgImage: cgimage)
                }
            }
            
            
            MainViewModel.shared.photo = outputImage ?? UIImage(data: imageData)
            
        }
    }
    
    func transformOutputImage(image: CIImage) -> CIImage {
        
        if MainViewModel.shared.isFrontFacing {
            return image.oriented(.right).transformed(by: CGAffineTransform(scaleX: -1, y: 1).translatedBy(x: -image.extent.width/2, y: 0))
        }
        
        return image.oriented(.right)
    }
}


extension PreviewMetalView.Rotation {
    init?(with interfaceOrientation: UIInterfaceOrientation, videoOrientation: AVCaptureVideoOrientation, cameraPosition: AVCaptureDevice.Position) {
        /*
         Calculate the rotation between the videoOrientation and the interfaceOrientation.
         The direction of the rotation depends upon the camera position.
         */
        switch videoOrientation {
        case .portrait:
            switch interfaceOrientation {
            case .landscapeRight:
                if cameraPosition == .front {
                    self = .rotate90Degrees
                } else {
                    self = .rotate270Degrees
                }
                
            case .landscapeLeft:
                if cameraPosition == .front {
                    self = .rotate270Degrees
                } else {
                    self = .rotate90Degrees
                }
                
            case .portrait:
                self = .rotate0Degrees
                
            case .portraitUpsideDown:
                self = .rotate180Degrees
                
            default: return nil
            }
        case .portraitUpsideDown:
            switch interfaceOrientation {
            case .landscapeRight:
                if cameraPosition == .front {
                    self = .rotate270Degrees
                } else {
                    self = .rotate90Degrees
                }
                
            case .landscapeLeft:
                if cameraPosition == .front {
                    self = .rotate90Degrees
                } else {
                    self = .rotate270Degrees
                }
                
            case .portrait:
                self = .rotate180Degrees
                
            case .portraitUpsideDown:
                self = .rotate0Degrees
                
            default: return nil
            }
            
        case .landscapeRight:
            switch interfaceOrientation {
            case .landscapeRight:
                self = .rotate0Degrees
                
            case .landscapeLeft:
                self = .rotate180Degrees
                
            case .portrait:
                if cameraPosition == .front {
                    self = .rotate270Degrees
                } else {
                    self = .rotate90Degrees
                }
                
            case .portraitUpsideDown:
                if cameraPosition == .front {
                    self = .rotate90Degrees
                } else {
                    self = .rotate270Degrees
                }
                
            default: return nil
            }
            
        case .landscapeLeft:
            switch interfaceOrientation {
            case .landscapeLeft:
                self = .rotate0Degrees
                
            case .landscapeRight:
                self = .rotate180Degrees
                
            case .portrait:
                if cameraPosition == .front {
                    self = .rotate90Degrees
                } else {
                    self = .rotate270Degrees
                }
                
            case .portraitUpsideDown:
                if cameraPosition == .front {
                    self = .rotate270Degrees
                } else {
                    self = .rotate90Degrees
                }
                
            default: return nil
            }
        @unknown default:
            fatalError("Unknown orientation.")
        }
    }
}
