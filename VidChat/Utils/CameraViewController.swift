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

    weak var delegate: CameraViewControllerDelegate?
  let captureSession = AVCaptureSession()
  var previewLayer: AVCaptureVideoPreviewLayer!
  var activeInput: AVCaptureDeviceInput!
  let movieOutput = AVCaptureMovieFileOutput()
    var videoUrl: URL?
    
  var tempURL: URL? {
    let directory = NSTemporaryDirectory() as NSString
    if directory != "" {
      let path = directory.appendingPathComponent("video.mov")
      return URL(fileURLWithPath: path)
    }
    return nil
  }

    
    override func viewDidLoad() {
    super.viewDidLoad()

    setupSession()
    setupPreview()
    startSession()
  }

  override func viewWillDisappear(_ animated: Bool) {
    stopSession()
  }

  func setupSession() {
    captureSession.beginConfiguration()
    guard let camera = AVCaptureDevice.default(for: .video) else {
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
    let position: AVCaptureDevice.Position = (activeInput.device.position == .back) ? .front : .back
    guard let device = camera(for: position) else {
        return
    }
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
  }

  func setupPreview() {
    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.frame = view.bounds
    previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    view.layer.addSublayer(previewLayer)
  }

  func startSession() {
    if !captureSession.isRunning {
      DispatchQueue.global(qos: .default).async { [weak self] in
        self?.captureSession.startRunning()
      }
    }
  }

  func stopSession() {
    if captureSession.isRunning {
      DispatchQueue.global(qos: .default).async() { [weak self] in
        self?.captureSession.stopRunning()
      }
    }
  }

  public func captureMovie() {
    guard let connection = movieOutput.connection(with: .video) else {
      return
    }
    if connection.isVideoStabilizationSupported {
      connection.preferredVideoStabilizationMode = .auto
    }
    let device = activeInput.device
    if device.isSmoothAutoFocusEnabled {
      do {
        try device.lockForConfiguration()
        device.isSmoothAutoFocusEnabled = true
        device.unlockForConfiguration()
      } catch {
        print("error: \(error)")
      }
    }
    guard let outUrl = tempURL else { return }
    movieOutput.startRecording(to: outUrl, recordingDelegate: self)
  }

  public func stopRecording() {
    if movieOutput.isRecording {
      movieOutput.stopRecording()
    }
  }
    
    func getVideoUrl() -> URL? {
        return videoUrl
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
  func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    if let error = error {
      print("error: \(error.localizedDescription)")
    } else {
        self.videoUrl = outputFileURL
        delegate?.setVideo(withUrl: outputFileURL)
    }
  }
}
