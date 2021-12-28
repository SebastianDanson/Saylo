//
//  CropController.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-28.
//

import SwiftUI
import CropViewController

struct ImageCropper: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    @Binding var showImageCropper: Bool
    @Binding var showImagePicker: Bool

    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = CropViewController(croppingStyle: .circular, image: image ?? UIImage())
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
            withAnimation {
                self.parent.showImageCropper = false
            }
        }
        
        func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
            withAnimation {
                self.parent.showImageCropper = false
            }
            
            self.parent.showImagePicker = true
        }
    }
}
