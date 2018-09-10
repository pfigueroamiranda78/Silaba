//
//  PhotoCaptureInteractorOutput.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 15/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import GPUImage
import Vision


protocol PhotoCaptureInteractorOutput: class {
    func photoCaptureDidReconigzed(with reconigzed: String, with confidence: Float, withSampleBuffer sampleBuffer: CMSampleBuffer)
    func photoCaptureDidFetchPlace(with result: PlaceServiceResult)
    func photoCaptureDidProcessMachineLearning(with mlresult: MachineLearningList?, with sample: CMSampleBuffer?)
    func photoCaptureDidFetchWikipedia(with reconigzed: String, with confidence: Float, with sample: CMSampleBuffer?, with searchResults: WikipediaSearchResults?, with error: WikipediaError?)
}

