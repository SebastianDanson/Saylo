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
    
    case blur, positiveVibrance, rosy, negativeVibrance
    
    var name: String {
        
        switch self {
        case .blur:
            return "bg blur"
        case .positiveVibrance:
            return "vibrant"
        case .negativeVibrance:
            return "mello"
        case .rosy:
            return "rosy"
        }
        
    }
    
    var imageName: String {
        
        switch self {
        case .blur:
            return "filterBackgroundBlurred"
        case .positiveVibrance:
            return "filterBackgroundPositiveVibrance"
        case .negativeVibrance:
            return "filterBackgroundNegativeVibrance"
        case .rosy:
            return "filterBackgroundRosy"
        }
    }
    
    static func getAvailableFilters() -> [Filter] {
            
        //The blur filter isn't available unless iOS 15 or later, so if not available add negative vibrance filter instead
        var filters = Filter.allCases.filter({$0 != Filter.blur })
        if #available(iOS 15.0, *){
            filters.insert(Filter.blur, at: 0)
        } 
        
        return filters
    }
    
    static func applyFilter(toImage image: CIImage, filter: Filter, sampleBuffer: CMSampleBuffer? = nil) -> CIImage? {
        
        switch filter {
            
        case .blur:
            return nil
        case .positiveVibrance:
            let vibrance = CIFilter.vibrance()
            vibrance.amount = 1
            vibrance.inputImage = image
            return vibrance.outputImage
        case .rosy:
            let rosy = CIFilter.colorMatrix()
            rosy.gVector = CIVector(x: 0, y: 0.6, z: 0, w: 0)
            rosy.inputImage = image
            return rosy.outputImage
        case .negativeVibrance:
            let vibrance = CIFilter.vibrance()
            vibrance.amount = -1
            vibrance.inputImage = image
            return vibrance.outputImage
        }
    }
}
    
   
