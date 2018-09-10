//
//  Photo.swift
//  Photostream
//
//  Created by Mounir Ybanez on 17/08/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import Foundation


struct Video {

    var videoTitle: String
    var videoSubTitle: String
    var channelId: String
    var imageUrl: String
    var videoId: String
    var viewCount: String
    var publishedAt: String

    init() {
        videoTitle = ""
        videoSubTitle = ""
        channelId = ""
        imageUrl = ""
        videoId = ""
        viewCount = ""
        publishedAt = ""
    }
    
    init (withTitle videoTitle: String, with videoSubTitle: String, with channelId: String, with imageUrl: String, with videoId: String, with viewCount: String,  with publishedAt: String) {
        self.videoTitle = videoTitle
        self.videoSubTitle = videoSubTitle
        self.channelId = channelId
        self.imageUrl = imageUrl
        self.videoId = videoId
        self.viewCount = viewCount
        self.publishedAt = publishedAt
        
    }
}

enum videoListSource: String {
    case general
    case silabers
    case recommend
}

struct VideoList {
    

    
    var videos: [Video]
    var count: Int {
        return videos.count
    }
    var source: videoListSource
    init() {
        videos = [Video]()
        source = videoListSource.general
    }
    
    subscript (index: Int) -> (Video)? {
        if videos.isValid(index) {
            let video = videos[index]
            return (video)
        }
        return nil
    }
}
