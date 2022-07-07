//
//  FilterRenderer.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-06-28.
//

import CoreMedia

protocol FilterRenderer: class {
        
    var isPrepared: Bool { get }
    
    // Prepare resources.
    func prepare(with inputFormatDescription: CMFormatDescription, outputRetainedBufferCountHint: Int)
    
    // Release resources.
    func reset()
    
    // The format description of the output pixel buffers.
    var outputFormatDescription: CMFormatDescription? { get }
    
    // The format description of the input pixel buffers.
    var inputFormatDescription: CMFormatDescription? { get }
    
    // Render the pixel buffer.
    func render(pixelBuffer: CVPixelBuffer) -> CVPixelBuffer?
    
}
