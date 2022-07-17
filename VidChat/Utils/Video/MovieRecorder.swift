//
//  MovieRecorder.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-06-28.
//

import Foundation
import AVFoundation

class MovieRecorder {
    
    private var assetWriter: AVAssetWriter?
    
    private var assetWriterVideoInput: AVAssetWriterInput?
    
    private var assetWriterAudioInput: AVAssetWriterInput?
    
    private var videoTransform: CGAffineTransform
    
    private var videoSettings: [String: Any]

    private var audioSettings: [String: Any]

    private(set) var isRecording = false
    
    init(audioSettings: [String: Any], videoSettings: [String: Any], videoTransform: CGAffineTransform) {
        self.audioSettings = audioSettings
        self.videoSettings = videoSettings
        self.videoTransform = videoTransform
    }
    
    func startRecording() {
        // Create an asset writer that records to a temporary file
        let outputFileName = NSUUID().uuidString
        let outputFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(outputFileName).appendingPathExtension("MOV")
        guard let assetWriter = try? AVAssetWriter(url: outputFileURL, fileType: .mov) else {
            return
        }
        
        // Add an audio input
        let assetWriterAudioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
        assetWriterAudioInput.expectsMediaDataInRealTime = true
        assetWriter.add(assetWriterAudioInput)
        
        //set video quality settings
        var videoSettings = videoSettings
        videoSettings[AVVideoCodecKey] = AVVideoCodecType.h264
        videoSettings[AVVideoWidthKey] = 540
        videoSettings[AVVideoHeightKey] = 960
        videoSettings[AVVideoCompressionPropertiesKey] = [
            AVVideoAverageBitRateKey : 1024 * 1024 * 2,
        ]
        
        // Add a video input
        let assetWriterVideoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        assetWriterVideoInput.expectsMediaDataInRealTime = true
        assetWriterVideoInput.transform = videoTransform
        assetWriter.add(assetWriterVideoInput)
        
        self.assetWriter = assetWriter
        self.assetWriterAudioInput = assetWriterAudioInput
        self.assetWriterVideoInput = assetWriterVideoInput
        
        isRecording = true
    }
    
    func pushBuffer() -> Bool {
        return isRecording || ConversationViewModel.shared.getIsInVideoCall()
    }
    
    func stopRecording(completion: @escaping (URL) -> Void) {
        guard let assetWriter = assetWriter else {
            return
        }
        
        self.isRecording = false
        self.assetWriter = nil
        
        assetWriter.finishWriting {
            completion(assetWriter.outputURL)
        }
    }
    
    func recordVideo(sampleBuffer: CMSampleBuffer) {
        if ConversationViewModel.shared.getIsInVideoCall() {
            ConversationViewModel.shared.pushVideoCallSampleBuffer(sampleBuffer: sampleBuffer)
        }
        
        guard isRecording,
              let assetWriter = assetWriter else {
            return
        }
        
        if assetWriter.status == .unknown {
            assetWriter.startWriting()
            assetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
        }
        
         if assetWriter.status == .writing {
            
            
            if let input = assetWriterVideoInput,
               input.isReadyForMoreMediaData {
                input.append(sampleBuffer)
            }
        }
        
        ConversationViewModel.shared.pushLiveSampleBuffer(sampleBuffer: sampleBuffer)


    }
    
    
    func recordAudio(sampleBuffer: CMSampleBuffer) {

        guard isRecording,
            let assetWriter = assetWriter,
            assetWriter.status == .writing,
            let input = assetWriterAudioInput,
            input.isReadyForMoreMediaData else {
                return
        }
        
        input.append(sampleBuffer)
    }
}
