//
//  Filters.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-06-04.
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import Vision

enum Filter: CaseIterable {
    
    case blur, one, two, three
    
    var name: String {
        
        switch self {
        case .blur:
            return "bg blur"
        case .one:
            return "vibrant"
        case .two:
            return "mello"
        case .three:
            return "dim"
//        case .four:
//            return "four"
        }
        
    }
    
    var imageName: String {
        
        switch self {
        case .blur:
            return "filterBackgroundBlurred"
        case .one:
            return "filterBackgroundPositiveVibrance"
        case .two:
            return "filterBackgroundGamma"
        case .three:
            return "filterBackgroundNegativeVibrance"
        }
        
    }
    
    
    static func applyFilter(toImage image: CIImage, filter: Filter, sampleBuffer: CMSampleBuffer? = nil) -> CIImage? {
        
        switch filter {
            
        case .blur:
            return Filter.applyBlurFilter(sampleBuffer: sampleBuffer)
        case .one:
            let vibrance = CIFilter.vibrance()
            vibrance.amount = 1
            vibrance.inputImage = image
            return vibrance.outputImage
        case .two:
            let gamma = CIFilter.gammaAdjust()
            gamma.power = 0.8
            gamma.inputImage = image
            return gamma.outputImage
        case .three:
//            let colorControls = CIFilter.colorControls()
//            colorControls.brightness = 0
//            colorControls.contrast = 0.95
//            colorControls.saturation = 1.2
//            colorControls.inputImage = image
//            return colorControls.outputImage
            
            let vibrance = CIFilter.vibrance()
            vibrance.amount = -1.5
            vibrance.inputImage = image
            return vibrance.outputImage
//        case .four:
//            let temperatureAndTint = CIFilter.temperatureAndTint()
//            temperatureAndTint.neutral = CIVector.init(x: 5500, y: 0)
//            temperatureAndTint.targetNeutral = CIVector.init(x: 0, y: 0)
//            temperatureAndTint.inputImage = image
//            return temperatureAndTint.outputImage
        }
        
//        let textImageGenerator = CIFilter.textImageGenerator()
//        textImageGenerator.text = "TESTER"
//        textImageGenerator.scaleFactor = 1
//        textImageGenerator.fontSize = 16
//        let textImage = textImageGenerator.outputImage
//        
//        let compose = CIFilter.sourceAtopCompositing()
//        compose.inputImage = textImage
//        compose.backgroundImage = image
//        return compose.outputImage
        
    }
    
    
    static func applyBlurFilter(sampleBuffer: CMSampleBuffer?) -> CIImage? {
        
        
        guard let sampleBuffer = sampleBuffer, #available(iOS 15.0, *) else { return nil }
        
        lazy var personSegmentationRequest: VNGeneratePersonSegmentationRequest = {
            let request = VNGeneratePersonSegmentationRequest()
            request.qualityLevel = .balanced
            request.outputPixelFormat = kCVPixelFormatType_OneComponent8
            return request
        }()
        
        
        let sequenceRequestHandler = VNSequenceRequestHandler()
        try? sequenceRequestHandler.perform([personSegmentationRequest],
                                            on: sampleBuffer,
                                            orientation: .up)
        
        guard let resultPixelBuffer = personSegmentationRequest.results?.first?.pixelBuffer else { return nil }
        
        
        let originalImage = CIImage(cvPixelBuffer: sampleBuffer.imageBuffer!)

        var maskImage = CIImage(cvPixelBuffer: resultPixelBuffer)
        
        let maxcomp = CIFilter.maximumComponent()
        maxcomp.inputImage = originalImage
        
        
        let filter = CIFilter.gaussianBlur()
        filter.inputImage = originalImage
        var newImage = filter.outputImage?.cropped(to: originalImage.extent)
        
//        if let image = newImage {
//            let scaleX = originalImage.extent.size.width / image.extent.size.width
//            let scaleY = originalImage.extent.size.height / newImage.extent.size.height
//
//            let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
//            newImage = newImage.transformed(by: transform)
//        }
     
        
        
        
        let scaleXForMask = originalImage.extent.width / maskImage.extent.width
        let scaleYForMask = originalImage.extent.height / maskImage.extent.height
        maskImage = maskImage.transformed(by: .init(scaleX: scaleXForMask, y: scaleYForMask))
        
        let blend = CIFilter.blendWithMask()
        blend.backgroundImage = newImage
        blend.inputImage = originalImage
        blend.maskImage = maskImage
        
        return blend.outputImage
    }
}
