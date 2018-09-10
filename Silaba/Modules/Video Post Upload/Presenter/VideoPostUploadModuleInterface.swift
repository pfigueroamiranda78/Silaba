//
//  VideoPostUploadModuleInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/07/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol VideoPostUploadModuleInterface: class {
    
    func upload()
    
    func willShowVideo()
    
    func detach()
}
