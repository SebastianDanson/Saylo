//
//  ImageUploader.swift
//  VidChat
//
//  Created by Student on 2021-09-24.
//

import UIKit
import Firebase
import AVFoundation
import AssetsLibrary
import Foundation
import QuartzCore

enum UploadType {
    case profile, video, photo, audio
    
    var filePath: StorageReference {
        let filename = NSUUID().uuidString
        
        switch self {
        case .audio:
            return Storage.storage().reference(withPath: "/audioRecordings/\(filename)")
        case .video:
            return Storage.storage().reference(withPath: "/videos/\(filename)")
        case .photo:
            return Storage.storage().reference(withPath: "/photos/\(filename)")
        case .profile:
            return Storage.storage().reference(withPath: "/profileImages/\(filename)")
        }
    }
}

class MediaUploader {
    
    static let shared = MediaUploader()
    
    func checkFileSize(sizeUrl: URL, message:String){
        let data = NSData(contentsOf: sizeUrl)!
        print(message, (Double(data.length) / 1048576.0), " mb")
    }
    
    static func uploadImage(image: UIImage, type: UploadType, completion: @escaping(String) -> Void) {
        
        var width = image.size.width
        var height = image.size.height
        if height > 700 || width > 700 {
            if width > height {
                let const = 700/width
                width *= const
                height *= const
            } else {
                let const = 700/height
                width *= const
                height *= const
            }
        }
        
        guard let imageData = shared.resizedImageWith(image: image, targetSize: CGSize(width: width, height: height))?.jpegData(compressionQuality: 0.5) else {return}
        
        let ref = type.filePath
        
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("DEBUG: Failed to upload image \(error.localizedDescription)")
                return
            }
            
