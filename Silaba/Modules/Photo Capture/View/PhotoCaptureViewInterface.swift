//
//  PhotoCaptureViewInterface.swift
//  Photostream
//
//  Created by Mounir Ybanez on 10/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import UIKit
import GPUImage

protocol PhotoCaptureViewInterface: class {

    var controller: UIViewController? { get }
    var presenter: PhotoCaptureModuleInterface! { set get }
    func updateVisual(with text:String)
    func updateWikipedia(with text:String)
    func updateBannerText(with text:String)
    func updateSelectedTalent(with selectedTalent:Talent)
    func updateSampleImage(with sample: CMSampleBuffer)
}
