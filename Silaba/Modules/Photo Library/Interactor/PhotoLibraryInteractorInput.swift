//
//  PhotoLibraryInteractorInput.swift
//  Photostream
//
//  Created by Mounir Ybanez on 11/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import UIKit
import UIKit
import GPUImage

protocol PhotoLibraryInteractorInput: class {

    func fetchPhotos()
    func fetchVideos()
    func fetchPhoto(for data: AssetRequestData, completion: ((UIImage?) -> Void)?)
    func fetchVideo(for data: AssetRequestData, completion: ((AVPlayerItem?) -> Void)?)
    func fetchPlaceInfo(id: String)
    func processMachineLearning(withImage image:UIImage?, withSampleBuffer sampleBuffer: CMSampleBuffer?, withType type:String)
    func fetchWikipedia(with recognized:String?, with confidence:Float)
    func fecthRecognized(with recognized:String?, with confidence:Float)
}
