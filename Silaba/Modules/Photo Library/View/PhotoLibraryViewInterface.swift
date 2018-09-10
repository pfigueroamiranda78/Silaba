//
//  PhotoLibraryViewInterface.swift
//  Photostream
//
//  Created by Mounir Ybanez on 11/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import UIKit
import AVKit
import Photos

protocol PhotoLibraryViewInterface: class {

    var controller: UIViewController? { get }
    var presenter: PhotoLibraryModuleInterface! { set get }
    
    func reloadView()
    func didFetchPhotos()
    func setSelectedAsset(with asset: PHAsset)
    func getSelectedAsset()->PHAsset
    func setSelectedAsset(with playerItem: AVPlayerItem)
    func getSelectedItemPlayer()->AVPlayerItem?
    func showSelectedPhoto(with image: UIImage?)
    func showSelectedPhotoInFillMode(animated: Bool)
    func showSelectedPhotoInFitMode(animated: Bool)
    func showrecognizedText(with recognizedText: String?)
    func showwikipediaText(with text: String?)
    func showBannerText(with text:String?)
}
