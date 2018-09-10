//
//  PhotoPickerDiscoveryWireframeInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 20/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit

protocol PhotoPickerDiscoveryWireframeInterface: class {
    
    var dependencies: [PhotoPickerDiscoveryModuleDependency]? { set get }
    var root: RootWireframeInterface? { set get }
    
    init(root: RootWireframeInterface?, delegate: PhotoPickerDiscoveryModuleDelegate?, view: PhotoPickerDiscoveryViewInterface)
    
    func attachRoot(with controller: UIViewController, in window: UIWindow)
    
    func present(with controller: UIViewController?, from: UIViewController?, animated: Bool, completion: (() -> Void)?)
    
    func dismiss(with controller: UIViewController?, animated: Bool, completion: (() -> Void)?)
    
    func dependency<T>() -> T?
}

protocol PhotoPickerDiscoveryModuleDependency: class { }
