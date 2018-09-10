//
//  VideoPostUploadViewInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/07/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import AVKit

protocol VideoPostUploadViewInterface: class {
    
    var controller: UIViewController? { get }
    var presenter: VideoPostUploadModuleInterface! { set get }
    func show(video: AVPlayerItem)
    
    func didFail(with message: String)
    func didSucceed()
    func didUpdate(with progress: Progress)
}
