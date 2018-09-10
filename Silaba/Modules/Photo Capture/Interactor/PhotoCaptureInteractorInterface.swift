//
//  PhotoCaptureInteractorInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 15/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol PhotoCaptureInteractorInterface: class {
    
    var output: PhotoCaptureInteractorOutput? { set get }
    var service: PlaceService! { set get }
    var machineLearningServices: MachineLearningService! { set get }
    var translatorService: TranslatorService! { set get }
    init(service: PlaceService, machineLearningService: MachineLearningService, translatorService: TranslatorService)
}