            //TODO compress images
            ref.downloadURL { url, error in
                if let error = error {
                    print("DEBUG: Failed to download image URL \(error.localizedDescription)")
                    return
                }
                
                guard let imageUrl = url?.absoluteString else {return}
                completion(imageUrl)
            }
        }
    }
    
    func uploadAudio(url: URL, completion: @escaping(String) -> Void) {
        let ref = UploadType.audio.filePath

        ref.putFile(from: url, metadata: nil) { _, error in
            if let error = error {
                print("DEBUG: Failed to upload audio \(error.localizedDescription)")
                return
            }
            
            ref.downloadURL { url, error in
                if let error = error {
                    print("DEBUG: Failed to download audio URL \(error.localizedDescription)")
                    return
                }
                
                guard let audioUrl = url?.absoluteString else {return}
                completion(audioUrl)
            }
        }
    }
    
    func uploadVideo(url: URL, completion: @escaping(String) -> Void) {
        let ref = UploadType.video.filePath
        
        // Compress
        compressFile(url) { (compressedURL) in

           // remove activity indicator
           // do something with the compressedURL such as sending to Firebase or playing it in a player on the *main queue*
                //MediaUploader.shared.checkFileSize(sizeUrl: url, message: "BEFORE SIZE")
                //MediaUploader.shared.checkFileSize(sizeUrl: path, message: "AFTER SIZE")
                
                ref.putFile(from: compressedURL, metadata: nil) { _, error in
                    if let error = error {
                        print("DEBUG: Failed to upload video \(error.localizedDescription)")
                        return
                    }
                    
                    ref.downloadURL { url, error in
                        if let error = error {
                            print("DEBUG: Failed to download video URL \(error.localizedDescription)")
                            return
                        }
                        
                        guard let videoUrl = url?.absoluteString else {return}
                        completion(videoUrl)
                    }
                }
            }
//            errorHandler: { e in
//                print("Error: ", e)
//            },
//            cancelHandler: {
//                print("Canceled.")
//            }
       // )
        
        // To cancel compression, set cancel flag to true and wait for handler invoke
        //   cancelable.cancel = true
        
    }
    
    func compressFile(_ urlToCompress: URL, completion:@escaping (URL)->Void) {
        var assetWriter: AVAssetWriter!
        var assetReader: AVAssetReader?
        let bitrate: NSNumber = NSNumber(value: 1024 * 1024 * 4)
        var audioFinished = false
        var videoFinished = false
        checkFileSize(sizeUrl: urlToCompress, message: "BEFORE SIZE")
        
        let asset = AVAsset(url: urlToCompress)
        
        //create asset reader
        do {
            assetReader = try AVAssetReader(asset: asset)
        } catch {
            assetReader = nil
        }
        
        guard let reader = assetReader else {
            print("Could not iniitalize asset reader probably failed its try catch")
            // show user error message/alert
            return
        }
        
        guard let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first else { return }
        let videoReaderSettings: [String:Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB]
        
        let assetReaderVideoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
        
        var assetReaderAudioOutput: AVAssetReaderTrackOutput?
        if let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first {
            
            let audioReaderSettings: [String : Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2
            ]
            
            assetReaderAudioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: audioReaderSettings)
            
            if reader.canAdd(assetReaderAudioOutput!) {
                reader.add(assetReaderAudioOutput!)
            } else {
                print("Couldn't add audio output reader")
                // show user error message/alert
                return
            }
        }
        
        if reader.canAdd(assetReaderVideoOutput) {
            reader.add(assetReaderVideoOutput)
        } else {
            print("Couldn't add video output reader")
            // show user error message/alert
            return
        }
        
        let videoSettings:[String:Any] = [
            AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: bitrate],
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoHeightKey: videoTrack.naturalSize.height,
            AVVideoWidthKey: videoTrack.naturalSize.width,
            AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill
        ]
        
        let audioSettings: [String:Any] = [AVFormatIDKey : kAudioFormatMPEG4AAC,
                                           AVNumberOfChannelsKey : 2,
                                           AVSampleRateKey : 44100.0,
                                           AVEncoderBitRateKey: 128000
        ]
        
        let audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioSettings)
        let videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
        videoInput.transform = videoTrack.preferredTransform
        
        let videoInputQueue = DispatchQueue(label: "videoQueue")
        let audioInputQueue = DispatchQueue.global(qos: .userInteractive)
        
        do {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
            let date = Date()
            let tempDir = NSTemporaryDirectory()
            let outputPath = "\(tempDir)/\(formatter.string(from: date)).mp4"
            let outputURL = URL(fileURLWithPath: outputPath)
            
            assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mp4)
            
        } catch {
            assetWriter = nil
        }
        guard let writer = assetWriter else {
            print("assetWriter was nil")
            // show user error message/alert
            return
        }
        
        writer.shouldOptimizeForNetworkUse = true
        writer.add(videoInput)
        writer.add(audioInput)
        
        writer.startWriting()
        reader.startReading()
        writer.startSession(atSourceTime: CMTime.zero)
        
        let closeWriter:()->Void = {
            if (audioFinished && videoFinished) {
                assetWriter?.finishWriting(completionHandler: { [weak self] in
                    
                    if let assetWriter = assetWriter {
                        do {
                            let data = try Data(contentsOf: assetWriter.outputURL)
                            print("compressFile -file size after compression: \(Double(data.count / 1048576)) mb")
                        } catch let err as NSError {
                            print("compressFile Error: \(err.localizedDescription)")
                        }
                    }
                    
                  //  if let safeSelf = self, let assetWriter = safeSelf.assetWriter {
                    print("DONE COMPRESSING")
                        completion(assetWriter.outputURL)
                   // }
                })
                
                assetReader?.cancelReading()
            }
        }
        
        audioInput.requestMediaDataWhenReady(on: audioInputQueue) {

            while(audioInput.isReadyForMoreMediaData) {

                if let cmSampleBuffer = assetReaderAudioOutput?.copyNextSampleBuffer() {
                    
                    audioInput.append(cmSampleBuffer)
                    
                } else {
                    audioInput.markAsFinished()
                    DispatchQueue.main.async {
                        audioFinished = true
                        closeWriter()
                    }
                    break;
                }
            }
        }
        
        videoInput.requestMediaDataWhenReady(on: videoInputQueue) {
            // request data here

            while(videoInput.isReadyForMoreMediaData) {
                if let cmSampleBuffer = assetReaderVideoOutput.copyNextSampleBuffer() {
                    videoInput.append(cmSampleBuffer)
                    
                } else {
                    videoInput.markAsFinished()
                    DispatchQueue.main.async {
                        videoFinished = true
                        closeWriter()
                    }
                    break;
                }
            }
        }
    }
    
    func resizedImageWith(image: UIImage, targetSize: CGSize) -> UIImage? {
        
        let imageSize = image.size
        let newWidth  = targetSize.width  / image.size.width
        let newHeight = targetSize.height / image.size.height
        var newSize: CGSize
        
        if(newWidth > newHeight) {
            newSize = CGSize(width: imageSize.width * newHeight, height: imageSize.height * newHeight)
        } else {
            newSize = CGSize(width: imageSize.width * newWidth,  height: imageSize.height * newWidth)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        
        image.draw(in: rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

// Angle Conversion Utility
extension Int {
     var degreesToRadiansCGFloat: CGFloat { return CGFloat(Double(self) * Double.pi / 180) }
}

