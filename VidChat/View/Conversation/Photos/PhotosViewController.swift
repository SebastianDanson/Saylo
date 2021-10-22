//
//  PhotosViewController.swift
//  VidChat
//
//  Created by Student on 2021-10-22.
//

import UIKit
import SwiftUI


final class PhotosViewController: UIViewController {
    let cameraController = CameraController()
    var previewView: UIView!
    
    override func viewDidLoad() {
                
        previewView = UIView(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        previewView.contentMode = UIView.ContentMode.scaleAspectFit
        view.addSubview(previewView)
        
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            
            try? self.cameraController.displayPreview(on: self.previewView)
        }
        
    }
}


extension PhotosViewController : UIViewControllerRepresentable{
    public typealias UIViewControllerType = PhotosViewController
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<PhotosViewController>) -> PhotosViewController {
        return PhotosViewController()
    }
    
    public func updateUIViewController(_ uiViewController: PhotosViewController, context: UIViewControllerRepresentableContext<PhotosViewController>) {
    }
}
