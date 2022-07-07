//
//  VibrantCIFilter.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-06-28.
//

import CoreMedia
import CoreVideo
import CoreImage

class VibrantCIRenderer: FilterRenderer {
        
    var isPrepared = false
    var isPositive: Bool
    
    private var ciContext: CIContext?
    
    private var vibrantFilter: CIFilter?
    
    private var outputColorSpace: CGColorSpace?
    
    private var outputPixelBufferPool: CVPixelBufferPool?
    
    private(set) var outputFormatDescription: CMFormatDescription?
    
    private(set) var inputFormatDescription: CMFormatDescription?
    
    init(isPositive: Bool) {
        self.isPositive = isPositive
    }
    
    /// - Tag: FilterCoreImageVibrant
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
        vibrantFilter = CIFilter(name: "CIVibrance")
        vibrantFilter!.setValue(isPositive ? 1.0 : -1.0, forKey: "inputAmount")
        isPrepared = true
    }
    
    func reset() {
        ciContext = nil
        vibrantFilter = nil
        outputColorSpace = nil
        outputPixelBufferPool = nil
        outputFormatDescription = nil
        inputFormatDescription = nil
        isPrepared = false
    }
    
    func render(pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {

        guard let vibrantFilter = vibrantFilter,
            let ciContext = ciContext,
            isPrepared else {
                assertionFailure("Invalid state: Not prepared")
                return nil
        }
        
        let sourceImage = CIImage(cvImageBuffer: pixelBuffer)
        vibrantFilter.setValue(sourceImage, forKey: kCIInputImageKey)
        
        guard var filteredImage = vibrantFilter.value(forKey: kCIOutputImageKey) as? CIImage else {
            print("CIFilter failed to render image")
            return nil
        }
        
        var pbuf: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, outputPixelBufferPool!, &pbuf)
        guard let outputPixelBuffer = pbuf else {
            print("Allocation failure")
            return nil
        }
        
        if MainViewModel.shared.isRecording, !TextOverlayViewModel.shared.overlayText.isEmpty, let textImage = TextOverlayViewModel.shared.addText(toImage: filteredImage) {
            filteredImage = textImage
        }
        
        // Render the filtered image out to a pixel buffer (no locking needed, as CIContext's render method will do that)
        ciContext.render(filteredImage, to: outputPixelBuffer, bounds: filteredImage.extent, colorSpace: outputColorSpace)
        return outputPixelBuffer
    }
}
