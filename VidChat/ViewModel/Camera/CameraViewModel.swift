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
    @Published var hasFlash = false
    @Published var progress = 0.0
    @Published var isRecording = false
    @Published var showCamera = false
    
    func reset() {
        hasRecordedVideo = false
        url = nil
        hasFlash = false
        progress = 0.0
        isRecording = false
        showCamera = false
    }
}
