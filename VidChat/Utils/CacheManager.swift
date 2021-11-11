//
//  CacheManager.swift
//  VidChat
//
//  Created by Student on 2021-11-10.
//

import Foundation
import AVFoundation

class CacheManager {
    
    static func getCachedUrl(_ url: URL, isVideo: Bool) -> URL {
        if fileExists(forUrl: url, isVideo: isVideo) {
            print("EXOSTS")
            return createNewPath(lastPath: url.lastPathComponent.appending(isVideo ? ".mov" : ".m4a"))
        } else {
            print("NO EXOSTS")

            isVideo ? (exportSession(forUrl: url)) : (exportAudio(forUrl: url))
            return url
        }
    }
    
    static func createNewPath(lastPath: String) -> URL {
        let cachesDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        
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
         guard
             let cacheDirectory = FileManager.default.urls(
                 for: .cachesDirectory,
                    in: .userDomainMask).first
         else { return }
         
         let outputURL = cacheDirectory.appendingPathComponent("\(fileName).m4a")
         print("File path: \(outputURL)")
         
         if FileManager.default.fileExists(atPath: outputURL.path) {
             do {
                 print("REMOVING", outputURL.lastPathComponent)
                  try FileManager.default.removeItem(at: outputURL)
             } catch let error {
                 print("Failed to delete file with error: \(error)")
             }
         }
         
         exporter.outputURL = outputURL
         exporter.outputFileType = AVFileType.m4a
         
         exporter.exportAsynchronously {
             print("Exporter did finish")
             if let error = exporter.error {
                 print("Error \(error)")
             }
         }
    }
    
   static func exportSession(forUrl url: URL) {
       let asset = AVURLAsset(url: url)
       
        if !asset.isExportable { return }
        
        // --- https://stackoverflow.com/a/41545559/1065334
        let composition = AVMutableComposition()
        
        if let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid)),
           let sourceVideoTrack = asset.tracks(withMediaType: .video).first {
            do {
                try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration), of: sourceVideoTrack, at: CMTime.zero)
            } catch {
                print("Failed to compose video")
                return
            }
        }
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
        
        guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            print("Failed to create export session")
            return
        }
        
        //        self.exporter = exporter
        let fileName = asset.url.lastPathComponent
        
        // let outputURL = documentsDirectory.appendingPathComponent(fileName)
        guard
            let cacheDirectory = FileManager.default.urls(
                for: .cachesDirectory,
                   in: .userDomainMask).first
        else { return }
        
        let outputURL = cacheDirectory.appendingPathComponent("\(fileName).mov")
        print("File path: \(outputURL)")
        
        if FileManager.default.fileExists(atPath: outputURL.path) {
            do {
                print("REMOVING", outputURL.lastPathComponent)
                // try FileManager.default.removeItem(at: outputURL)
            } catch let error {
                print("Failed to delete file with error: \(error)")
            }
        }
        
        exporter.outputURL = outputURL
        exporter.outputFileType = AVFileType.mp4
        
        exporter.exportAsynchronously {
            print("Exporter did finish")
            if let error = exporter.error {
                print("Error \(error)")
            }
        }
    }
    
    static func fileExists(forUrl url: URL, isVideo: Bool) -> Bool {
        let fileName = url.lastPathComponent
        
        // let outputURL = documentsDirectory.appendingPathComponent(fileName)
        guard
            let cacheDirectory = FileManager.default.urls(
                for: .cachesDirectory,
                   in: .userDomainMask).first
        else { return false }
        
        let pathComp = isVideo ? "\(fileName).mov" : "\(fileName).m4a"
        let outputURL = cacheDirectory.appendingPathComponent(pathComp)
        
        return FileManager.default.fileExists(atPath: outputURL.path)
    }
    
    static func removeOldFiles() {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {

        let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                let date = (try? FileManager.default.attributesOfItem(atPath: fileURL.path))?[.creationDate] as? Date

                if date!.timeIntervalSince1970 < Date().timeIntervalSince1970 - 86400  {
                    try FileManager.default.removeItem(at: fileURL)
                }
            }
        } catch {
            print("ERROR removing file")
        }
    }
}
