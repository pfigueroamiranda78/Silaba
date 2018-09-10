//
//  PhotoPickerPresenter.swift
//  Photostream
//
//  Created by Mounir Ybanez on 09/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import UIKit

class PhotoPickerPresenter: PhotoPickerPresenterInterface {
    
    weak var moduleDelegate: PhotoPickerModuleDelegate?
    weak var view: PhotoPickerViewInterface!
    var wireframe: PhotoPickerWireframeInterface!
    var interactor: PhotoPickerInteractorInput!
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
                view.showVideoCamera()
            case .unknown:
                break
            }
        }
    }
}

extension PhotoPickerPresenter: PhotoPickerModuleInterface {
    
    func cancel() {
        moduleDelegate?.photoPickerDidCancel()
    }
    
    func willShowCamera() {
        source = .camera
    }
    
    func willShowVideoCamera() {
        source = .videocamera
    }
    
    func willShowLibrary() {
        source = .library
    }
    
    func dismiss(animated: Bool) {
        wireframe.dismiss(with: view.controller, animated: animated, completion: nil)
    }
}

extension PhotoPickerPresenter: PhotoPickerInteractorOutput {
    func photoPickerDidFetchTalent(with result: TalentServiceResult) {
        moduleDelegate?.photoPickerSetTalent(with: result.talents!)
    }
    
    func photoPickerDidFetchThing(with result: ThingServiceResult) {
        moduleDelegate?.photoPickerSetThing(with: result.things!)
    }
    
    func photoPickerDidiFecthFollowing(with result: UserServiceFollowListResult) {
         moduleDelegate?.photoPickerSetFollow(with: result.users!)
    }

}
