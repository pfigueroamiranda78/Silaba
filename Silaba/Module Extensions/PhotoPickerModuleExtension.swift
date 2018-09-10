//
//  PhotoPickerModuleExtension.swift
//  Photostream
//
//  Created by Mounir Ybanez on 09/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import UIKit
import AVKit
import Photos
import AssetsLibrary


extension PhotoPickerModuleInterface {
    
    func didPickPhotoFromLibrary() {
        guard let presenter = self as? PhotoPickerPresenter else {
            return
        }
        
        let photoLibraryPresenter: PhotoLibraryPresenter? = presenter.wireframe.dependency()
        photoLibraryPresenter?.done()
    }
    

}

extension PhotoPickerPresenter: PhotoLibraryModuleDelegate {
    func photoLibraryDidPick(with playerItem: AVPlayerItem?, with machineLearningList: MachineLearningList) {
        guard let presenter = self as? PhotoPickerPresenter else {
            return
        }
        presenter.interactor.fetchTalentAll()
         self.moduleDelegate?.videoPickerDidFinish(with: playerItem, with: machineLearningList)
    }
    
    func photoLibraryDidPick(with image: UIImage?, with machineLearningList: MachineLearningList) {
        guard let presenter = self as? PhotoPickerPresenter else {
            return
        }
        presenter.interactor.fetchTalentAll()
        self.moduleDelegate?.photoPickerDidFinish(with: image, with: machineLearningList)
    }
    
    func photoLibraryDidCancel() {
        print("Photo Picker: did cancel")
    }
    

}

extension PhotoPickerPresenter: PhotoCaptureModuleDelegate {

    func photoAsSampleBuffer(with recognized: MachineLearningList) {
        moduleDelegate?.photoAsSampleBuffer(with: recognized)
    }
    
    func photoCaptureDidFinish(with image: UIImage?) {
        guard let presenter = self as? PhotoPickerPresenter else {
            return
        }
        
        presenter.interactor.fetchTalentAll()
        moduleDelegate?.photoPickerDidFinish(with: image, with: nil)
    }
    
    func photoCaptureDidCanel() {
        print("Photo Picker: did cancel capture")
    }
}

extension PhotoPickerPresenter: VideoCaptureModuleDelegate {
    
    func videoAsSampleBuffer(with recognized: MachineLearningList) {
        moduleDelegate?.photoAsSampleBuffer(with: recognized)
    }
    
    
    func videoCaptureDidFinish(with video: AVPlayerItem?) {
        guard let presenter = self as? PhotoPickerPresenter else {
            return
        }
        
        presenter.interactor.fetchTalentAll()
        moduleDelegate?.videoPickerDidFinish(with: video, with: nil)
    }
    
    func videoCaptureDidCancel() {
        print("Video Picker: did cancel capture")
    }
    
    func videoDidCapture(with url: NSURL) {
        guard let presenter = self as? PhotoPickerPresenter else {
            return
        }
        
        let photoLibraryPresenter: PhotoLibraryPresenter? = presenter.wireframe.dependency()
        let playerItem = AVPlayerItem(url: url as URL)
        photoLibraryPresenter?.view.setSelectedAsset(with: playerItem)
    }
}

extension PhotoPickerWireframeInterface {
    
    func showPhotoShare(from navigationController: UINavigationController?, with image: UIImage, delegate: PhotoShareModuleDelegate) {
        let vc = PhotoShareWireframe.createViewController()
        vc.image = image
        let wireframe = PhotoShareWireframe(root: root, delegate: delegate, view: vc)
        wireframe.push(with: vc, from: navigationController)
    }
}

extension PhotoPickerWireframe {
    
    class func createViewController() -> PhotoPickerViewController {
        let sb = UIStoryboard(name: "PhotoPickerModuleStoryboard", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "PhotoPickerViewController")
        return vc as! PhotoPickerViewController
    }
    
    class func createNavigationController() -> UINavigationController {
        let sb = UIStoryboard(name: "PhotoPickerModuleStoryboard", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "PhotoPickerNavigationController")
        return vc as! UINavigationController
    }
}
