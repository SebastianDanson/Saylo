//
//  CameraViewController.swift
//  Saylo
//
//  Created by Student on 2021-09-27.
//
import UIKit
import AVFoundation
import Photos
import CoreImage.CIFilterBuiltins
import SwiftUI

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
    private var previewViewTopAnchor: NSLayoutConstraint!
    
    //Back Camera Preview view constraints
    private var backPreviewViewWidthAnchor: NSLayoutConstraint!
    private var backPreviewViewHeightAnchor: NSLayoutConstraint!
    private var backPreviewViewTrailingAnchor: NSLayoutConstraint!
    private var backPreviewViewTopAnchor: NSLayoutConstraint!
    
    private var isBlurFilterEnabled = false {
        didSet {
            previewBlurView.setBlur(enabled: isBlurFilterEnabled)
        }
    }
    private let bottomPadding = CGFloat(TOP_PADDING + CAMERA_HEIGHT - SCREEN_HEIGHT)
    private var videoFilter: FilterRenderer?
    private var previewView = PreviewMetalView()
    
    private var blurredBackgroundRenderer: BlurredBackgroundRenderer?
    
    //Zoom propertis
    private let minimumZoom: CGFloat = 1.0
    private let maximumZoom: CGFloat = 5.0
    private var lastZoomFactor: CGFloat = 1.0
    
    private var previewBlurView = PreviewMetalView()
    private let photoOutput = AVCapturePhotoOutput()
    
    // MARK: View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setNoramlizedPipFrame()
        
        // Disable UI. Enable the UI later, if and only if the session starts running.
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
        
        view.addSubview(previewView)
        previewView.anchor(top: view.topAnchor, left: view.leftAnchor)
        previewView.setDimensions(height: SCREEN_WIDTH * 16/9, width: SCREEN_WIDTH)
        
        view.addSubview(previewBlurView)
        previewBlurView.anchor(top: view.topAnchor, left: view.leftAnchor)
        previewBlurView.setDimensions(height: SCREEN_WIDTH * 16/9, width: SCREEN_WIDTH)
        
        self.previewView.layer.cornerRadius = 14
        self.previewView.layer.masksToBounds = true
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action:#selector(pinch(_:)))
        self.view.addGestureRecognizer(pinchRecognizer)
        
    }
    
    private func setMainPreviewViewPiP() {
        
        let width = SCREEN_WIDTH/4
        let height = MESSAGE_HEIGHT/4
        previewViewWidthAnchor.constant = width
        previewViewHeightAnchor.constant = height
        previewViewTopAnchor.constant += 20
        previewViewTrailingAnchor.constant = -20
        
//        UIView.animate(withDuration: 0.2) {
//            self.view.layoutIfNeeded()
//        }
    }
    
    private func setBackPreviewViewPiP() {
        
        let width = SCREEN_WIDTH/4
        let height = MESSAGE_HEIGHT/4
        backPreviewViewWidthAnchor.constant = width
        backPreviewViewHeightAnchor.constant = height
        backPreviewViewTopAnchor.constant += 20
        backPreviewViewTrailingAnchor.constant = -20
        
//        UIView.animate(withDuration: 0.2) {
//            self.view.layoutIfNeeded()
//        }
    }
    
    private func setMainPreviewViewFull() {
    
        previewViewWidthAnchor.constant = SCREEN_WIDTH
        previewViewHeightAnchor.constant = MESSAGE_HEIGHT
        previewViewTopAnchor.constant = 0
        previewViewTrailingAnchor.constant = 0
        
//        UIView.animate(withDuration: 0.2) {
//            self.view.layoutIfNeeded()
//        }
        
        view.sendSubviewToBack(frontCameraVideoPreviewView)
    }
    
    private func setBackPreviewViewFull() {
    
        backPreviewViewWidthAnchor.constant = SCREEN_WIDTH
        backPreviewViewHeightAnchor.constant = MESSAGE_HEIGHT
        backPreviewViewTopAnchor.constant = 0
        backPreviewViewTrailingAnchor.constant = 0
        
//        UIView.animate(withDuration: 0.2) {
//            self.view.layoutIfNeeded()
//        }
        
        view.sendSubviewToBack(backCameraVideoPreviewView)

    }
    
    private func setupMainPreviewView() {
        
        view.addSubview(frontCameraVideoPreviewView)
        
        let width = SCREEN_WIDTH
        let height = MESSAGE_HEIGHT
        
        previewViewWidthAnchor = frontCameraVideoPreviewView.widthAnchor.constraint(equalToConstant: width)
        previewViewWidthAnchor.isActive = true
        
        previewViewHeightAnchor = frontCameraVideoPreviewView.heightAnchor.constraint(equalToConstant: height)
        previewViewHeightAnchor.isActive = true
        
        previewViewTopAnchor = frontCameraVideoPreviewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        previewViewTopAnchor.isActive = true
        
        previewViewTrailingAnchor = frontCameraVideoPreviewView.rightAnchor.constraint(equalTo: view.rightAnchor)
        previewViewTrailingAnchor.isActive = true
        
        frontCameraVideoPreviewView.translatesAutoresizingMaskIntoConstraints = false
        frontCameraVideoPreviewView.videoPreviewLayer.videoGravity = .resizeAspectFill
        frontCameraVideoPreviewView.layer.cornerRadius = 14
    }
    
    private func addBackCameraVideoPreviewView() {
        
        view.addSubview(backCameraVideoPreviewView)
        
        let width = SCREEN_WIDTH
        let height = MESSAGE_HEIGHT
        
        backPreviewViewWidthAnchor = backCameraVideoPreviewView.widthAnchor.constraint(equalToConstant: width)
        backPreviewViewWidthAnchor.isActive = true
        
        backPreviewViewHeightAnchor = backCameraVideoPreviewView.heightAnchor.constraint(equalToConstant: height)
        backPreviewViewHeightAnchor.isActive = true
        
        backPreviewViewTopAnchor = backCameraVideoPreviewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        backPreviewViewTopAnchor.isActive = true
        
        backPreviewViewTrailingAnchor = backCameraVideoPreviewView.rightAnchor.constraint(equalTo: view.rightAnchor)
        backPreviewViewTrailingAnchor.isActive = true
        
        backCameraVideoPreviewView.translatesAutoresizingMaskIntoConstraints = false
        backCameraVideoPreviewView.videoPreviewLayer.videoGravity = .resizeAspectFill
        backCameraVideoPreviewView.layer.cornerRadius = 14
    
        view.sendSubviewToBack(backCameraVideoPreviewView)
    }
    
    private func togglePip() {
        
        DispatchQueue.main.async {
            
            
            if self.pipDevicePosition == .front {
                self.setBackPreviewViewPiP()
                self.setMainPreviewViewFull()
                self.pipDevicePosition = .back
            } else {
                self.setMainPreviewViewPiP()
                self.setBackPreviewViewFull()
                self.pipDevicePosition = .front
            }
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
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
        let keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in  }
        
        keyValueObservations.append(keyValueObservation)
        
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
    
    private func setNoramlizedPipFrame() {
        let padding: CGFloat = 20
        let pipRatio: CGFloat = 0.25
        let xPos: CGFloat = 1 - pipRatio - padding/SCREEN_WIDTH // (Screen width - pip width - padding left) / screen width
        let yPos: CGFloat = (TOP_PADDING + padding) / SCREEN_HEIGHT
        self.normalizedPipFrame = CGRect(x: xPos, y: yPos, width: pipRatio, height: pipRatio)
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
        
        sessionQueue.async {
            guard self.configureBackCamera() else {
                self.setupResult = .configurationFailed
                return
            }
        }
        
        DispatchQueue.main.async {
            self.addBackCameraVideoPreviewView()
            self.setMainPreviewViewPiP()
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
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
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: MainViewModel.shared.isFrontFacing ? .front : .back) else {
            print("Could not find the front camera")
            return false
        }
        
        self.session.inputs.forEach({self.session.removeInput($0)})
        self.session.outputs.forEach({self.session.removeOutput($0)})
        self.session.connections.forEach({self.session.removeConnection($0)})
        
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
        frontCameraVideoDataOutputConnection.isVideoMirrored = MainViewModel.shared.isFrontFacing
        
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
        frontCameraVideoPreviewLayerConnection.isVideoMirrored = MainViewModel.shared.isFrontFacing
        
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
    
    
    func startMovieRecording() {
        
        ConversationViewModel.shared.setIsLive()
        
        if !ConversationViewModel.shared.didCancelRecording, let chat = ConversationViewModel.shared.chat {
            ConversationViewModel.shared.sendIsTalkingNotification(chat: chat)
        }
        
        MainViewModel.shared.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(MAX_VIDEO_LENGTH), repeats: false) { timer in
            MainViewModel.shared.stopRecording()
        }
        
        
//        if UIDevice.current.isMultitaskingSupported {
//            self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
//        }
        
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
    
    
    public func toggleIsMultiCamEnabled() {
        withAnimation {
            MainViewModel.shared.isMultiCamEnabled.toggle()
        }
        
        if MainViewModel.shared.isMultiCamEnabled {
            if !MainViewModel.shared.isFrontFacing {
                self.switchCamera()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.addBackCamera()
                }
            } else {
                self.addBackCamera()
            }
            
        } else {
            self.removeBackCamera()
        }
    }
    
    public func switchCamera() {
        togglePip()
//        sessionQueue.async {
//            DispatchQueue.main.async {
//                MainViewModel.shared.isFrontFacing.toggle()
//                self.configureFrontCamera()
//            }
//        }
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
        
        if MainViewModel.shared.isMultiCamEnabled {
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
        
        if MainViewModel.shared.isMultiCamEnabled {
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
        
        if !MainViewModel.shared.isMultiCamEnabled {
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
        
        
        
        
        if !MainViewModel.shared.isMultiCamEnabled && videoFilter == nil && !isBlurFilterEnabled{
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
            
            return
        }
        
        guard let fullScreenPixelBuffer = CMSampleBufferGetImageBuffer(fullScreenSampleBuffer),
              let formatDescription = CMSampleBufferGetFormatDescription(fullScreenSampleBuffer) else {
            return
        }
        
        guard let pipSampleBuffer = currentPiPSampleBuffer,
              let pipPixelBuffer = CMSampleBufferGetImageBuffer(pipSampleBuffer) else {
            return
        }
        
        if !videoMixer.isPrepared {
            videoMixer.prepare(with: formatDescription, outputRetainedBufferCountHint: 3)
        }
        
        videoMixer.pipFrame = normalizedPipFrame
        
        //  Mix the full screen pixel buffer with the pip pixel buffer
        //  When the PIP is the back camera, the primaryPixelBuffer is the front camera
        guard let mixedPixelBuffer = videoMixer.mix(fullScreenPixelBuffer: fullScreenPixelBuffer,
                                                    pipPixelBuffer: pipPixelBuffer,
                                                    fullScreenPixelBufferIsFrontCamera: pipDevicePosition == .back) else {
            print("Unable to combine video")
            return
        }
        
        guard let outputFormatDescription = videoMixer.outputFormatDescription else { return }
        
        // If we're recording, append this buffer to the movie
        if let recorder = movieRecorder,
           recorder.isRecording {
            
            guard let finalVideoSampleBuffer = createVideoSampleBufferWithPixelBuffer(mixedPixelBuffer,
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
