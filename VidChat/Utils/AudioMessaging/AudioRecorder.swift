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
    @Published var isPlaying = false {
        didSet {
            print(isPlaying, "ISPLAYING2")
        }
    }
    
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
        
        timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
            self.stopRecording()
        }
    }
    
    func stopRecording(startPlayback: Bool = true) {
        timer?.invalidate()
        audioRecorder.stop()
        recording = false
        
        ConversationViewModel.shared.audioProgress = 0.0
        ConversationViewModel.shared.showAudio = false
        
        if ConversationViewModel.shared.chatId.isEmpty {
            ConversationGridViewModel.shared.isSelectingChats = true
        }
        
        if startPlayback {
            audioPlayer.startPlayback(audio: audioUrl)
        }
        
        print("STOPPING RECORDING")
    }
    
    func sendRecording() {
        withAnimation(.easeInOut(duration: 0.2)) {
            ConversationViewModel.shared.sendMessage(url: audioUrl, text: nil, type: .Audio)
        }
    }
    
    func playRecording() {
        print("PLAYING")
        isPlaying = true
        audioPlayer.resume()
    }
    
    func pauseRecording() {
        print("PAUSED")
        audioPlayer.pause()
        isPlaying = false
    }
    
    func stopPlayback() {
        audioPlayer.stopPlayback(recording: recording)
    }
}
