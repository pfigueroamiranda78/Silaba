//
//  NewsFeedInteractor.swift
//  Photostream
//
//  Created by Mounir Ybanez on 06/08/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

protocol NewsFeedInteractorInput: BaseModuleInteractorInput {
    
    func fetchNew(with limit: UInt)
    func fetchNext(with limit: UInt)
    func like(post id: String)
    func unlike(post id: String)
    func share(post id: String)
    func unshare(post id: String)
    func fetchUserFromTag(with metionTag: String, callback:((String) -> Void)?)
}

protocol NewsFeedInteractorOutput: BaseModuleInteractorOutput {
    
    func newsFeedDidRefresh(data: NewsFeedData)
    func newsFeedDidLoadMore(data: NewsFeedData)
    func newsFeedDidRefresh(error: NewsFeedServiceError)
    func newsFeedDidLoadMore(error: NewsFeedServiceError)
    
    func newsFeedDidLike(with postId: String, and error: PostServiceError?)
    func newsFeedDidUnlike(with postId: String, and error: PostServiceError?)
    
    func newsFeedDidShare(with postId: String, and error: PostServiceError?)
    func newsFeedDidUnshare(with postId: String, and error: PostServiceError?)
}

protocol NewsFeedInteractorInterface: BaseModuleInteractor {
    
    var offset: String? { set get }
    var feedService: NewsFeedService! { set get }
    var postService: PostService! { set get }
    var videoService: VideoService! { set get }
    
    init(feedService: NewsFeedService, postService: PostService, videoService: VideoService)
}

class NewsFeedInteractor: NewsFeedInteractorInterface {
    
    typealias Output = NewsFeedInteractorOutput
    
    weak var output: Output?
    
    var feedService: NewsFeedService!
    var postService: PostService!
    var videoService: VideoService!
    var offset: String?
    
    fileprivate var isFetching: Bool = false

    required init(feedService: NewsFeedService, postService: PostService, videoService: VideoService) {
        self.feedService = feedService
        self.postService = postService
        self.videoService = videoService
    }

    fileprivate func fetch(with limit: UInt) {
        guard output != nil && offset != nil && !isFetching else {
            return
        }
        
        isFetching = true
        feedService.fetchNewsFeed(offset: offset!, limit: limit) { (result) in
            self.isFetching = false
            
            guard result.error == nil else {
                if self.offset!.isEmpty {
                    self.output?.newsFeedDidRefresh(error: result.error!)
                } else {
                    self.output?.newsFeedDidLoadMore(error: result.error!)
                }
                return
            }
            
            let data = self.parseData(with: result.posts)
            if self.offset!.isEmpty {
                self.output?.newsFeedDidRefresh(data: data)
            } else {
                self.output?.newsFeedDidLoadMore(data: data)
            }
            
            self.offset = result.nextOffset as? String
        }
    }

    fileprivate func parseData(with posts: PostList?) -> NewsFeedData {
        guard posts != nil else {
            return NewsFeedData()
        }
        
        var data = NewsFeedData()
        for i in 0..<posts!.count {
            if let (post, user) = posts![i] {
                var item = NewsFeedPost()
                
                item.id = post.id
                item.message = post.message
                item.timestamp = post.timestamp
                
                item.likes = post.likesCount
                item.comments = post.commentsCount
                item.shares = post.sharesCount
                item.isShared = post.isShared
                item.isLiked = post.isLiked
                item.isVideo = post.isVideo

                item.photoUrl = post.photo.url
                item.photoWidth = post.photo.width
                item.photoHeight  = post.photo.height
                
                item.identifier = post.identificador()
                item.confidence = post.confidence()
                item.recognized_type = post.model
                item.talent = post.talent

                item.userId = user.id
                item.avatarUrl = user.avatarUrl
                item.displayName = user.displayName

                data.items.append(item)
            }
        }
        return data
    }
}

extension NewsFeedInteractor: NewsFeedInteractorInput {
    
    func fetchNew(with limit: UInt) {
        offset = ""
        fetch(with: limit)
    }
    
    func fetchUserFromTag(with metionTag: String, callback:((String) -> Void)?) {
        var userInput = [String]()
        userInput.append(String(metionTag))
        
        postService.getUserFromUsername(of: userInput) { (users) in
            if users.count < 1 {
                callback!("")
                return
            }
            callback!((users.first?.id)!)
        }
    }
    
    
    func fetchNext(with limit: UInt) {
        fetch(with: limit)
    }
    
    func like(post id: String) {
        guard output != nil else {
            return
        }
        
        postService.like(id: id) { (error) in
            self.output?.newsFeedDidLike(with: id, and: error)
        }
    }
    
    func unlike(post id: String) {
        guard output != nil else {
            return
        }
        
        postService.unlike(id: id) { (error) in
            self.output?.newsFeedDidUnlike(with: id, and: error)
        }
    }
    
    func share(post id: String) {
        guard output != nil else {
            return
        }
        
        postService.share(id: id) { (error) in
            self.output?.newsFeedDidShare(with: id, and: error)
        }
    }
    
    func unshare(post id: String) {
        guard output != nil else {
            return
        }
        
        postService.unshare(id: id) { (error) in
            self.output?.newsFeedDidUnshare(with: id, and: error)
        }
    }
}

