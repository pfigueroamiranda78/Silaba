//
//  VideoFeedInteractor.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 30/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
//
//  CommenFeedInteractor.swift
//  Photostream
//
//  Created by Mounir Ybanez on 28/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

class VideoFeedInteractor: VideoFeedInteractorInterface {
    
    typealias Output = VideoFeedInteractorOutput
    
    weak var output: Output?
    
    var service: VideoService!
    var offset: String?
    
    fileprivate var isFetching: Bool = false
    
    required init(service: VideoService) {
        self.service = service
    }
    
    fileprivate func fetchVideos(with identifier: String, withTalent talentSource: Talent, withKnowledge knowledgeSource: knowledgeSource, and limit: UInt) {
        guard output != nil, offset != nil, !isFetching else {
            return
        }
        
        isFetching = true
        service.fetchVideos(identifier: identifier, talentSource: talentSource, knowledgeSource: knowledgeSource, offset: offset!, limit: limit) { (result) in
            self.isFetching = false
            
            guard result.error == nil else {
                if self.offset!.isEmpty {
                    self.output?.videoFeedDidRefresh(with: result.error!)
                } else {
                    self.output?.videoFeedDidLoadMore(with: result.error!)
                }
                return
            }
            
            guard let list = result.videoList, list.videos.count > 0  else {
                if self.offset!.isEmpty {
                    self.output?.videoFeedDidRefresh(with: [VideoFeedDataItem]())
                } else {
                    self.output?.videoFeedDidLoadMore(with: [VideoFeedDataItem]())
                }
                return
            }
            
            var feed = [VideoFeedDataItem]()
            
            for (_, video) in list.videos.enumerated() {
       
                var item = VideoFeedDataItem()
                item.id = video.videoId
                item.content = video.videoTitle
                item.authorName = video.videoSubTitle
                item.authorAvatar = video.imageUrl
                item.authorId = video.channelId
                
                let RFC3339DateFormatter = DateFormatter()
                
                RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
                RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"

                let date = RFC3339DateFormatter.date(from: video.publishedAt)
                let dateStamp:TimeInterval = date!.timeIntervalSince1970
                item.timestamp = dateStamp
                feed.append(item)
            }
            
            if self.offset!.isEmpty {
                self.output?.videoFeedDidRefresh(with: feed)
            } else {
                self.output?.videoFeedDidLoadMore(with: feed)
            }
            
            self.offset = result.nextOffset
        }
    }
}

extension VideoFeedInteractor: VideoFeedInteractorInput {
    
    func fetchNew(with postId: String, withTalent talentSource: Talent, withKnowledge knowledgeSource: knowledgeSource, and limit: UInt) {
        offset = ""
        fetchVideos(with: postId, withTalent: talentSource, withKnowledge: knowledgeSource, and: limit)
    }
    
    func fetchNext(with postId: String, withTalent talentSource: Talent, withKnowledge knowledgeSource: knowledgeSource, and limit: UInt) {
        fetchVideos(with: postId, withTalent: talentSource, withKnowledge: knowledgeSource, and: limit)
    }
}

