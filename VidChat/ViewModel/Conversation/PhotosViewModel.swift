//
//  PhotosViewModel.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-02-04.
//

import Foundation
import PhotosUI

class PhotosViewModel: ObservableObject {
        
    
    static let shared = PhotosViewModel()
    
    private init() {}
    
    
    func getHasAccessToPhotos() -> Bool {
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == .denied {
            MainViewModel.shared.showPhotosAlert = true
        }
                
        return status == .authorized
    }
    
    
    func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}
