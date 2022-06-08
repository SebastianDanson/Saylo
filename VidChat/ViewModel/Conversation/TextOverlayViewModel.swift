//
//  TextOverlayViewModel.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-06-05.
//

import SwiftUI
import UIKit
import CoreImage

class TextOverlayViewModel: ObservableObject {
    
    @Published var overlayText = ""
    
    var textLocationOffSet: CGSize = .zero
    var fontColor: UIColor = .white
    var textMagnification: CGFloat = 1
    
    static let shared = TextOverlayViewModel()
    
    private init() {}
    
    func addText(toImage cameraImage: CIImage) -> CIImage? {
        
        let scale = textMagnification
        
        // Text to image
        let font = UIFont.rounded(ofSize: 166, weight: .semibold)
        //            let font = Font.system(size: 64, weight: .semibold, design: .rounded)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: fontColor,
        ]
        
        let attributedQuote = NSAttributedString(string: overlayText, attributes: attributes)
        if let textGenerationFilter = CIFilter(name: "CIAttributedTextImageGenerator") {
            textGenerationFilter.setValue(attributedQuote, forKey: "inputText")
            textGenerationFilter.setValue(NSNumber(value: Double(scale)), forKey: "inputScaleFactor")
            
            guard var textImage = textGenerationFilter.outputImage else { return nil }
            
            let offset = textLocationOffSet
            let scaleOffsetX = cameraImage.extent.midX * offset.width
            let scaleOffsetY = cameraImage.extent.midY * offset.height
            
            let translationX = min(abs(cameraImage.extent.midX - textImage.extent.width/2 - scaleOffsetX), abs(cameraImage.extent.width - textImage.extent.width))
            
            let transform = CGAffineTransform(translationX: translationX,
                                              y: cameraImage.extent.midY - textImage.extent.height/2 + scaleOffsetY)
            
            textImage = textImage.transformed(by: transform)
            
            return textImage
                .applyingFilter("CISourceAtopCompositing", parameters: [ kCIInputBackgroundImageKey: cameraImage])
        }
        
        return nil
    }
}
