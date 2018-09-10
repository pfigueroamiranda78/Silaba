//
//  VideoFeedModuleInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 30/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol VideoFeedModuleInterface: BaseModuleInterface {
    
    var videoCount: Int { get }
    
    func refreshVideos()
    func loadMoreVideos()
    
    func view(at index: Int) -> VideoFeedData?
}
