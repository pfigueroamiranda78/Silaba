//
//  PhotoPickerDiscoveryPresenterInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 20/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol PhotoPickerDiscoveryPresenterInterface: class {
    
    var view: PhotoPickerDiscoveryViewInterface! { set get }
    var wireframe: PhotoPickerDiscoveryWireframeInterface! { set get }
    var moduleDelegate: PhotoPickerDiscoveryModuleDelegate? { set get }
    var source: PhotoSource { set get }
}

