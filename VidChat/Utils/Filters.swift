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
    
    case blur, positiveVibrance, saturated, gamma, negativeVibrance
    
    var name: String {
        
        switch self {
        case .blur:
            return "bg blur"
        case .positiveVibrance:
            return "vibrant"
        case .gamma:
            return "mello"
        case .negativeVibrance:
            return "dim"
        case .saturated:
            return "warm"
//        case .four:
//            return "four"
        }
        
    }
    
    var imageName: String {
        
        switch self {
        case .blur:
            return "filterBackgroundBlurred"
        case .positiveVibrance:
            return "filterBackgroundPositiveVibrance"
        case .gamma:
            return "filterBackgroundGamma"
        case .saturated:
            return "filterBackgroundSaturated"
        case .negativeVibrance:
            return "filterBackgroundNegativeVibrance"
        }
        
    }
    
    static func getAvailableFilters() -> [Filter] {
            
        //The blur filter isn't available unless iOS 15 or later, so if not available add negative vibrance filter instead
        var filters = Filter.allCases.filter({$0 != Filter.blur && $0 != Filter.negativeVibrance })
        if #available(iOS 15.0, *){
            filters.insert(Filter.blur, at: 0)
        } else {
            filters.append(Filter.negativeVibrance)
        }
        
        return filters
    }
    
    
    static func applyFilter(toImage image: CIImage, filter: Filter, sampleBuffer: CMSampleBuffer? = nil) -> CIImage? {
        
        switch filter {
            
        case .blur:
            return Filter.applyBlurFilter(sampleBuffer: sampleBuffer)
        case .positiveVibrance:
            let vibrance = CIFilter.vibrance()
            vibrance.amount = 0.5
            vibrance.inputImage = image
            return vibrance.outputImage
        case .gamma:
            let gamma = CIFilter.gammaAdjust()
            gamma.power = 0.85
            gamma.inputImage = image
            return gamma.outputImage
        case .saturated:
            let colorControls = CIFilter.colorControls()
            colorControls.brightness = 0
            colorControls.contrast = 0.95
            colorControls.saturation = 1.2
            colorControls.inputImage = image
            return colorControls.outputImage
        case .negativeVibrance:
            let vibrance = CIFilter.vibrance()
            vibrance.amount = -0.3
            vibrance.inputImage = image
            return vibrance.outputImage
//        case .four:
//            let temperatureAndTint = CIFilter.temperatureAndTint()
//            temperatureAndTint.neutral = CIVector.init(x: 5500, y: 0)
//            temperatureAndTint.targetNeutral = CIVector.init(x: 0, y: 0)
//            temperatureAndTint.inputImage = image
//            return temperatureAndTint.outputImage
        }
 
        
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
        let newImage = filter.outputImage?.cropped(to: originalImage.extent)
        
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
