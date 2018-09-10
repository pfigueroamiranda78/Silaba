//
//  PhotoPickerDiscoveryModuleInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 20/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit
import AVKit

extension PhotoPickerDiscoveryModuleInterface {
    
    func didPickPhotoFromLibrary(withTalent talent: Talent) {
        guard let presenter = self as? PhotoPickerDiscoveryPresenter else {
            return
        }
        
        let photoLibraryPresenter: PhotoLibraryPresenter? = presenter.wireframe.dependency()
        photoLibraryPresenter?.done()
    }
    
}

extension PhotoPickerDiscoveryPresenter: PhotoLibraryModuleDelegate {
    
    func photoLibraryDidPick(with playerItem: AVPlayerItem?, with machineLearningList: MachineLearningList) {
    
    }
    
    
    func photoLibraryDidPick(with image: UIImage?, with machineLearningList: MachineLearningList) {
        
        self.moduleDelegate?.photoPickerDiscoveryDidFinish(with: image, with: machineLearningList)
    }
    
    func photoLibraryDidCancel() {
        print("Photo Picker: did cancel")
    }
}

extension PhotoPickerDiscoveryPresenter: PhotoCaptureModuleDelegate {

    func photoAsSampleBuffer(with recognized: MachineLearningList) {
        moduleDelegate?.photoDiscoveryAsSampleBuffer(with: recognized)
    }
    
    func photoCaptureDidFinish(with image: UIImage?) {
        moduleDelegate?.photoPickerDiscoveryDidFinish(with: image, with: nil)
    }
    
    func photoCaptureDidCanel() {
        print("Photo Picker: did cancel capture")
    }
}

extension PhotoPickerDiscoveryPresenter: VideoCaptureModuleDelegate {
    func videoDidCapture(with url: NSURL) {
        
    }
    
    func videoCaptureDidFinish(with video: AVPlayerItem?) {
         moduleDelegate?.photoPickerDiscoveryDidFinish(with: video, with: nil)
    }
    
    func videoAsSampleBuffer(with recognized: MachineLearningList) {
        moduleDelegate?.photoDiscoveryAsSampleBuffer(with: recognized)
    }
    
    func videoCaptureDidCancel() {
        print("Photo Picker: did cancel capture")
    }
}

extension PhotoPickerDiscoveryWireframeInterface {
    
    func showPhotoShare(from navigationController: UINavigationController?, with image: UIImage, delegate: PhotoShareModuleDelegate) {
        let vc = PhotoShareWireframe.createViewController()
        vc.image = image
        let wireframe = PhotoShareWireframe(root: root, delegate: delegate, view: vc)
        wireframe.push(with: vc, from: navigationController)
    }
}

extension PhotoPickerDiscoveryWireframe {
    
    class func createViewController() -> PhotoPickerDiscoveryViewController {
        let sb = UIStoryboard(name: "PhotoPickerDiscoveryModuleStoryboard", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "PhotoPickerDiscoveryViewController")
        return vc as! PhotoPickerDiscoveryViewController
    }
    
    class func createNavigationController() -> UINavigationController {
        let sb = UIStoryboard(name: "PhotoPickerDiscoveryModuleStoryboard", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "PhotoPickerDiscoveryNavigationController")
        return vc as! UINavigationController
    }
}

