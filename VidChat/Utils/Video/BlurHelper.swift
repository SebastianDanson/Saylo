//
//  BlurHelper.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-06-28.
//

import Vision
import UIKit

class BlurHelper {
    
    static func processVideoFrame(_ framePixelBuffer: CVPixelBuffer) -> CIImage? {
        guard #available(iOS 15.0, *) else { return nil }
        
        let requestHandler = VNSequenceRequestHandler()
        
        let segmentationRequest = VNGeneratePersonSegmentationRequest()
        segmentationRequest.qualityLevel = .balanced
        segmentationRequest.outputPixelFormat = kCVPixelFormatType_OneComponent8
        
        // Perform the requests on the pixel buffer that contains the video frame.
        try? requestHandler.perform([segmentationRequest],
                                    on: framePixelBuffer,
                                    orientation: .right)
        
        // Get the pixel buffer that contains the mask image.
        guard let maskPixelBuffer =
                segmentationRequest.results?.first?.pixelBuffer else { return nil }
        
        // Process the images.
        return blend(original: framePixelBuffer, mask: maskPixelBuffer)
    }
    
    // MARK: - Process Results
    
    // Performs the blend operation.
    static func blend(original framePixelBuffer: CVPixelBuffer,
                       mask maskPixelBuffer: CVPixelBuffer) -> CIImage? {
        // Create CIImage objects for the video frame and the segmentation mask.
        let originalImage = CIImage(cvPixelBuffer: framePixelBuffer).oriented(.right)
        var maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)
        
        // Scale the mask image to fit the bounds of the video frame.
        let scaleX = originalImage.extent.width / maskImage.extent.width
        let scaleY = originalImage.extent.height / maskImage.extent.height
        maskImage = maskImage.transformed(by: .init(scaleX: scaleX, y: scaleY))
        
        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.radius = 15
        blurFilter.inputImage = originalImage
        let backgroundImage = blurFilter.outputImage?.cropped(to: originalImage.extent)
        
        // Blend the original, background, and mask images.
        let blendFilter = CIFilter.blendWithMask()
        blendFilter.inputImage = originalImage
        blendFilter.backgroundImage = backgroundImage
        blendFilter.maskImage = maskImage
        
        // Set the new, blended image as current.
        return blendFilter.outputImage?.oriented(.left)
    }
}
