//
//  VideoPostUploadModuleDelegate.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/07/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol VideoPostUploadModuleDelegate: class {
    
    func postUploadVideoDidRetry()
    func postUploadVideoDidFail(with message: String)
    func postUploadVideoDidSucceed(with post: UploadedPost)
}
