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
    
    typealias UIViewType = PhotosCollectionView
//    var photosCollectionView = PhotosCollectionView()
    
    let baseHeight: CGFloat
    @Binding var height: CGFloat
    @Binding var showVideoLengthAlert: Bool

    func makeUIView(context: Context) -> PhotosCollectionView {
        let photosCollectionView = PhotosCollectionView()
        photosCollectionView.delegate = context.coordinator
        return photosCollectionView
    }
    
    func updateUIView(_ uiView: PhotosCollectionView, context: Context) {
        uiView.setIsSendEnabled()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
//    func setIsSendEnabled() {
//        photosCollectionView.setIsSendEnabled()
//    }

    class Coordinator: NSObject, UINavigationControllerDelegate, PhotosCollectioViewDelegate {
      
        func showAlert() {
            self.parent.showVideoLengthAlert = true
        }
        
        
        func resetHeight() {
            withAnimation(.linear(duration: 0.2)) {
                self.parent.height = self.parent.baseHeight
            }
        }
        
        func hidePhotoPicker() {
            withAnimation(.linear(duration: 0.1)) {
                ConversationViewModel.shared.showPhotos = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.resetHeight()
            }
        }
        
        
        func setHeightOffset(offset: CGFloat) {
            self.parent.height = self.parent.baseHeight - offset
        }
        
        let parent: PhotoPickerView
        
        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }
        
    }
}


