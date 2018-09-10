//
//  VideoFeedScene.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 30/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol VideoFeedScene: BaseModuleView {
    
    var presenter: VideoFeedModuleInterface! { set get }
    
    func reload()
    func showEmptyView()
    func showInitialLoadView()
    func showRefreshView()
    func hideEmptyView()
    func hideInitialLoadView()
    func hideRefreshView()
    
    func didRefreshVideos(with error: String?)
    func didLoadMoreVideos(with error: String?)
}
