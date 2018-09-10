//
//  VideoPostUploadInteractorInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/07/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol VideoPostUploadInteractorInterface: class {
    
    var output: VideoPostUploadInteractorOutput? { set get }
    var fileService: FileService! { set get }
    var postService: PostService! { set get }
    var machineLearningService: MachineLearningService! { set get }
    var youTubeService: VideoService! { set get }
    
    init(fileService: FileService, postService: PostService, machineLearningService: MachineLearningService, youTubeService: VideoService)
}


