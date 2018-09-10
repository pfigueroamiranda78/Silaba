//
//  PhotoPickerDiscoveryPresenter.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 20/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit

class PhotoPickerDiscoveryPresenter: PhotoPickerDiscoveryPresenterInterface {
    
    weak var moduleDelegate: PhotoPickerDiscoveryModuleDelegate?
    weak var view: PhotoPickerDiscoveryViewInterface!
    var wireframe: PhotoPickerDiscoveryWireframeInterface!
     var interactor: PhotoPickerDiscoveryInteractorInput!
    var source: PhotoSource = .unknown {
        didSet {
            guard source != oldValue else {
                return
            }
            
            switch source {
            case .library:
                view.showLibrary()
            case .camera:
                view.showCamera()
            case .videocamera:
                view.showCamera()
            case .unknown:
                break
            }
        }
    }
    var talent: Talent!
}

extension PhotoPickerDiscoveryPresenter: PhotoPickerDiscoveryModuleInterface {
    
    func cancel() {
        moduleDelegate?.photoPickerDiscoveryDidCancel()
    }
    
    func willShowCamera() {
        source = .camera
    }
    
    func willShowLibrary() {
        source = .library
    }
    
    func dismiss(animated: Bool) {
        wireframe.dismiss(with: view.controller, animated: animated, completion: nil)
    }
}

extension PhotoPickerDiscoveryPresenter: PhotoPickerDiscoveryInteractorOutput {
    func photoPickerDiscoveryDidFetchTalent(with result: TalentServiceResult) {
        moduleDelegate?.photoPickerSetTalent(with: result.talents!)
    }
    
}
