//
//  CMSampleBuffer+Extensions.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 6/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import GPUImage

extension CMSampleBuffer {
    
    func image() -> UIImage? {
        let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(self)!
        let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
        let image : UIImage = self.convert(cmage: ciimage)
        return image
    }
    
    func imageExtend() -> UIImage? {
        let context = CIContext()
        guard let imageBuffer = CMSampleBufferGetImageBuffer(self) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    // Convert CIImage to CGImage
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
}
