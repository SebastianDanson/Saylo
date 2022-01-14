//
//  CacheManager.swift
//  VidChat
//
//  Created by Student on 2021-11-10.
//

import Foundation
import AVFoundation

//TODO cache audio URLs
//TODO actually cut off after 20s
class CacheManager {
    
    static func getCachedUrl(_ url: URL, userStoredURL: URL?, isVideo: Bool) -> URL {
        if fileExists(forUrl: url, isVideo: isVideo) {
            //            print("EXISTS")
            return createNewPath(lastPath: url.lastPathComponent.appending(isVideo ? ".mov" : ".m4a"))
        } else if let url = userStoredURL, fileExists(forUrl: url, isVideo: isVideo, addComp: false) {
            //            print("STORED EXISTS")
            return createNewPath(lastPath: url.lastPathComponent)
        }
        else {
            //            print("DOESNT EXIST")
            DispatchQueue.global(qos: .userInitiated).async {
                isVideo ? (exportSession(forUrl: url)) : (exportAudio(forUrl: url))
            }
            return url
        }
    }
    
    static func createNewPath(lastPath: String) -> URL {
        // let cachesDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let cachesDirectory = NSTemporaryDirectory()
        
        let destination = URL(fileURLWithPath: String(format: "%@/%@", cachesDirectory, lastPath))
        return destination
    }
    
    static func exportAudio(forUrl url: URL) {
        let asset = AVURLAsset(url: url)
        
        if !asset.isExportable { return }
        
        // --- https://stackoverflow.com/a/41545559/1065334
        let composition = AVMutableComposition()
        
        if let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid)),
           let sourceAudioTrack = asset.tracks(withMediaType: .audio).first {
            do {
                try compositionAudioTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration), of: sourceAudioTrack, at: CMTime.zero)
            } catch {
                print("Failed to compose audio")
                return
            }
        }
        // ---
        
        guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A) else {
            print("Failed to create export session")
            return
        }
        
        //        self.exporter = exporter
        let fileName = asset.url.lastPathComponent
        
        // let outputURL = documentsDirectory.appendingPathComponent(fileName)
        //         guard
        //             let cacheDirectory = FileManager.default.urls(
        //                 for: .cachesDirectory,
        //                    in: .userDomainMask).first
        //         else { return }
        
        let cacheDirectory = NSTemporaryDirectory() as NSString
        
        let outputURL = cacheDirectory.appendingPathComponent("\(fileName).m4a")
        print("File path: \(outputURL)")
        
        if FileManager.default.fileExists(atPath: outputURL) {
            do {
                try FileManager.default.removeItem(at: URL(string: outputURL)!)
            } catch let error {
                print("Failed to delete file with error: \(error)")
            }
        }
        
        exporter.outputURL = URL(fileURLWithPath: outputURL)
        exporter.outputFileType = AVFileType.m4a
        
        exporter.exportAsynchronously {
            print("Exporter did finish")
            if let error = exporter.error {
                print("Error \(error)")
            }
        }
    }
    
    static func exportSession(forUrl url: URL, addAudio: Bool = true) {
        let asset = AVURLAsset(url: url)
        
        if !asset.isExportable { return }
        
        // --- https://stackoverflow.com/a/41545559/1065334
        let composition = AVMutableComposition()
        
        if let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid)),
           let sourceVideoTrack = asset.tracks(withMediaType: .video).first {
            compositionVideoTrack.preferredTransform = sourceVideoTrack.preferredTransform
            do {
                try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration), of: sourceVideoTrack, at: CMTime.zero)
            } catch {
                print("Failed to compose video")
                return
            }
        }
        
        if addAudio {
            if let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid)),
               let sourceAudioTrack = asset.tracks(withMediaType: .audio).first {
                do {
                    try compositionAudioTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration), of: sourceAudioTrack, at: CMTime.zero)
                } catch {
                    print("Failed to compose audio")
                    return
                }
            }
        }
        // ---
        
        guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            print("Failed to create export session")
            return
        }
        
        //        self.exporter = exporter
        let fileName = asset.url.lastPathComponent
        
        // let outputURL = documentsDirectory.appendingPathComponent(fileName)
        //        guard
        //            let cacheDirectory = FileManager.default.urls(
        //                for: .cachesDirectory,
        //                   in: .userDomainMask).first
        //        else { return }
        let cacheDirectory = NSTemporaryDirectory() as NSString
        
        
        let outputURL = cacheDirectory.appendingPathComponent("\(fileName).mov")
        print("File path: \(outputURL)")
        
        if FileManager.default.fileExists(atPath: outputURL) {
            do {
                //                print("REMOVING", outputURL.lastPathComponent)
                // try FileManager.default.removeItem(at: outputURL)
                
              
            } catch let error {
                print("Failed to delete file with error: \(error)")
            }
        }
        
        exporter.outputURL = URL(fileURLWithPath: outputURL)
        exporter.outputFileType = AVFileType.mov
        
        exporter.exportAsynchronously {
            print("Exporter did finish")
            if let error = exporter.error {
                print("Error \(error)")
                
                if addAudio {
                    self.exportSession(forUrl: url, addAudio: false)
                }
            }
        }
    }
    
    static func fileExists(forUrl url: URL, isVideo: Bool, addComp: Bool = true) -> Bool {
        let fileName = url.lastPathComponent
        
        // let outputURL = documentsDirectory.appendingPathComponent(fileName)
        //        guard
        //            let cacheDirectory = FileManager.default.urls(
        //                for: .cachesDirectory,
        //                   in: .userDomainMask).first
        //        else { return false }
        let cacheDirectory = NSTemporaryDirectory() as NSString
        
        
        let pathComp = addComp ? (isVideo ? "\(fileName).mov" :"\(fileName).m4a") : "\(fileName)"
        let outputURL = cacheDirectory.appendingPathComponent(pathComp)
        return FileManager.default.fileExists(atPath: outputURL)
    }
    
    static func removeOldFiles() {
        
        do {
            
            let tempDir = NSTemporaryDirectory()
            let fileURLs = try FileManager.default.contentsOfDirectory(atPath: tempDir)
            
            for fileURL in fileURLs {
                let fullUrl = tempDir + fileURL
                let date = (try? FileManager.default.attributesOfItem(atPath: fullUrl))?[.creationDate] as? Date
                if let date = date, date.timeIntervalSince1970 < Date().timeIntervalSince1970 - 86400  {
                    try FileManager.default.removeItem(at: URL(fileURLWithPath: fullUrl))
                }
            }
        } catch {
            print("ERROR removing file")
        }
    }
}
