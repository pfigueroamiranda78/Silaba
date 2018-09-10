//
//  YouTubeService.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 22/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol VideoService {
    func getTopVideos(data: VideoServiceTopSearchData, callback: ((VideoServiceResult)-> Void)?)
    func getVideoWithTextSearch (data: VideoServiceTextSearchData, callback: ((VideoServiceResult)-> Void)?)
    func fetchVideos(identifier: String, talentSource: Talent, knowledgeSource: knowledgeSource, offset: String, limit: UInt, callback: ((VideoServiceResult) -> Void)?)
}

struct VideoServiceTopSearchData {
    var nextPageToken : String = ""
    var channelId: String = ""
    var showLoader : Bool = false
}

struct VideoServiceTextSearchData {
    var searchText: String = ""
    var talentSource: Talent = Talent()
    var knowledgeSource: knowledgeSource = .general
    var channelId: String = ""
    var nextPageToken: String = ""
    var source: videoListSource = videoListSource.general
}


struct VideoServiceResult {
    
    var videoList: VideoList?
    var success: Bool?
    var nextToken: String?
    var nextOffset: String?
    var source: videoListSource?
    var error: VideoServiceError?
}

enum VideoServiceError: Error {
    case videosnotFound(message: String)
    case netError(message: String)
    var message: String {
        switch self {
        case .videosnotFound(let message),
             .netError(let message):
            return message
        }
    }
}
