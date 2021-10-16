//
//  AudioRecorder.swift
//  VidChat
//
//  Created by Student on 2021-10-14.
//

import Foundation

import Foundation
import SwiftUI
import AVFoundation
import Combine

class AudioRecorder: NSObject,ObservableObject {
    
    let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    
    var audioRecorder: AVAudioRecorder!
    
    var audioUrl: URL!
    
    var recording = false {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session")
        }
        
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        audioUrl = documentPath.appendingPathComponent(UUID().uuidString + ".m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            
            audioRecorder = try AVAudioRecorder(url: audioUrl, settings: settings)
            audioRecorder.record()

            recording = true
        } catch {
            print("Could not start recording")
        }
    }
    
    func stopRecording() {
        audioRecorder.stop()
        recording = false
        ConversationViewModel.shared.addMessage(url: audioUrl, text: nil, type: .Audio)
    }
}