//
//  PhotoLibraryInteractor.swift
//  Photostream
//
//  Created by Mounir Ybanez on 11/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import Photos
import Crashlytics

class PhotoLibraryInteractor: PhotoLibraryInteractorInterface {
    
    weak var output: PhotoLibraryInteractorOutput?
    var service: AssetService!
    var placeService: PlaceService!
    var machineLearningService: MachineLearningService!
    var translatorService: TranslatorService!
    required init(service: AssetService, placeService: PlaceService, machineLearningService: MachineLearningService, translatorService: TranslatorService) {
        self.service = service
        self.placeService = placeService
        self.service.observer = self
        self.machineLearningService = machineLearningService
        self.translatorService = translatorService
    }
}

extension PhotoLibraryInteractor: PhotoLibraryInteractorInput {
    
    
    func fecthRecognized(with recognized: String?, with confidence: Float) {
        self.output?.photoLibraryDidReconigzed(with: recognized!, with: confidence)
    }
    
    func fetchPlaceInfo(id: String) {
        placeService.fetchPlaceInfo(id: id) { (placeResult) in
            self.output?.photoLibraryDidFetchPlace(with: placeResult)
        }
    }
    
    func processMachineLearning(withImage image:UIImage?, withSampleBuffer sampleBuffer: CMSampleBuffer?, withType type:String) {
        var dataImage:Data?
        var machineLearningList = MachineLearningList()
        
        if (image != nil) {
            dataImage = UIImageJPEGRepresentation(image!, 1)
        } else {
            Crashlytics.sharedInstance().setObjectValue(image, forKey: "ImageLibrary")
            return
        }
        
        if (dataImage == nil) {
            Crashlytics.sharedInstance().setObjectValue(dataImage, forKey: "ImageDataLibrary")
            return
        }
        
        let machineLearningServicesPhotoSearchData = MachineLearningServicePhotoSearchData(searchPhoto: dataImage, sampleBuffer: sampleBuffer)
        machineLearningService.theModel(tModel: type)
        machineLearningService.Clasificate(data: machineLearningServicesPhotoSearchData) { (mlresult) in
            guard mlresult.error == nil else { return }
            var machineLearning1 = MachineLearning()
            var machineLearning2 = MachineLearning()
            
            let translateSearchData0 = TranslateSearchData (source: "en", target: "es", text: (mlresult.machineLearningList![0]?.identifier)!, text2: (mlresult.machineLearningList![1]?.identifier)!)
            self.translatorService.translate(inputData: translateSearchData0) { (translateServiceResult) in
                machineLearning1.identifier = (mlresult.machineLearningList![0]?.identifier)!
                machineLearning1.confidence = (mlresult.machineLearningList![0]?.confidence)!
                machineLearning1.model = (mlresult.machineLearningList![0]?.model)!
                machineLearning2.identifier = (mlresult.machineLearningList![1]?.identifier)!
                machineLearning2.confidence = (mlresult.machineLearningList![1]?.confidence)!
                machineLearning2.model = (mlresult.machineLearningList![1]?.model)!
                
                if (translateServiceResult.error != nil) {
                    machineLearning1.identificador = machineLearning1.identifier.replaceFirstOccurrence(of: "\"", to: "")
                    machineLearning2.identificador = machineLearning2.identifier.replaceFirstOccurrence(of: "\"", to: "")
                } else {
                    machineLearning1.identificador = translateServiceResult.translated!.replaceFirstOccurrence(of: "\"", to: "")
                    machineLearning2.identificador = translateServiceResult.translated2!.replaceFirstOccurrence(of: "\"", to: "")
                }
                machineLearningList.machineLearningList.append(machineLearning1)
                machineLearningList.machineLearningList.append(machineLearning2)
                self.output?.photoLibraryDidProcessMachineLearning(with: machineLearningList)
            }
        }
    }
    
    func fetchWikipedia(with recognized:String?, with confidence:Float) {
        WikipediaNetworking.appAuthorEmailForAPI = "pedro.figueroa@silaba.org"
        let language_wikipedia = WikipediaLanguage("es")
        
        _ = Wikipedia.shared.requestOptimizedSearchResults(language: language_wikipedia, term: recognized!) { (searchResults, error) in
            guard error == nil else {
                self.output?.photoLibraryDidFetchWikipedia(with: recognized!, with: confidence, with: searchResults, with: error)
                return
            }
            guard let searchResults = searchResults else {
                self.output?.photoLibraryDidFetchWikipedia(with: recognized!, with: confidence, with: nil, with: error)
                return
            }
            self.output?.photoLibraryDidFetchWikipedia(with: recognized!, with: confidence, with: searchResults, with: error)
        }
    }
   
    func fetchPhotos() {
        service.fetchImageAndVideoAssets { (assets) in
            self.output?.photoLibraryDidFetchPhotos(with: assets)
        }
    }
    
    func fetchVideos() {
        service.fetchVideoAssets { (assets) in
            self.output?.photoLibraryDidFetchPhotos(with: assets)
        }
    }
    
    func fetchPhoto(for data: AssetRequestData, completion: ((UIImage?) -> Void)?) {
        service.fetchImage(for: data) { (image) in
            completion?(image)
        }
    }
    
    func fetchVideo(for data: AssetRequestData, completion: ((AVPlayerItem?) -> Void)?) {
        service.fetchVideo(for: data) { (playerItem) in
            completion?(playerItem)
        }
    }
}

extension PhotoLibraryInteractor: AssetServiceObserver {
    
    func assetServiceDidChange(assets: [PHAsset]) {
        output?.photoLibraryDidFetchPhotos(with: assets)
    }
}
