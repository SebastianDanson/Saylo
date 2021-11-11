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
        print("VIDEO")
        let ref = UploadType.video.filePath
        // Get source video
        let videoToCompress = url
        
        // Declare destination path and remove anything exists in it
        let destinationPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("compressed.mp4")
        try? FileManager.default.removeItem(at: destinationPath)
        
        // Compress
        let cancelable = compressh264VideoInBackground(
            videoToCompress: videoToCompress,
            destinationPath: destinationPath,
            size: nil, // nil preserves original,
            //size: CompressionSize(width: Int(UIScreen.main.bounds.width), height: Int(UIScreen.main.bounds.width * 1.2)),
            compressionTransform: .keepSame,
            compressionConfig: .defaultConfig,
            completionHandler: { [weak self] path in
                MediaUploader.shared.checkFileSize(sizeUrl: url, message: "BEFORE SIZE")
                MediaUploader.shared.checkFileSize(sizeUrl: path, message: "AFTER SIZE")
                
                ref.putFile(from: path, metadata: nil) { _, error in
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
            },
            errorHandler: { e in
                print("Error: ", e)
            },
            cancelHandler: {
                print("Canceled.")
            }
        )
        
        // To cancel compression, set cancel flag to true and wait for handler invoke
        //   cancelable.cancel = true
        
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

// Global Queue for All Compressions
fileprivate let compressQueue = DispatchQueue.global(qos: .userInteractive)

// Angle Conversion Utility
extension Int {
    fileprivate var degreesToRadiansCGFloat: CGFloat { return CGFloat(Double(self) * Double.pi / 180) }
}

// Compression Interruption Wrapper
class CancelableCompression {
    var cancel = false
}

// Compression Error Messages
struct CompressionError: LocalizedError {
    let title: String
    let code: Int
    
    init(title: String = "Compression Error", code: Int = -1) {
        self.title = title
        self.code = code
    }
}

// Compression Transformation Configuration
enum CompressionTransform {
    case keepSame
    case fixForBackCamera
    case fixForFrontCamera
}

// Compression Encode Parameters
struct CompressionConfig {
    let videoBitrate: Int
    let avVideoProfileLevel: String
    let audioSampleRate: Int
    let audioBitrate: Int
    
    static let defaultConfig = CompressionConfig(
        videoBitrate: Int(1024 * 1024 * 3),
        avVideoProfileLevel: AVVideoProfileLevelH264High41,
        audioSampleRate: 22050,
        audioBitrate: 80000
    )
}

// Video Size
typealias CompressionSize = (width: Int, height: Int)

// Compression Operation (just call this)
func compressh264VideoInBackground(videoToCompress: URL, destinationPath: URL, size: CompressionSize?, compressionTransform: CompressionTransform, compressionConfig: CompressionConfig, completionHandler: @escaping (URL)->(), errorHandler: @escaping (Error)->(), cancelHandler: @escaping ()->()) -> CancelableCompression {
    
    // Globals to store during compression
    class CompressionContext {
        var cgContext: CGContext?
        var pxbuffer: CVPixelBuffer?
        let colorSpace = CGColorSpaceCreateDeviceRGB()
    }
    
    // Draw Single Video Frame in Memory (will be used to loop for each video frame)
    func getCVPixelBuffer(_ i: CGImage?, compressionContext: CompressionContext) -> CVPixelBuffer? {
        // Allocate Temporary Pixel Buffer to Store Drawn Image
        weak var image = i!
        let imageWidth = image!.height
        let imageHeight = image!.width
        
        let attributes : [AnyHashable: Any] = [
            kCVPixelBufferCGImageCompatibilityKey : true as AnyObject,
            kCVPixelBufferCGBitmapContextCompatibilityKey : true as AnyObject
        ]
        
        if compressionContext.pxbuffer == nil {
            CVPixelBufferCreate(kCFAllocatorSystemDefault,
                                imageWidth,
                                imageHeight,
                                kCVPixelFormatType_32ARGB,
                                attributes as CFDictionary?,
                                &compressionContext.pxbuffer)
        }
        
        // Draw Frame to Newly Allocated Buffer
        if let _pxbuffer = compressionContext.pxbuffer {
            let flags = CVPixelBufferLockFlags(rawValue: 0)
            CVPixelBufferLockBaseAddress(_pxbuffer, flags)
            let pxdata = CVPixelBufferGetBaseAddress(_pxbuffer)
                        
            if compressionContext.cgContext == nil {
                compressionContext.cgContext = CGContext(data: pxdata,
                                                         width: imageWidth,
                                                         height: imageHeight,
                                                         bitsPerComponent: 8,
                                                         bytesPerRow: CVPixelBufferGetBytesPerRow(_pxbuffer),
                                                         space: compressionContext.colorSpace,
                                                         bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
            }
            
            if let _context = compressionContext.cgContext, let image = image {
                _context.draw(image, in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
            }
            else {
                CVPixelBufferUnlockBaseAddress(_pxbuffer, flags);
                return nil
            }
            
            CVPixelBufferUnlockBaseAddress(_pxbuffer, flags);
            return _pxbuffer;
        }
        
        return nil
    }
    
    // Asset, Output File
    let avAsset = AVURLAsset(url: videoToCompress)
    let filePath = destinationPath
    
    do {
        // Reader and Writer
        let writer = try AVAssetWriter(outputURL: filePath, fileType: AVFileType.mp4)
        let reader = try AVAssetReader(asset: avAsset)
        
        // Tracks
        let videoTrack = avAsset.tracks(withMediaType: AVMediaType.video).first!
        let audioTrack = avAsset.tracks(withMediaType: AVMediaType.audio).first!
        
        // Video Output Configuration
        let videoCompressionProps: Dictionary<String, Any> = [
            AVVideoAverageBitRateKey : compressionConfig.videoBitrate,
            AVVideoProfileLevelKey : compressionConfig.avVideoProfileLevel
        ]
        
        
        let videoOutputSettings: Dictionary<String, Any> = [
            AVVideoWidthKey : size == nil ? videoTrack.naturalSize.height : size!.width,
            AVVideoHeightKey : size == nil ? videoTrack.naturalSize.width : size!.height,
            AVVideoCodecKey : AVVideoCodecType.h264,
            AVVideoCompressionPropertiesKey : videoCompressionProps
        ]
        let videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoOutputSettings)
        videoInput.expectsMediaDataInRealTime = false
        
        let sourcePixelBufferAttributesDictionary: Dictionary<String, Any> = [
            String(kCVPixelBufferPixelFormatTypeKey) : Int(kCVPixelFormatType_32RGBA),
            String(kCVPixelFormatOpenGLESCompatibility) : kCFBooleanTrue ?? false
        ]
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoInput, sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
        
        videoInput.performsMultiPassEncodingIfSupported = true
        guard writer.canAdd(videoInput) else {
            errorHandler(CompressionError(title: "Cannot add video input"))
            return CancelableCompression()
        }
        writer.add(videoInput)
        
        // Audio Output Configuration
        var acl = AudioChannelLayout()
        acl.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo
        acl.mChannelBitmap = AudioChannelBitmap(rawValue: UInt32(0))
        acl.mNumberChannelDescriptions = UInt32(0)
        
        let acll = MemoryLayout<AudioChannelLayout>.size
        let audioOutputSettings: Dictionary<String, Any> = [
            AVFormatIDKey : UInt(kAudioFormatMPEG4AAC),
            AVNumberOfChannelsKey : UInt(2),
            AVSampleRateKey : compressionConfig.audioSampleRate,
            AVEncoderBitRateKey : compressionConfig.audioBitrate,
            AVChannelLayoutKey : NSData(bytes:&acl, length: acll)
        ]
        let audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioOutputSettings)
        audioInput.expectsMediaDataInRealTime = false
        
        guard writer.canAdd(audioInput) else {
            errorHandler(CompressionError(title: "Cannot add audio input"))
            return CancelableCompression()
        }
        writer.add(audioInput)
        
        // Video Input Configuration
        let videoOptions: Dictionary<String, Any> = [
            kCVPixelBufferPixelFormatTypeKey as String : UInt(kCVPixelFormatType_422YpCbCr8_yuvs),
            kCVPixelBufferIOSurfacePropertiesKey as String : [:]
        ]
        let readerVideoTrackOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoOptions)
        
        readerVideoTrackOutput.alwaysCopiesSampleData = true
        
        guard reader.canAdd(readerVideoTrackOutput) else {
            errorHandler(CompressionError(title: "Cannot add video output"))
            return CancelableCompression()
        }
        reader.add(readerVideoTrackOutput)
        
        // Audio Input Configuration
        let decompressionAudioSettings: Dictionary<String, Any> = [
            AVFormatIDKey: UInt(kAudioFormatLinearPCM)
        ]
        let readerAudioTrackOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: decompressionAudioSettings)
        
        readerAudioTrackOutput.alwaysCopiesSampleData = true
        
        guard reader.canAdd(readerAudioTrackOutput) else {
            errorHandler(CompressionError(title: "Cannot add video output"))
            return CancelableCompression()
        }
        reader.add(readerAudioTrackOutput)
        
        // Orientation Fix for Videos Taken by Device Camera
        var appliedTransform: CGAffineTransform
        //        switch compressionTransform {
        //        case .fixForFrontCamera:
        //            appliedTransform = CGAffineTransform(rotationAngle: 90.degreesToRadiansCGFloat).scaledBy(x:-1.0, y:1.0)
        //        case .fixForBackCamera:
        //            appliedTransform = CGAffineTransform(rotationAngle: 270.degreesToRadiansCGFloat)
        //        case .keepSame:
        //            appliedTransform = CGAffineTransform.identity
        //        }
        
        appliedTransform = CGAffineTransform(rotationAngle: 270.degreesToRadiansCGFloat)
        
        // Begin Compression
        reader.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: avAsset.duration)
        writer.shouldOptimizeForNetworkUse = true
        reader.startReading()
        writer.startWriting()
        writer.startSession(atSourceTime: CMTime.zero)
        
        // Compress in Background
        let cancelable = CancelableCompression()
        compressQueue.async {
            // Allocate OpenGL Context to Draw and Transform Video Frames
            let glContext = EAGLContext(api: .openGLES2)!
            let context = CIContext(eaglContext: glContext)
            let compressionContext = CompressionContext()
            
            // Loop Video Frames
            var frameCount = 0
            var videoDone = false
            var audioDone = false
            
            while !videoDone || !audioDone {
                // Check for Writer Errors (out of storage etc.)
                if writer.status == AVAssetWriter.Status.failed {
                    reader.cancelReading()
                    writer.cancelWriting()
                    compressionContext.pxbuffer = nil
                    compressionContext.cgContext = nil
                    
                    if let e = writer.error {
                        errorHandler(e)
                        return
                    }
                }
                
                // Check for Reader Errors (source file corruption etc.)
                if reader.status == AVAssetReader.Status.failed {
                    reader.cancelReading()
                    writer.cancelWriting()
                    compressionContext.pxbuffer = nil
                    compressionContext.cgContext = nil
                    
                    if let e = reader.error {
                        errorHandler(e)
                        return
                    }
                }
                
                // Check for Cancel
                if cancelable.cancel {
                    reader.cancelReading()
                    writer.cancelWriting()
                    compressionContext.pxbuffer = nil
                    compressionContext.cgContext = nil
                    cancelHandler()
                    return
                }
                
                // Check if enough data is ready for encoding a single frame
                if videoInput.isReadyForMoreMediaData {
                    // Copy a single frame from source to destination with applied transforms
                    if let vBuffer = readerVideoTrackOutput.copyNextSampleBuffer(), CMSampleBufferDataIsReady(vBuffer) {
                        frameCount += 1
                        
                        autoreleasepool {
                            let presentationTime = CMSampleBufferGetPresentationTimeStamp(vBuffer)
                            let pixelBuffer = CMSampleBufferGetImageBuffer(vBuffer)!
                            
                            CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue:0))
                            
                            let transformedFrame = CIImage(cvPixelBuffer: pixelBuffer).transformed(by: appliedTransform)
                            let frameImage = context.createCGImage(transformedFrame, from: transformedFrame.extent)
                            let frameBuffer = getCVPixelBuffer(frameImage, compressionContext: compressionContext)
                            
                            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
                            
                            _ = pixelBufferAdaptor.append(frameBuffer!, withPresentationTime: presentationTime)
                        }
                    } else {
                        // Video source is depleted, mark as finished
                        if !videoDone {
                            videoInput.markAsFinished()
                        }
                        videoDone = true
                    }
                }
                
                if audioInput.isReadyForMoreMediaData {
                    // Copy a single audio sample from source to destination
                    if let aBuffer = readerAudioTrackOutput.copyNextSampleBuffer(), CMSampleBufferDataIsReady(aBuffer) {
                        _ = audioInput.append(aBuffer)
                    } else {
                        // Audio source is depleted, mark as finished
                        if !audioDone {
                            audioInput.markAsFinished()
                        }
                        audioDone = true
                    }
                }
                
                // Let background thread rest for a while
                Thread.sleep(forTimeInterval: 0.001)
            }
            
            // Write everything to output file
            writer.finishWriting(completionHandler: {
                compressionContext.pxbuffer = nil
                compressionContext.cgContext = nil
                completionHandler(filePath)
            })
        }
        
        // Return a cancel wrapper for users to let them interrupt the compression
        return cancelable
    } catch {
        // Error During Reader or Writer Creation
        errorHandler(error)
        return CancelableCompression()
    }
}

