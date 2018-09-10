//
//  PhotoPickerDiscoveryModuleInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 20/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
protocol PhotoPickerDiscoveryModuleInterface: class {
    
    func cancel()
    
    func willShowCamera()
    func willShowLibrary()
    
    func dismiss(animated: Bool)
}

extension PhotoPickerDiscoveryModuleInterface {
    
    func dismiss() {
        dismiss(animated: true)
    }
}
