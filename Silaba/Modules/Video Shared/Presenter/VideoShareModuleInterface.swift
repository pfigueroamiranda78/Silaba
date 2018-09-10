//
//  VideoShareModuleInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 29/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import AVKit

protocol VideoShareModuleInterface: class {
    
    func cancel()
    func finish(with video: AVPlayerItem, content: String)
    
    func pop(animated: Bool)
    func dismiss(animated: Bool, completion: (() -> Void)?)
}   

extension VideoShareModuleInterface {
    
    func pop() {
        pop(animated: true)
    }
    
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}
