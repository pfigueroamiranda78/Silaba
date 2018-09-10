//
//  PhotoPickerDiscoveryInteractorOutput.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 27/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import Foundation

protocol PhotoPickerDiscoveryInteractorOutput: class {
    
    func photoPickerDiscoveryDidFetchTalent(with result: TalentServiceResult)
    
}