//func isStorageAvailable() -> Bool {
//    let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
//    do {
//        let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey, .volumeTotalCapacityKey])
//        guard let totalSpace = values.volumeTotalCapacity,
//              let freeSpace = values.volumeAvailableCapacityForImportantUsage else {
//                  return false
//              }
//        if freeSpace > minimumSpaceRequired {
//            return true
//        } else {
//            // Capacity is unavailable
//            return false
//        }
//        catch {}
//        return false
//    }
//    
//    func cleanExpiredVideos() {
//        let currentTimeStamp = Date().timeIntervalSince1970
//        var expiredKeys: [String] = []
//        for videoData in videosDict where currentTimeStamp - videoData.value.timeStamp >= expiryTime {
//            // video is expired. delete
//            if let _ = popupVideosDict[videoData.key] {
//                expiredKeys.append(videoData.key)
//            }
//        }
//        for key in expiredKeys {
//            if let _ = popupVideosDict[key] {
//                popupVideosDict.removeValue(forKey: key)
//                deleteVideo(ForVideoId: key)
//            }
//        }
//    }
//    
//    func removeVideoIfMaxNumberOfVideosReached() {
//        if popupVideosDict.count >= maxVideosAllowed {
//            // remove the least recently used video
//            let sortedDict = popupVideosDict.keysSortedByValue { (v1, v2) -> Bool in
//                v1.timeStamp < v2.timeStamp
//            }
//            guard let videoId = sortedDict.first else {
//                return
//            }
//            popupVideosDict.removeValue(forKey: videoId)
//            deleteVideo(ForVideoId: videoId)
//        }
//    }
//    
//    static func findCachedVideoURL(forVideoId id: String) -> URL? {
//        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
//        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
//        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
//        if let dirPath = paths.first {
//            let fileURL = URL(fileURLWithPath: dirPath).appendingPathComponent(folderPath).appendingPathComponent(id + ".mp4")
//            let filePath = fileURL.path
//            let fileManager = FileManager.default
//            if fileManager.fileExists(atPath: filePath) {
//                NewRelicService.sendCustomEvent(with: NewRelicEventType.statusCodes,
//                                                eventName: NewRelicEventName.videoCacheHit,
//                                                attributes: [NewRelicAttributeKey.videoSize: fileURL.fileSizeString])
//                return fileURL
//            } else {
//                return nil
//            }
//        }
//        return nil
//    }
//    
//    
//    extension URL {
//        var attributes: [FileAttributeKey : Any]? {
//            do {
//                return try FileManager.default.attributesOfItem(atPath: path)
//            } catch let error as NSError {
//                print("FileAttribute error: \(error)")
//            }
//            return nil
//        }
//        
//        var fileSize: UInt64 {
//            return attributes?[.size] as? UInt64 ?? UInt64(0)
//        }
//        
//        var fileSizeString: String {
//            return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
//        }
//    }
