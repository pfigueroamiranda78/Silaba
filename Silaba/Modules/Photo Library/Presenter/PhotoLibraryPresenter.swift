//
//  PhotoLibraryPresenter.swift
//  Photostream
//
//  Created by Mounir Ybanez on 11/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import Photos

class PhotoLibraryPresenter: PhotoLibraryPresenterInterface {

    weak var view: PhotoLibraryViewInterface!
    weak var moduleDelegate: PhotoLibraryModuleDelegate?
    weak var cropper: PhotoCropper!
    
    var wireframe: PhotoLibraryWireframeInterface!
    var interactor: PhotoLibraryInteractorInput!
    var photos = [PHAsset]()
    var contentMode: PhotoContentMode = .fill(false) {
        didSet {
            switch contentMode {
            case .fill(let animated):
                view.showSelectedPhotoInFillMode(animated: animated)
            case.fit(let animated):
                view.showSelectedPhotoInFitMode(animated: animated)
            }
        }
    }
   
    var recognized_type: String = "objeto"
    var definitlymachineLearningList: MachineLearningList!
}

extension PhotoLibraryPresenter: PhotoLibraryModuleInterface {
    
    
    func fetchVideo(with asset: PHAsset, callback: ((AVPlayerItem?) -> Void)?) {
        var data = AssetRequestData()
        data.asset = asset
        data.mode = .aspectFit
        
        interactor.fetchVideo(for: data) { (playerItem) in
            DispatchQueue.main.async {
                 callback?(playerItem)
            }
        }
    }
    
    
    func setReconigzedType(with recognized_type: String) {
        self.recognized_type = recognized_type
    }
    
    
    var photoCount: Int {
        return photos.count
    }
    
    func fetchPhotos() {
        interactor.fetchPhotos()
    }

    func fetchVideos() {
        interactor.fetchVideos()
    }
 

    func photo(at index: Int) -> PHAsset? {
        guard photos.isValid(index) else {
            return nil
        }
        
        return photos[index]
    }
    
    
    
    func willShowSelectedPhoto(at index: Int, size: CGSize) {
        guard let asset = photo(at: index) else {
            self.view.showSelectedPhoto(with: nil)
            return
        }
        
        var data = AssetRequestData()
        data.asset = asset
        data.size = size
        data.mode = .aspectFit
       
        interactor.fetchPhoto(for: data) { (image) in
            self.view.showSelectedPhoto(with: image)
            self.view.setSelectedAsset(with: asset)
            self.interactor.processMachineLearning(withImage: image, withSampleBuffer: nil, withType: self.recognized_type)
        }
    
        
    }
    
    func fetchThumbnail(at index: Int, size: CGSize, completion: ((UIImage?) -> Void)?) {
        guard let asset = photo(at: index) else {
            completion?(nil)
            return
        }
        
        var data = AssetRequestData()
        data.asset = asset
        data.size = size
        
        interactor.fetchPhoto(for: data) { (image) in
            completion?(image)
        }
    }
    
    func set(photoCropper: PhotoCropper) {
        cropper = photoCropper
    }
    
    func cancel() {
        moduleDelegate?.photoLibraryDidCancel()
    }
    
    
    func done(withTalent talent:Talent) {
        if definitlymachineLearningList == nil {
            return
        }
        moduleDelegate?.photoLibraryDidPick(with: cropper.image, with: definitlymachineLearningList)
    }
    
    
    func done() {
        if definitlymachineLearningList == nil {
            return
        }
        
        let selectedAsset = view.getSelectedAsset()
        if selectedAsset.mediaType == .video {
            
            self.fetchVideo(with: selectedAsset) { (avplayerItem) in
                self.moduleDelegate?.photoLibraryDidPick(with: avplayerItem, with: self.definitlymachineLearningList)
            }
            
        } else {
            let selectedPlayerItem = view.getSelectedItemPlayer()
           
            if selectedPlayerItem != nil {
                self.moduleDelegate?.photoLibraryDidPick(with: selectedPlayerItem, with: self.definitlymachineLearningList)
            } else {
                moduleDelegate?.photoLibraryDidPick(with: cropper.image, with: definitlymachineLearningList)
            }
        }
    }
    
    func fillSelectedPhoto(animated: Bool) {
        contentMode = .fill(animated)
    }
    
    func fitSelectedPhoto(animated: Bool) {
        contentMode = .fit(animated)
    }
    
    func toggleContentMode(animated: Bool) {
        switch contentMode {
        case .fill:
            contentMode = .fit(animated)
        case .fit:
            contentMode = .fill(animated)
        }
    }
    
    func dismiss(animated: Bool) {
        wireframe.dismiss(with: view.controller)
    }
}

extension PhotoLibraryPresenter: PhotoLibraryInteractorOutput {
    func photoLibraryDidReconigzed(with reconigzed: String, with confidence: Float) {
        let recognized_text: String = self.recognized_type+": "+reconigzed+" en un \(confidence.round(digit: 2)  )%"
        self.view.showrecognizedText(with: recognized_text)
    }
    
    func photoLibraryDidProcessMachineLearning(with mlresult: MachineLearningList?) {
        guard mlresult?.count != 0 else {
            self.view.showrecognizedText(with: "")
            return
        }
        let recognized = mlresult?.mejorIdenficador
        let confidence = mlresult?.bestConfidence
        self.definitlymachineLearningList = mlresult
        self.interactor.fetchPlaceInfo(id: recognized!)
        self.interactor.fetchWikipedia(with: recognized!, with: confidence!)
        
    }
    
    func photoLibraryDidFetchWikipedia(with reconigzed: String, with confidence: Float, with searchResults: WikipediaSearchResults?, with error: WikipediaError?) {
        var wikiresult: String = "wikipedia: "
        
        guard error == nil else {
            photoLibraryDidReconigzed(with: reconigzed, with: confidence)
            view.showwikipediaText(with: "No tienes conexión a internet o el sitio de Wikipedia no se encuentra disponible")
            return
        }
        
        for articlePreview in (searchResults?.results)! {
            print(articlePreview.displayTitle)
            wikiresult.append(articlePreview.displayTitle)
            wikiresult.append(": ")
            wikiresult.append(articlePreview.displayText)
        }
        photoLibraryDidReconigzed(with: reconigzed, with: confidence)
        self.view.showwikipediaText(with: wikiresult)
    }

    
    
    func photoLibraryDidFetchPlace(with result: PlaceServiceResult?) {
        guard result?.error == nil else {
            view.showBannerText(with: "")
            return
        }
        view.showBannerText(with: (result?.place?.banner)!)
    }
    

    func photoLibraryDidFetchPhotos(with assets: [PHAsset]) {
        photos.removeAll()
        photos.append(contentsOf: assets)
        view.didFetchPhotos()
    }
}
