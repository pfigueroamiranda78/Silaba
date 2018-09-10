//
//  VideoFeedInteractorInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 30/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol VideoFeedInteractorInterface: BaseModuleInteractor {
    
    var service: VideoService! { set get }
    var offset: String? { set get }
    
    init(service: VideoService)
}
