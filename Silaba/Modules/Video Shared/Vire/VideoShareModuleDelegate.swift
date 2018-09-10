//
//  VideoShareModuleDelegate.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 29/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//
import UIKit
import AVKit


protocol VideoShareModuleDelegate: class {
    
    func videoShareDidCancel()
    func videoShareDidFinish(with video: AVPlayerItem, content: String)
}
