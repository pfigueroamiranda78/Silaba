//
//  VideoCaptureInteractorInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 11/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol VideoCaptureInteractorInterface: class {
    
    var output: VideoCaptureInteractorOutput? { set get }
    var service: PlaceService! { set get }
    var machineLearningServices: MachineLearningService! { set get }
    var translatorService: TranslatorService! { set get }
    init(service: PlaceService, machineLearningService: MachineLearningService, translatorService: TranslatorService)
}
