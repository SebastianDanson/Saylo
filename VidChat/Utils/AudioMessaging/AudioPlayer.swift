//
//  AudioPlayer.swift
//  VidChat
//
//  Created by Student on 2021-10-14.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    let objectWillChange = PassthroughSubject<AudioPlayer, Never>()
    
    var audio: URL!
    var hasFinished = true
    
    @Published var isPlaying = false {
        didSet {
            CameraViewModel.shared.isPlaying = isPlaying
            objectWillChange.send(self)
        }
    }
    
    var audioPlayer: AVAudioPlayer!
    
    func startPlayback (audio: URL) {
        
        let playbackSession = AVAudioSession.sharedInstance()
        
        do {
            try playbackSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playing over the device's speakers failed")
        }
        
        do {
            self.audio = audio
            audioPlayer = try AVAudioPlayer(contentsOf: audio)
            audioPlayer.delegate = self
            audioPlayer.play()
            hasFinished = false
            isPlaying = true
        } catch {
            print("Playback failed.")
        }
    }
    
    func stopPlayback() {
        audioPlayer.stop()
        hasFinished = false
        isPlaying = false
    }
    
    func pause() {
        audioPlayer.pause()
        isPlaying = false
    }
    
    func resume() {
        print(isPlaying, "RESUMED")
        if !hasFinished {
            audioPlayer.play()
        } else {
            startPlayback(audio: audio)
        }
        isPlaying = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("STOPPED")
            stopPlayback()
        }
    }
}
