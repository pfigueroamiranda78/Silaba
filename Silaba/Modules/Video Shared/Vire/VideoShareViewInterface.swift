//
//  VideoShareViewInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 29/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit
import AVKit

protocol VideoShareViewInterface: class {
    
    var controller: UIViewController? { get }
    var presenter: VideoShareModuleInterface! { set get }
    var video: AVPlayerItem! { set get }
    
}
