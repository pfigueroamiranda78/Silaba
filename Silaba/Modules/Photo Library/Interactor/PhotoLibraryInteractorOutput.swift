//
//  PhotoLibraryInteractorOutput.swift
//  Photostream
//
//  Created by Mounir Ybanez on 11/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import Photos

protocol PhotoLibraryInteractorOutput: class {

    func photoLibraryDidFetchPhotos(with assets: [PHAsset])
    func photoLibraryDidReconigzed(with reconigzed: String, with confidence: Float)
    func photoLibraryDidFetchPlace(with result: PlaceServiceResult?)
    func photoLibraryDidProcessMachineLearning(with mlresult: MachineLearningList?)
    func photoLibraryDidFetchWikipedia(with reconigzed: String, with confidence: Float, with searchResults: WikipediaSearchResults?, with error: WikipediaError?)
}
