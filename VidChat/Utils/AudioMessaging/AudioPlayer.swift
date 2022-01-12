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
    
    var audioPlayer: AVPlayer!
    
    
    func startPlayback (audio: URL) {

        let playbackSession = AVAudioSession.sharedInstance()
        
        do {
            try playbackSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playing over the device's speakers failed")
        }
        
       // do {
            self.audio = audio
            let playerItem = AVPlayerItem(url: audio)

            audioPlayer = AVPlayer(playerItem: playerItem)
           // audioPlayer.delegate = self
            audioPlayer.play()
            hasFinished = false
            isPlaying = true
//        } catch let e {
//            print("Playback failed. \(e.localizedDescription)")
//        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: audioPlayer.currentItem)
    }
    
    func stopPlayback(recording: Bool) {
        
        if !recording {
            audioPlayer.seek(to: .zero)
            audioPlayer.pause()
        }
        

        if !ConversationViewModel.shared.chatId.isEmpty && !recording {
            ConversationViewModel.shared.index += 1
        }
        
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
            stopPlayback(recording: false)
        }
    }
    
    @objc
    func playerItemDidReachEnd(notification: Notification) {
        stopPlayback(recording: false)
    }
}
