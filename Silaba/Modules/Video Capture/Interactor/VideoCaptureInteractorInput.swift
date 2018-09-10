//
//  VideoCaptureInteractorInput.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 11/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit
import GPUImage

protocol VideoCaptureInteractorInput: class {
    
    func fetchPlaceInfo(id: String)
    func processMachineLearning(withImage image:UIImage?, withSampleBuffer sampleBuffer: CMSampleBuffer?, withType type:String)
    func fetchWikipedia(with recognized:String?, with confidence:Float, withSampleBuffer sampleBuffer: CMSampleBuffer)
    func fecthRecognized(with recognized:String?, with confidence:Float, withSampleBuffer sampleBuffer: CMSampleBuffer)
    
}
