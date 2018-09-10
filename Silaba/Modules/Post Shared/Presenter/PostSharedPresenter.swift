//
//  PostSharedPresenter.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation


protocol PostSharedPresenterInterface: BaseModulePresenter, BaseModuleInteractable {
    
    var postId: String { set get }
    var limit: UInt { set get }
    var shares: [PostSharedDisplayData] { set get }
    
    func append(itemsOf data: [PostSharedData])
    func index(of userId: String) -> Int?
}

class PostSharedPresenter: PostSharedPresenterInterface {
    
    typealias ModuleView = PostSharedScene
    typealias ModuleInteractor = PostSharedInteractorInput
    typealias ModuleWireframe = PostSharedWireframeInterface
    
    weak var view: ModuleView!
    var interactor: ModuleInteractor!
    var wireframe: ModuleWireframe!
    
    var postId: String = ""
    var limit: UInt = 20
    var shares = [PostSharedDisplayData]()
    
    func append(itemsOf data: [PostSharedData]) {
        let filtered = data.filter { data -> Bool in
            return index(of: data.userId) == nil
        }
        
        for entry in filtered {
            var item = PostSharedDisplayDataItem()
            item.avatarUrl = entry.avatarUrl
            item.displayName = entry.displayName
            item.isFollowing = entry.isFollowing
            item.isMe = entry.isMe
            item.userId = entry.userId
            
            shares.append(item)
        }
    }
    
    func index(of userId: String) -> Int? {
        return shares.index { displayData -> Bool in
            return displayData.userId == userId
        }
    }
}

extension PostSharedPresenter: PostSharedModuleInterface {
    
    var shareCount: Int {
        return shares.count
    }
    
    func exit() {
        var property = WireframeExitProperty()
        property.controller = view.controller
        wireframe.exit(with: property)
    }
    
    func share(at index: Int) -> PostSharedDisplayData? {
        guard shares.isValid(index) else {
            return nil
        }
        
        return shares[index]
    }
    
    func viewDidLoad() {
        initialLoad()
    }
    
    func initialLoad() {
        view.isLoadingViewHidden = false
        view.isEmptyViewHidden = true
        interactor.fetchNew(postId: postId, limit: limit)
    }
    
    func refresh() {
        view.isRefreshingViewHidden = false
        view.isEmptyViewHidden = true
        interactor.fetchNew(postId: postId, limit: limit)
    }
    
    func loadMore() {
        interactor.fetchNext(postId: postId, limit: limit)
    }
    
    func toggleFollow(at index: Int) {
        guard let share = share(at: index) else {
            return
        }
        
        if share.isFollowing {
            unfollow(at: index)
            
        } else {
            follow(at: index)
        }
    }
    
    func follow(at index: Int) {
        guard var share = share(at: index) else {
            view.didFollow(error: "No puedes seguir en este momento ese usuario, por favor intenta luego")
            return
        }
        
        share.isBusy = true
        shares[index] = share
        
        view.reload(at: index)
        
        interactor.follow(userId: share.userId)
    }
    
    func unfollow(at index: Int) {
        guard var share = share(at: index) else {
            view.didUnfollow(error: "No puedes dejar de seguir en este momento ese usuario, por favor intenta luego")
            return
        }
        
        share.isBusy = true
        shares[index] = share
        
        view.reload(at: index)
        
        interactor.unfollow(userId: share.userId)
    }
}

extension PostSharedPresenter: PostSharedInteractorOutput {
    
    func didFetchNew(data: [PostSharedData]) {
        view.isLoadingViewHidden = true
        view.isRefreshingViewHidden = true
        
        shares.removeAll()
        
        append(itemsOf: data)
        
        if shareCount == 0 {
            view.isEmptyViewHidden = false
        }
        
        view.didRefresh(error: nil)
        view.reload()
    }
    
    func didFetchNext(data: [PostSharedData]) {
        view.didLoadMore(error: nil)
        
        guard data.count > 0 else {
            return
        }
        
        append(itemsOf: data)
        
        view.reload()
    }
    
    func didFetchNew(error: PostServiceError) {
        view.isLoadingViewHidden = true
        view.isRefreshingViewHidden = true
        
        view.didRefresh(error: error.message)
    }
    
    func didFetchNext(error: PostServiceError) {
        view.didLoadMore(error: error.message)
    }
    
    func didFollow(error: UserServiceError?, userId: String) {
        if let index = index(of: userId) {
            var share = shares[index]
            share.isBusy = false
            
            if error == nil {
                share.isFollowing = true
            }
            
            shares[index] = share
            
            view.reload(at: index)
        }
        
        view.didFollow(error: error?.message)
    }
    
    func didUnfollow(error: UserServiceError?, userId: String) {
        if let index = index(of: userId) {
            var share = shares[index]
            share.isBusy = false
            
            if error == nil {
                share.isFollowing = false
            }
            
            shares[index] = share
            
            view.reload(at: index)
        }
        
        view.didUnfollow(error: error?.message)
    }
}

