//
//  CameraViewModel.swift
//  VidChat
//
//  Created by Student on 2021-09-27.
//

import Foundation

class CameraViewModel: ObservableObject {
    @Published var hasRecordedVideo = false
    @Published var url: URL?

    
    func setHasRecordedVideo() {
        hasRecordedVideo = true
    }
    
    func setUrl(_ url: URL) {
        self.url = url
    }
}
