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
    
    case blur, one, two, three, four
    
    var name: String {
        
        switch self {
        case .blur:
            return "blur"
        case .one:
            return "one"
        case .two:
            return "two"
        case .three:
            return "three"
        case .four:
            return "four"
        }
        
    }
    
    var defaultImage: UIImage? {
//        switch self {
//        case .blur:
//        let uiimage = UIImage(named: IS_SMALL_PHONE ? "filterBackgroundSmall" : "filterBackgroundLarge")
//        let inputImage = CIImage(image: uiimage!)
//        print("ciimage1", applyFilter(toImage: inputImage!, filter: .one))
//        print("ciimage2", applyFilter(toImage: inputImage!, filter: .two))
//        print("ciimage3", applyFilter(toImage: inputImage!, filter: .three))
//        print("ciimage4", applyFilter(toImage: inputImage!, filter: .four))

        guard let uiimage = UIImage(named: IS_SMALL_PHONE ? "filterBackgroundSmall" : "filterBackgroundLarge"),
              let inputImage = CIImage(image: uiimage),
              let ciimage = applyFilter(toImage: inputImage, filter: .one) else {return nil}
        
        return UIImage(ciImage: ciimage)
        
//        case .one:
//            <#code#>
//        case .two:
//            <#code#>
//        case .three:
//            <#code#>
//        case .four:
//            <#code#>
//        }
    }
    
    func applyFilter(toImage image: CIImage, filter: Filter, sampleBuffer: CMSampleBuffer? = nil) -> CIImage? {
        
        switch filter {
            
        case .blur:
           return applyBlurFilter(sampleBuffer: sampleBuffer)
        case .one:
            let vibrance = CIFilter.vibrance()
            vibrance.amount = -0.8
            vibrance.inputImage = image
            return vibrance.outputImage
        case .two:
            let gamma = CIFilter.gammaAdjust()
            gamma.power = 0.8
            gamma.inputImage = image
            return gamma.outputImage
        case .three:
            let colorControls = CIFilter.colorControls()
            colorControls.brightness = 0
            colorControls.contrast = 0.95
            colorControls.saturation = 1.2
            colorControls.inputImage = image
            return colorControls.outputImage
        case .four:
            let temperatureAndTint = CIFilter.temperatureAndTint()
            temperatureAndTint.neutral = CIVector.init(x: 5500, y: 0)
            temperatureAndTint.targetNeutral = CIVector.init(x: 0, y: 0)
            temperatureAndTint.inputImage = image
            return temperatureAndTint.outputImage
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
    
    
    private func applyBlurFilter(sampleBuffer: CMSampleBuffer?) -> CIImage? {
        
        
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
                                            orientation: .right)
        
        guard let resultPixelBuffer = personSegmentationRequest.results?.first?.pixelBuffer else { return nil }
        
        let originalImage = CIImage(cvPixelBuffer: sampleBuffer.imageBuffer!)

        var maskImage = CIImage(cvPixelBuffer: resultPixelBuffer).oriented(.left)
        
        let maxcomp = CIFilter.maximumComponent()
        maxcomp.inputImage = originalImage
        
        
        let filter = CIFilter.gaussianBlur()
        filter.radius = 10
        filter.inputImage = originalImage
        let newImage = filter.outputImage
        
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
