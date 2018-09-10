//
//  PhotoCaptureInteractor.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 15/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit
import GPUImage


class PhotoCaptureInteractor: PhotoCaptureInteractorInterface {
   
    weak var output: PhotoCaptureInteractorOutput?
    var service: PlaceService!
    var machineLearningServices: MachineLearningService!
    var translatorService: TranslatorService!
    private var lastRecognized:String = ""
    
    required init(service: PlaceService, machineLearningService: MachineLearningService, translatorService: TranslatorService) {
        self.service = service
        self.machineLearningServices = machineLearningService
        self.translatorService = translatorService
    }
}

extension PhotoCaptureInteractor: PhotoCaptureInteractorInput {

    
    
    
    func fecthRecognized(with recognized: String?, with confidence: Float, withSampleBuffer sampleBuffer: CMSampleBuffer) {
        self.output?.photoCaptureDidReconigzed(with: recognized!, with: confidence, withSampleBuffer: sampleBuffer)
    }
    
    
    func fetchPlaceInfo(id: String) {
        service.fetchPlaceInfo(id: id) { (placeResult) in
             self.output?.photoCaptureDidFetchPlace(with: placeResult)
        }
    }
    
    func processMachineLearning(withImage image:UIImage?, withSampleBuffer sampleBuffer: CMSampleBuffer?, withType type:String) {
        var dataImage:Data?
        var machineLearningList = MachineLearningList()
            
        if (image != nil) {
            dataImage = UIImageJPEGRepresentation(image!, 1)
        }
       
        let machineLearningServicesPhotoSearchData = MachineLearningServicePhotoSearchData(searchPhoto: dataImage, sampleBuffer: sampleBuffer)
        machineLearningServices.theModel(tModel: type)
        machineLearningServices.Clasificate(data: machineLearningServicesPhotoSearchData) { (mlresult) in
            guard mlresult.error == nil else { return }
            
            // Si reconoce por debajo del 40% no lo tiene en cuenta para evitar uso de datos.
            
            if ((mlresult.machineLearningList![0]?.confidence)! < 0.20) {
                return
            }
            
            // Si reconoce lo mismo del anterior, no lo procesa para evitar uso de datos
            
            if ((mlresult.machineLearningList![0]?.identifier) == self.lastRecognized) {
                return
            }
            
            var machineLearning1 = MachineLearning()
            var machineLearning2 = MachineLearning()
            
            let translateSearchData0 = TranslateSearchData (source: "en", target: "es", text: (mlresult.machineLearningList![0]?.identifier)!, text2: (mlresult.machineLearningList![1]?.identifier)!)
            self.translatorService.translate(inputData: translateSearchData0) { (translateServiceResult) in
                self.lastRecognized = (mlresult.machineLearningList![0]?.identifier)!
                machineLearning1.identifier = (mlresult.machineLearningList![0]?.identifier)!
                machineLearning1.confidence = (mlresult.machineLearningList![0]?.confidence)!
                machineLearning1.model = (mlresult.machineLearningList![0]?.model)!
                machineLearning2.identifier = (mlresult.machineLearningList![1]?.identifier)!
                machineLearning2.confidence = (mlresult.machineLearningList![1]?.confidence)!
                machineLearning1.model = (mlresult.machineLearningList![0]?.model)!
                
                if (translateServiceResult.error != nil) {
                    machineLearning1.identificador = machineLearning1.identifier.replaceFirstOccurrence(of: "\"", to: "")
                    machineLearning2.identificador = machineLearning2.identifier.replaceFirstOccurrence(of: "\"", to: "")
                } else {
                    machineLearning1.identificador = translateServiceResult.translated!.replaceFirstOccurrence(of: "\"", to: "")
                    machineLearning2.identificador = translateServiceResult.translated2!.replaceFirstOccurrence(of: "\"", to: "")
                }
                machineLearningList.machineLearningList.append(machineLearning1)
                machineLearningList.machineLearningList.append(machineLearning2)
                self.output?.photoCaptureDidProcessMachineLearning(with: machineLearningList, with: sampleBuffer)
            }
        }
    }
    
       func fetchWikipedia(with recognized: String?, with confidence: Float, withSampleBuffer sampleBuffer: CMSampleBuffer) {
        WikipediaNetworking.appAuthorEmailForAPI = "pedro.figueroa@silaba.org"
        let language_wikipedia = WikipediaLanguage("es")
        
        _ = Wikipedia.shared.requestOptimizedSearchResults(language: language_wikipedia, term: recognized!) { (searchResults, error) in
            guard error == nil else {
                self.output?.photoCaptureDidFetchWikipedia(with: recognized!, with: confidence, with: sampleBuffer, with: searchResults, with: error)
                return
            }
            guard let searchResults = searchResults else {
                self.output?.photoCaptureDidFetchWikipedia(with: recognized!, with: confidence,with: sampleBuffer, with: nil, with: error)
                return
            }
            self.output?.photoCaptureDidFetchWikipedia(with: recognized!, with: confidence, with: sampleBuffer, with: searchResults, with: error)
        }
    }
}
