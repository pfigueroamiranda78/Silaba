//
//  VideoCaptureInteractorOutput.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 11/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import GPUImage
import Vision


protocol VideoCaptureInteractorOutput: class {
    func videoCaptureDidReconigzed(with reconigzed: String, with confidence: Float, withSampleBuffer sampleBuffer: CMSampleBuffer)
    func videoCaptureDidFetchPlace(with result: PlaceServiceResult)
    func videoCaptureDidProcessMachineLearning(with mlresult: MachineLearningList?, with sample: CMSampleBuffer?)
    func videoCaptureDidFetchWikipedia(with reconigzed: String, with confidence: Float, with sample: CMSampleBuffer?, with searchResults: WikipediaSearchResults?, with error: WikipediaError?)
}

