//
//  Audio.swift
//  Saylo
//
//  Created by Student on 2021-10-21.
//

import AVFoundation

func configureAudioSession() {
  let session = AVAudioSession.sharedInstance()
  do {
      try session.setCategory(.playAndRecord, mode: .voiceChat, options: [.mixWithOthers, .defaultToSpeaker, .allowBluetooth, .allowAirPlay])
  } catch (let error) {
    print("Error while configuring audio session: \(error)")
  }
}

func startAudio() {
  print("Starting audio")
}

func stopAudio() {
  print("Stopping audio")
}
