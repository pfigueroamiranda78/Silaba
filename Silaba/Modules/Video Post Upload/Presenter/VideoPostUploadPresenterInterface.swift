//
//  VideoPostUploadPresenterInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/07/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation


protocol VideoPostUploadPresenterInterface: class {
    
    var interactor: VideoPostUploadInteractorInput! { set get }
    var view: VideoPostUploadViewInterface! { set get }
    var wireframe: VideoPostUploadWireframeInterface! { set get }
    var moduleDelegate: VideoPostUploadModuleDelegate? { set get }
    var item: VideoPostUploadItem! { set get }
}
