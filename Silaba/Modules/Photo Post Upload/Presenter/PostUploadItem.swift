//
//  PostUploadItem.swift
//  Photostream
//
//  Created by Mounir Ybanez on 25/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import UIKit
import AVKit

struct PostUploadItem {
    
    var image: UIImage!
    var content: String!
    var recognize_type: String!
    var machineLearningList: MachineLearningList!
    var talent: Talent!
    
    var imageData: FileServiceImageUploadData {
        var data = FileServiceImageUploadData()
        data.data = UIImageJPEGRepresentation(image, 1.0)
        data.width = Float(image.size.width)
        data.height = Float(image.size.height)
        return data
    }
}
