//
//  PhotoPickerDiscoveryModuleDelegate.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 20/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit
import AVKit

protocol PhotoPickerDiscoveryModuleDelegate: class {
    
    func photoPickerDiscoveryDidFinish(with image: UIImage?, with identifier: MachineLearningList?)
    func photoPickerDiscoveryDidFinish(with video: AVPlayerItem?, with identifier: MachineLearningList?)
    func photoPickerDiscoveryDidCancel()
    func photoDiscoveryAsSampleBuffer(with identifier: MachineLearningList?)
    func photoPickerSetTalent(with talentList: TalentList)
}
