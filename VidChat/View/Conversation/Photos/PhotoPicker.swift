//
//  PhotoPicker.swift
//  VidChat
//
//  Created by Student on 2021-10-15.
//

import Photos
import Foundation
import SwiftUI
import AVFoundation

struct PhotoPickerView: UIViewRepresentable {
    
    typealias UIViewType = PhotosCollectioView
    var photosCollectioView = PhotosCollectioView()
    let baseHeight: CGFloat
    @Binding var height: CGFloat
    @Binding var isShowingPhotos: Bool
    
    func makeUIView(context: Context) -> PhotosCollectioView {
        photosCollectioView.delegate = context.coordinator
        return photosCollectioView
    }
    
    func updateUIView(_ uiView: PhotosCollectioView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, PhotosCollectioViewDelegate {
        
        func resetHeight() {
            withAnimation(.linear(duration: 0.2)) {
                self.parent.height = self.parent.baseHeight
            }
        }
        
        func hidePhotoPicker() {
            withAnimation(.linear(duration: 0.1)) {
                self.parent.isShowingPhotos = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.resetHeight()
            }
        }
        
        
        func setHeightOffset(offset: CGFloat) {
            print(offset, "OFFSET")
            self.parent.height = self.parent.baseHeight - offset
        }
        
        let parent: PhotoPickerView
        
        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }
        
    }
}


