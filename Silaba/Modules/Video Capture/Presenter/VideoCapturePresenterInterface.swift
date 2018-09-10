//
//  VideoCapturePresenterInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 11/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import GPUImage

protocol VideoCapturePresenterInterface: class {
    
    var view: VideoCaptureViewInterface! { set get }
    var wireframe: VideoCaptureWireframeInterface! { set get }
    var moduleDelegate: VideoCaptureModuleDelegate? { set get }
    var interactor: VideoCaptureInteractorInput! { set get }
    
    var videoCamera: GPUImageVideoCamera? { set get }
    var filter: GPUImageFilter? { set get }
    
}
