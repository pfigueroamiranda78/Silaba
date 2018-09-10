//
//  VideoFeedPresenter.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 30/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

class VideoFeedPresenter: VideoFeedPresenterInterface {
    typealias ModuleView = VideoFeedScene
    typealias ModuleWireframe = VideoFeedWireframeInterface
    typealias ModeuleInteractor = VideoFeedInteractorInput
    
    lazy var videos: [VideoFeedData]! = [VideoFeedData]()
    
    weak var view: ModuleView!
    var wireframe: ModuleWireframe!
    var interactor: ModeuleInteractor!
    var identifier: String!
    var talentSource: Talent!
    var knowledgeSource: knowledgeSource!
    var limit: UInt! = 10
}


extension VideoFeedPresenter: VideoFeedModuleInterface {
    
    var videoCount: Int {
        return videos.count
    }
    
    func exit() {
        var property = WireframeExitProperty()
        property.controller = view.controller
        wireframe.exit(with: property)
    }
    
    func loadMoreVideos() {
        interactor.fetchNext(with: identifier, withTalent: talentSource, withKnowledge: knowledgeSource, and: limit)
    }
    
    func refreshVideos() {
        interactor.fetchNew(with: identifier, withTalent: talentSource, withKnowledge: knowledgeSource, and: limit)
        if videos.count == 0 {
            view.hideEmptyView()
            view.showInitialLoadView()
        }
        view.showRefreshView()
    }
    
    func view(at index: Int) -> VideoFeedData? {
        return videos[index]
    }
}

extension VideoFeedPresenter: VideoFeedInteractorOutput {
    
    func videoFeedDidRefresh(with feed: [VideoFeedData]) {
        view.hideInitialLoadView()
        view.hideRefreshView()
        
        guard !(feed.count == 0 && videos.count == 0) else {
            view.reload()
            view.showEmptyView()
            return
        }
        
        videos.removeAll()
        videos.append(contentsOf: feed)
        
        view.didRefreshVideos(with: nil)
        view.reload()
    }
    
    func videoFeedDidLoadMore(with feed: [VideoFeedData]) {
        guard feed.count > 0 else {
            return
        }
        
        videos.append(contentsOf: feed)
        
        view.didLoadMoreVideos(with: nil)
        view.reload()
    }
    
    func videoFeedDidRefresh(with error: VideoServiceError) {
        view.hideInitialLoadView()
        view.hideRefreshView()
        
        if videos.count == 0 {
            view.showEmptyView()
        }
        
        view.didRefreshVideos(with: error.message)
        view.reload()
    }
    
    func videoFeedDidLoadMore(with error: VideoServiceError) {
        view.hideInitialLoadView()
        view.hideRefreshView()
        
        view.didLoadMoreVideos(with: error.message)
        view.reload()
    }
}
