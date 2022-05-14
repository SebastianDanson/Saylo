//
//  PhotoCamera.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-04-27.
//

import UIKit
import AVFoundation
import SwiftUI

struct PhotoCamera: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    @Binding var showImageCropper: Bool
    @Binding var showCamera: Bool

    @Environment(\.presentationMode) var mode
    
    func makeUIViewController(context: Context) -> CustomCameraController {
        let camera = CustomCameraController()
        camera.delegate = context.coordinator
        return camera
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIViewController(_ uiViewController: CustomCameraController, context: Context) {
        
    }
    
    class Coordinator: NSObject, CustomCameraControllerDelegate {
       
        func hideCamera() {
            withAnimation {
                self.parent.showCamera = false
            }
        }
        
        func imageTaken(image: UIImage) {
            self.parent.image = image
            self.parent.showImageCropper = true
            self.parent.mode.wrappedValue.dismiss()
        }
        
        let parent: PhotoCamera
        
        init(_ parent: PhotoCamera) {
            self.parent = parent
        }
    }
}

protocol CustomCameraControllerDelegate: AnyObject {
    func imageTaken(image: UIImage)
    func hideCamera()
}

class CustomCameraController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    // MARK: - Variables
    lazy private var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named:"x"), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    lazy private var takePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(handleTakePhoto), for: .touchUpInside)
        return button
    }()
    
    private let photoOutput = AVCapturePhotoOutput()
    weak var delegate: CustomCameraControllerDelegate?
        
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        openCamera()
    }
    
    
    // MARK: - Private Methods
    private func setupUI() {
        
        view.backgroundColor = .black
        view.addSubview(backButton)
        view.addSubview(takePhotoButton)
                        
        takePhotoButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 15, width: 60, height: 60)
        takePhotoButton.layer.cornerRadius = 30
        takePhotoButton.centerX(inView: view)
       
//        backButton.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: TOP_PADDING, paddingLeft: 15, width: 40, height: 40)
//        backButton.imageView?.contentMode = .scaleAspectFit
//        backButton.backgroundColor = .fadedBlack
//        backButton.layer.cornerRadius = 20
    }
    
    private func openCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // the user has already authorized to access the camera.
            self.setupCaptureSession()
            
        case .notDetermined: // the user has not yet asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted { // if user has granted to access the camera.
                    print("the user has granted to access the camera")
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                        self.setupUI()
                    }
                } else {
                    print("the user has not granted to access the camera")
                    self.handleDismiss()
                }
            }
            
        case .denied:
            print("the user has denied previously to access the camera.")
            self.handleDismiss()
            
        case .restricted:
            print("the user can't give camera access due to some restriction.")
            self.handleDismiss()
            
        default:
            print("something has wrong due to we can't access the camera.")
            self.handleDismiss()
        }
    }
    
    private func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        
        if let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            do {
                
                let input = try AVCaptureDeviceInput(device: captureDevice)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            } catch let error {
                print("Failed to set input device with error: \(error)")
            }
            
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            let cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            cameraLayer.frame = self.view.frame
            cameraLayer.videoGravity = .resizeAspect
            cameraLayer.cornerRadius = 8
            self.view.layer.addSublayer(cameraLayer)
            
            captureSession.startRunning()
        }
    }
    
    @objc private func handleDismiss() {
        DispatchQueue.main.async {
            self.delegate?.hideCamera()
        }
    }
    
    @objc private func handleTakePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            guard let connection = photoOutput.connection(with: .video) else { return }
            connection.isVideoMirrored = true
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else { return }
        
        delegate?.imageTaken(image: image)
//        let previewImage = UIImage(data: imageData)
//        
//        let photoPreviewContainer = PhotoPreviewView(frame: self.view.frame)
//        photoPreviewContainer.photoImageView.image = previewImage
//        self.view.addSubviews(photoPreviewContainer)
    }
}
