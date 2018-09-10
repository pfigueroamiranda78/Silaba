//
//  VideoSharePresenter.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 29/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class VideoSharePresenter: VideoSharePresenterInterface {
    
    weak var moduleDelegate: VideoShareModuleDelegate?
    weak var view: VideoShareViewInterface!
    var wireframe: VideoShareWireframeInterface!
}

extension VideoSharePresenter: VideoShareModuleInterface {
    
    func cancel() {
        moduleDelegate?.videoShareDidCancel()
    }
    
    func finish(with video: AVPlayerItem, content: String) {
        moduleDelegate?.videoShareDidFinish(with: video, content: content)
    }
    
    func pop(animated: Bool) {
        wireframe.pop(from: view.controller?.navigationController, animated: animated)
    }
    
    func dismiss(animated: Bool, completion: (() -> Void)?) {
        wireframe.dismiss(with: view.controller, animated: animated, completion: completion)
    }
}

