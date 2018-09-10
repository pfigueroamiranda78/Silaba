//
//  PhotoPickerDiscoveryInteractorInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 27/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol PhotoPickerDiscoveryInteractorInterface: class {
    
    var output: PhotoPickerDiscoveryInteractorOutput? { set get }
    
    init(service: TalentService)
}
