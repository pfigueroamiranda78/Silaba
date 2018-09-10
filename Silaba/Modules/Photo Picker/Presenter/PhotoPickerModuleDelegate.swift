//
//  PhotoPickerModuleDelegate.swift
//  Photostream
//
//  Created by Mounir Ybanez on 09/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import UIKit
import AVKit

protocol PhotoPickerModuleDelegate: class {
    
    func photoPickerDidFinish(with image: UIImage?, with identifier: MachineLearningList?)
    func videoPickerDidFinish(with playeritem: AVPlayerItem?, with identifier: MachineLearningList?)
    func photoPickerDidCancel()
    func photoAsSampleBuffer(with identifier: MachineLearningList?)
    func photoPickerSetTalent(with talentList: TalentList)
    func photoPickerSetThing(with thingList: ThingList)
    func photoPickerSetFollow(with userList: [User])
}
