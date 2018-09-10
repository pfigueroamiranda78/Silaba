//
//  VideoSharePresenterInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 29/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol VideoSharePresenterInterface: class {
    
    var view: VideoShareViewInterface! { set get }
    var wireframe: VideoShareWireframeInterface! { set get }
    var moduleDelegate: VideoShareModuleDelegate? { set get }
}

