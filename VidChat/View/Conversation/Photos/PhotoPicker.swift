//
//  PhotoPicker.swift
//  VidChat
//
//  Created by Student on 2021-10-15.
//

import SwiftUI
import Photos

import Foundation
import SwiftUI
import AVFoundation

struct PhotoPickerView: UIViewRepresentable {
    
    typealias UIViewType = PhotosCollectioView
    private var photosCollectioView = PhotosCollectioView()

    func makeUIView(context: Context) -> PhotosCollectioView {
        photosCollectioView
    }
    
    func updateUIView(_ uiView: PhotosCollectioView, context: Context) {
    }
}


