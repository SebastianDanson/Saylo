//
//  CropController.swift
//  Saylo
//
//  Created by Sebastian Danson on 2021-12-28.
//

import SwiftUI
import CropViewController

struct ImageCropper: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    @Binding var showImageCropper: Bool
    @Binding var showImagePicker: Bool
    
    var onDone: (() -> Void)?

    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = CropViewController(croppingStyle: .default, image: image ?? UIImage())
        picker.aspectRatioLockEnabled = true
        picker.customAspectRatio = CGSize(width: 1,height: 1)
        picker.delegate = context.coordinator
        return picker
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    class Coordinator: NSObject, CropViewControllerDelegate {
        
        let parent: ImageCropper
        
        init(_ parent: ImageCropper) {
            self.parent = parent
        }
        
        func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            self.parent.image = image
            
            if let onDone = self.parent.onDone {
                onDone()
            }

            withAnimation {
                self.parent.showImageCropper = false
            }
            
        }
        
        func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
            
            withAnimation {
                self.parent.showImageCropper = false
            }
            
            self.parent.image = nil
            CameraViewModel.shared.photo = nil
            self.parent.showImagePicker = true
        }
    }
}
