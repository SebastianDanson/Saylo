//
//  AudioRecorder.swift
//  Saylo
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
    @Published var audioPlayer = AudioPlayer()
    @Published var isPlaying = false
    
    var audioUrl: URL!
    
    var timer: Timer?

    var recording = false {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    func getTempUrl() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        if directory != "" {
            let path = directory.appendingPathComponent("\(UUID().uuidString).m4a")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session")
        }
        
        audioUrl = getTempUrl()
        
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
        
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(MAX_VIDEO_LENGTH), repeats: false) { timer in
            self.stopRecording()
        }
    }
    
    func stopRecording() {
        timer?.invalidate()
        audioRecorder.stop()
        sendRecording()
        print("YESSIR")
    }
    
    func cancelRecording() {
        print("CANCELLED")
        audioRecorder.stop()
        timer?.invalidate()
    }
    
    func sendRecording() {
//        withAnimation(.easeInOut(duration: 0.2)) {
//        audioPlayer.startPlayback(audio: audioUrl)

        
        ConversationViewModel.shared.sendMessage(url: audioUrl, text: nil, type: .Audio)
//        }
    }
    
    func playRecording() {
        isPlaying = true
        audioPlayer.resume()
    }
    
    func pauseRecording() {
        audioPlayer.pause()
        isPlaying = false
    }
    
    func stopPlayback() {
        audioPlayer.stopPlayback(recording: recording)
    }
}
