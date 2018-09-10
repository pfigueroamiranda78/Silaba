//
//  PhotoPickerDiscoveryViewInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 20/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit

protocol PhotoPickerDiscoveryViewInterface: class {
    
    var controller: UIViewController? { get }
    var presenter: PhotoPickerDiscoveryModuleInterface! { set get }
    
    func setupDependency(with controllers: [UIViewController])
    
    func showCamera()
    func showLibrary()
}
