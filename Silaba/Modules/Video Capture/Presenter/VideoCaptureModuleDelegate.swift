//
//  VideoCaptureModuleDelegate.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 11/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit
import AVKit

protocol VideoCaptureModuleDelegate: class {
    
    func videoCaptureDidFinish(with video: AVPlayerItem?)
    func videoCaptureDidCancel()
    func videoAsSampleBuffer(with recognized: MachineLearningList)
    func videoDidCapture(with url: NSURL)

}

