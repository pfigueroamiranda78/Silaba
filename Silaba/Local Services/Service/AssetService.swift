//
//  AssetService.swift
//  Photostream
//
//  Created by Mounir Ybanez on 11/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import Foundation
import Photos

protocol AssetServiceObserver: class {
    
    func assetServiceDidChange(assets: [PHAsset])
}

protocol AssetService: class {
    
    var observer: AssetServiceObserver? { set get }
    
    func fetchImageAssets(with options: PHFetchOptions?, completion: (([PHAsset]) -> Void)?)
    func fetchImage(for data: AssetRequestData, completion: ((UIImage?) -> Void)?)
    func fetchImageAndVideoAssets(with options: PHFetchOptions?, completion: (([PHAsset]) -> Void)?)
    func fetchVideoAssets(with options: PHFetchOptions?, completion: (([PHAsset]) -> Void)?)
    func fetchVideo(for data: AssetRequestData, completion: ((AVPlayerItem?) -> Void)?)
}

extension AssetService {

    func fetchVideoAssets(completion: (([PHAsset]) -> Void)?) {
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        fetchVideoAssets(with: options, completion: completion)
    }
    
    func fetchImageAssets(completion: (([PHAsset]) -> Void)?) {
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        fetchImageAssets(with: options, completion: completion)
    }
    
    func fetchImageAndVideoAssets(completion: (([PHAsset]) -> Void)?) {
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        fetchImageAndVideoAssets(with: options, completion: completion)
    }
}

struct AssetRequestData {
    
    var asset: PHAsset?
    var size: CGSize
    var mode: PHImageContentMode
    var options: PHImageRequestOptions?
    
    init() {
        size = .zero
        mode = .default
    }
}
