//
//  VideoFeedInteractorOutput.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 30/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol VideoFeedInteractorOutput: BaseModuleInteractorOutput {
    
    func videoFeedDidRefresh(with feed: [VideoFeedData])
    func videoFeedDidLoadMore(with feed: [VideoFeedData])
    func videoFeedDidRefresh(with error: VideoServiceError)
    func videoFeedDidLoadMore(with error: VideoServiceError)
}
