//
//  AVPlayer+Extensions.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 27/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import AVFoundation

extension AVPlayer {
    
    var isPlaying: Bool {
        if (self.rate != 0 && self.error == nil) {
            return true
        } else {
            return false
        }
    }
    
}


