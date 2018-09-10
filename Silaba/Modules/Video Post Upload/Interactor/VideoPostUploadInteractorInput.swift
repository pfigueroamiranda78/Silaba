//
//  VideoPostUploadInteractorInput.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/07/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation


protocol VideoPostUploadInteractorInput: class {

   func upload(with data: FileServiceImageUploadData, content: String,  machineLearningList: MachineLearningList, talent: Talent)
}
