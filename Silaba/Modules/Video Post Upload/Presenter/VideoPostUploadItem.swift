//
//  VideoPostUploadItem.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 4/07/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit
import AVKit

struct VideoPostUploadItem {
    
    var content: String!
    var recognize_type: String!
    var machineLearningList: MachineLearningList!
    var talent: Talent!
    var video: AVPlayerItem!
    
    var imageData: FileServiceImageUploadData {
        var data = FileServiceImageUploadData()
        data.isVideo = true
        data.localUrl = (video.asset as? AVURLAsset)?.url as NSURL?
        data.data =  try? Data(contentsOf: data.localUrl! as URL)
        return data
    }
}
