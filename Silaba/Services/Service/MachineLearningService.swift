//
//  YouTubeService.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 22/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol MachineLearningService {
    init(with useModel: String)
    
    func Clasificate(data: MachineLearningServicePhotoSearchData, callback: ((MachineLearningServiceResult)-> Void)?)
    func theModel(tModel: String)
    
}


struct MachineLearningServicePhotoSearchData {
    var searchPhoto: Data?
    var sampleBuffer: CMSampleBuffer?
   // var useModel: String
}

struct MachineLearningServiceResult {
    
    var machineLearningList: MachineLearningList?
    var success: Bool?
    var error: MachineLearningServiceError?
}

enum MachineLearningServiceError: Error {
    case notLoadImage(message: String)
    case notLearningModel(message: String)
    case notReconized(message: String)
    var message: String {
        switch self {
        case .notLearningModel(let message),
             .notLoadImage(let message),
             .notReconized(let message):
            return message
        }
    }
}
