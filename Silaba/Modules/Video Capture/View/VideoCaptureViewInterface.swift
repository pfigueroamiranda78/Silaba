//
//  VideoCaptureViewInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 11/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit
import GPUImage

protocol VideoCaptureViewInterface: class {
    
    var controller: UIViewController? { get }
    var presenter: VideoCaptureModuleInterface! { set get }
    func updateVisual(with text:String)
    func updateWikipedia(with text:String)
    func updateBannerText(with text:String)
    func updateSelectedTalent(with selectedTalent:Talent)
    func updateSampleImage(with sample: CMSampleBuffer)
    func didRecordedVideo(theUrl url:NSURL)
}
