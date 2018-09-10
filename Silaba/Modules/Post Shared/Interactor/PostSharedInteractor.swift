//
//  PostSharedInteractor.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation


protocol PostSharedInteractorInput: BaseModuleInteractorInput {
    
    func fetchNew(postId: String, limit: UInt)
    func fetchNext(postId: String, limit: UInt)
    
    func follow(userId: String)
    func unfollow(userId: String)
}

protocol PostSharedInteractorOutput: BaseModuleInteractorOutput {
    
    func didFetchNew(data: [PostSharedData])
    func didFetchNext(data: [PostSharedData])
    
    func didFetchNew(error: PostServiceError)
    func didFetchNext(error: PostServiceError)
    
    func didFollow(error: UserServiceError?, userId: String)
    func didUnfollow(error: UserServiceError?, userId: String)
}

protocol PostSharedInteractorInterface: BaseModuleInteractor {
    
    var postService: PostService! { set get }
    var userService: UserService! { set get }
    var offset: String? { set get }
    var isFetching: Bool { set get }
    
    init(postService: PostService, userService: UserService)
    
    func fetch(postId: String, limit: UInt)
}

class PostSharedInteractor: PostSharedInteractorInterface {
    
    typealias Output = PostSharedInteractorOutput
    
    weak var output: Output?
    var postService: PostService!
    var userService: UserService!
    var offset: String?
    var isFetching: Bool = false
    
    required init(postService: PostService, userService: UserService) {
        self.postService = postService
        self.userService = userService
    }
    
    func fetch(postId: String, limit: UInt) {
        guard output != nil, offset != nil, !isFetching else {
            return
        }
        
        isFetching = true
        
        postService.fetchShares(id: postId, offset: offset!, limit: limit, callback: {
            [weak self] result in
            
            self?.didFinishFetching(result: result)
        })
    }
    
    fileprivate func didFinishFetching(result: PostServiceShareResult) {
        guard result.error == nil else {
            didFetch(error: result.error!)
            return
        }
        
        guard let shares = result.shares, shares.count > 0 else {
            didFetch(data: [PostSharedData](), nextOffset: result.nextOffset)
            return
        }
        
        var data = [PostSharedData]()
        
        for share in shares {
            var item = PostSharedDataItem()
            
            item.avatarUrl = share.avatarUrl
            item.displayName = share.displayName
            item.userId = share.id
            
            item.isFollowing = result.following != nil && result.following![share.id] != nil
            
            if let isMe = result.following?[share.id] {
                item.isMe = isMe
            }
            
            data.append(item)
        }
        
        didFetch(data: data, nextOffset: result.nextOffset)
    }
    
    fileprivate func didFetch(error: PostServiceError) {
        if let offset = offset {
            if offset.isEmpty {
                output?.didFetchNew(error: error)
            } else {
                output?.didFetchNext(error: error)
            }
        }
        
        isFetching = false
    }
    
    fileprivate func didFetch(data: [PostSharedData], nextOffset: String?) {
        if let offset = offset {
            if offset.isEmpty {
                output?.didFetchNew(data: data)
            } else {
                output?.didFetchNext(data: data)
            }
        }
        
        isFetching = false
        offset = nextOffset
    }
}

extension PostSharedInteractor: PostSharedInteractorInput {
    
    func fetchNew(postId: String, limit: UInt) {
        offset = ""
        fetch(postId: postId, limit: limit)
    }
    
    func fetchNext(postId: String, limit: UInt) {
        fetch(postId: postId, limit: limit)
    }
    
    func follow(userId: String) {
        userService.follow(id: userId) { [weak self] error in
            self?.output?.didFollow(error: error, userId: userId)
        }
    }
    
    func unfollow(userId: String) {
        userService.unfollow(id: userId) { [weak self] error in
            self?.output?.didUnfollow(error: error, userId: userId)
        }
    }}

