//
//  PostSharedScene.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol PostSharedScene: BaseModuleView {
    
    var presenter: PostSharedModuleInterface! { set get }
    
    var isEmptyViewHidden: Bool { set get }
    var isLoadingViewHidden: Bool { set get }
    var isRefreshingViewHidden: Bool { set get }
    
    func reload()
    func reload(at index: Int)
    
    func didRefresh(error: String?)
    func didLoadMore(error: String?)
    
    func didFollow(error: String?)
    func didUnfollow(error: String?)
}
