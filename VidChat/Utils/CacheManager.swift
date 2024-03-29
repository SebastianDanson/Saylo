//
//  CacheManager.swift
//  Saylo
//
//  Created by Student on 2021-11-10.
//

import Foundation
import AVFoundation


class CacheManager {
    
    static func getCachedUrl(_ url: URL, userStoredURL: URL?, isVideo: Bool) -> URL {
        
        if fileExists(forUrl: url, isVideo: isVideo) {
            if let path = createNewPath(lastPath: url.lastPathComponent.appending(isVideo ? ".mov" : ".m4a")) {
                return path
            }
        } else if let url = userStoredURL, fileExists(forUrl: url, isVideo: isVideo, addComp: false) {
            if let path = createNewPath(lastPath: url.lastPathComponent) {
                return path
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            exportSession(forUrl: url, isVideo: isVideo)
        }
        
        return url
    }
    
    static func createNewPath(lastPath: String) -> URL? {
        // let cachesDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let cachesDirectory = NSTemporaryDirectory()
        
        let destination = URL(fileURLWithPath: String(format: "%@/%@", cachesDirectory, lastPath))
        
        let asset = AVAsset(url: destination)

        if asset.duration.seconds == 0.0 {
            do {
                try FileManager.default.removeItem(at: destination)
            } catch let error {
                print("Failed to delete file with error: \(error)")
            }
            return nil
        }
        
        return destination
    }
    
   
    static func exportSession(forUrl url: URL, isVideo: Bool) {
        
        let fileName = url.lastPathComponent
        let cacheDirectory = NSTemporaryDirectory() as NSString
        
        let fileExtension = isVideo ? ".mov" : ".m4a"
        let outputURL = cacheDirectory.appendingPathComponent("\(fileName)\(fileExtension)")
        
        if let videoData = NSData(contentsOf: url) {
            
            do {
                try videoData.write(toFile: outputURL, options: .atomic)
            } catch let e {
                print("ERROR WRITING TO FILE: \(e.localizedDescription)")
            }
           
//
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
        
        let fileOutputUrl = sharedDirectoryURL().appendingPathComponent(pathComp)
        
        if FileManager.default.fileExists(atPath: fileOutputUrl.path) {
            do {
                try FileManager.default.moveItem(atPath: fileOutputUrl.path, toPath: outputURL)
                
            } catch let e {
                print("ERROR MOVING FILE: \(e.localizedDescription)")
                
                try? FileManager.default.removeItem(at: fileOutputUrl)
            }
            
        }
        
        return FileManager.default.fileExists(atPath: outputURL)
    }
    
    static func sharedDirectoryURL() -> URL {
        let fileManager = FileManager.default
        return fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.SebastianDanson.saylo")!
       
    }
    
    static func removeOldFiles() {
        
        do {
            
            let tempDir = NSTemporaryDirectory()
            let fileURLs = try FileManager.default.contentsOfDirectory(atPath: tempDir)
            
            for fileURL in fileURLs {
                let fullUrl = tempDir + fileURL
                let date = (try? FileManager.default.attributesOfItem(atPath: fullUrl))?[.creationDate] as? Date
                
                if let date = date, date.timeIntervalSince1970 < Date().timeIntervalSince1970 - (86400 * 2)  {
                    try FileManager.default.removeItem(at: URL(fileURLWithPath: fullUrl))
                }
            }
        } catch {
            print("ERROR removing file")
        }
    }
}

