//
//  BlurHelper.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-06-28.
//

import Vision
import UIKit

class BlurHelper {
    
    static let requestHandler = VNSequenceRequestHandler()
    @available(iOS 15.0, *)
    static let segmentationRequest = VNGeneratePersonSegmentationRequest()
    static let blendFilter = CIFilter.blendWithMask()
    static let blurFilter = CIFilter.gaussianBlur()
    
    static func processVideoFrame(_ framePixelBuffer: CVPixelBuffer) -> CIImage? {
        guard #available(iOS 15.0, *) else { return nil }
        
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
        
        blurFilter.radius = 15
        blurFilter.inputImage = originalImage
        let backgroundImage = blurFilter.outputImage?.cropped(to: originalImage.extent)
        
        // Blend the original, background, and mask images.
        blendFilter.inputImage = originalImage
        blendFilter.backgroundImage = backgroundImage
        blendFilter.maskImage = maskImage
        
        // Set the new, blended image as current.
        return blendFilter.outputImage?.oriented(.left)
    }
    
}

class BlurredBackgroundRenderer {
    
    var isPrepared = false
    
    private var ciContext: CIContext?
        
    private var outputColorSpace: CGColorSpace?
    
    private var outputPixelBufferPool: CVPixelBufferPool?
    
    private(set) var outputFormatDescription: CMFormatDescription?
    
    private(set) var inputFormatDescription: CMFormatDescription?
    
    /// - Tag: FilterCoreImageRosy
    func prepare(with formatDescription: CMFormatDescription, outputRetainedBufferCountHint: Int) {
        reset()
        
        (outputPixelBufferPool,
         outputColorSpace,
         outputFormatDescription) = allocateOutputBufferPool(with: formatDescription,
                                                             outputRetainedBufferCountHint: outputRetainedBufferCountHint)
        if outputPixelBufferPool == nil {
            return
        }
        inputFormatDescription = formatDescription
        ciContext = CIContext()
        isPrepared = true
    }
    
    func reset() {
        ciContext = nil
        outputColorSpace = nil
        outputPixelBufferPool = nil
        outputFormatDescription = nil
        inputFormatDescription = nil
        isPrepared = false
    }
    
    func render(ciImage: CIImage) -> CVPixelBuffer? {
        var ciImage = ciImage
        guard let ciContext = ciContext, isPrepared else {
                assertionFailure("Invalid state: Not prepared")
                return nil
        }
                
        var pbuf: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, outputPixelBufferPool!, &pbuf)
        guard let outputPixelBuffer = pbuf else {
            print("Allocation failure")
            return nil
        }
        
        if MainViewModel.shared.isRecording, !TextOverlayViewModel.shared.overlayText.isEmpty, let textImage = TextOverlayViewModel.shared.addText(toImage: ciImage) {
            ciImage = textImage
        }
        
        // Render the filtered image out to a pixel buffer (no locking needed, as CIContext's render method will do that)
        ciContext.render(ciImage, to: outputPixelBuffer, bounds: ciImage.extent, colorSpace: outputColorSpace)
        return outputPixelBuffer
    }
}
