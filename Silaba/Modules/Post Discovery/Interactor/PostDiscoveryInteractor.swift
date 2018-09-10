//
//  PostDiscoveryInteractor.swift
//  Photostream
//
//  Created by Mounir Ybanez on 20/12/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

protocol PostDiscoveryInteractorInput: BaseModuleInteractorInput {
    
    func fetchNew(with limit: UInt)
    func fetchNext(with limit: UInt)
    
    func fetchNew(withHashTag hashTag: String, with limit: UInt)
    func fetchNext(withHashTag hashTag: String, with limit: UInt)
    
    func fetchNew(withRecognized recognized: String,  withTalentId talentId: String, with limit: UInt)
    func fetchNext(withRecognized recognized: String,  withTalentId talentId: String,  with limit: UInt)
    
    func like(post id: String)
    func unlike(post id: String)
    
    func share(post id: String)
    func unshare(post id: String)
}

protocol PostDiscoveryInteractorOutput: BaseModuleInteractorOutput {
    
    func postDiscoveryDidRefresh(with data: [PostDiscoveryData])
    func postDiscoveryDidLoadMore(with data: [PostDiscoveryData])

    
    func postRecommendedDiscoveryDidRefresh(with data: [PostDiscoveryData])
    func postRecommendedDiscoveryDidLoadMores(with data: [PostDiscoveryData])
    
    
    func postDiscoveryDidRefresh(with error: PostServiceError)
    func postDiscoveryDidLoadMore(with error: PostServiceError)
    
    func postDiscoveryDidLike(with postId: String, and error: PostServiceError?)
    func postDiscoveryDidUnlike(with postId: String, and error: PostServiceError?)
    
    func postDiscoveryDidShare(with postId: String, and error: PostServiceError?)
    func postDiscoveryDidUnshare(with postId: String, and error: PostServiceError?)
}

protocol PostDiscoveryInteractorInterface: BaseModuleInteractor {
    
    var service: PostService! { set get }
    
    var offset: String? { set get }
    var isFetching: Bool { set get }
    
    init(service: PostService)
    
    func fetchDiscoveryPosts(with limit: UInt)
    func fetchRecommendedPost(with limit: UInt)
    func fetchDiscoveryPosts(withRecognized recognized: String, withTalentId talentId: String, with limit: UInt)
    
}

class PostDiscoveryInteractor: PostDiscoveryInteractorInterface {
  
    typealias Output = PostDiscoveryInteractorOutput
    
    weak var output: Output?
    
    var service: PostService!

    var offset: String?
    var offset_recommended: String?
    var isFetching: Bool = false
    
    required init(service: PostService) {
        self.service = service
        
    }
    
    func fetchRecommendedPost(with limit: UInt) {
        guard !isFetching, offset != nil, output != nil else {
            return
        }
        
        var discovered_post = [Post]()
        var posts = [PostDiscoveryData]()
        
        service.fetchRecommendPosts(offset: offset!, limit: limit) { [weak self] (result) in
            guard result.error == nil else {
                self?.didFetch(with: result.error!)
                return
            }
            
            discovered_post = (result.posts?.posts)!
            var users_post = result.posts?.users
            
            for post in discovered_post {
                guard let user = users_post![post.userId] else {
                    continue
                }
                
                var item = PostDiscoveryDataItem()
                
                item.id = post.id
                item.message = post.message
                item.timestamp = post.timestamp
                
                item.photoUrl = post.photo.url
                item.photoWidth = post.photo.width
                item.photoHeight = post.photo.height
                
                item.likes = post.likesCount
                item.comments = post.commentsCount
                item.isLiked = post.isLiked
                
                item.shares = post.sharesCount
                item.isShared = post.isShared
                item.isVideo = post.isVideo
                
                item.identifier = post.identificador()
                item.confidence = post.confidence()
                item.recognized_type = post.model
                item.talent = post.talent
                
                item.userId = user.id
                item.avatarUrl = user.avatarUrl
                item.displayName = user.displayName
                
                posts.append(item)
                
                
            }
            if (discovered_post.count > 0) {
                self?.didFetchRecommmended(with: posts)
                self?.offset_recommended = result.nextOffset
            }
        }
    }
    
    func fetchTaggedPosts(withTag tagged: String,  with limit: UInt) {
        guard !isFetching, offset != nil, output != nil else {
            return
        }
        
        
        var discovered_post = [Post]()
        var posts = [PostDiscoveryData]()
        // 

        service.fetchTaggedPosts(tag: tagged, offset: offset!, limit: limit) { [weak self] (result) in
            guard result.error == nil, result.posts != nil else {
                self?.didFetch(with: result.error!)
                return
            }
            
            discovered_post = (result.posts?.posts)!
            var users_post = result.posts?.users
            
            for post in discovered_post {
                guard let user = users_post![post.userId] else {
                    continue
                }
                
                var item = PostDiscoveryDataItem()
                
                item.id = post.id
                item.message = post.message
                item.timestamp = post.timestamp
                
                item.photoUrl = post.photo.url
                item.photoWidth = post.photo.width
                item.photoHeight = post.photo.height
                
                item.likes = post.likesCount
                item.comments = post.commentsCount
                item.isLiked = post.isLiked
                item.shares = post.sharesCount
                item.isShared = post.isShared
                item.isVideo = post.isVideo
                
                item.identifier = post.identificador()
                item.confidence = post.confidence()
                item.recognized_type = post.model
                item.talent = post.talent
                
                item.userId = user.id
                item.avatarUrl = user.avatarUrl
                item.displayName = user.displayName
                
                posts.append(item)
                
                
            }
            
            if discovered_post.count > 0 {
                self?.didFetchRecommmended(with: posts)
                self?.offset = result.nextOffset
            }
        }
    }
    
    
    
    
    func fetchDiscoveryPosts(withRecognized recognized: String, withTalentId talentId: String, with limit: UInt) {
        guard !isFetching, offset != nil, output != nil else {
            return
        }
        
        self.fetchRecommendedPost(with: limit)
        
        var discovered_post = [Post]()
        var posts = [PostDiscoveryData]()
        
        service.fetchDiscoveryPosts(recognized: recognized, talentId: talentId, offset: offset!, limit: limit) { [weak self] (result) in
            guard result.error == nil, result.posts != nil else {
                self?.didFetch(with: result.error!)
                return
            }
            
            discovered_post = (result.posts?.posts)!
            var users_post = result.posts?.users
            
            for post in discovered_post {
                guard let user = users_post![post.userId] else {
                    continue
                }
                
                var item = PostDiscoveryDataItem()
                
                item.id = post.id
                item.message = post.message
                item.timestamp = post.timestamp
                
                item.photoUrl = post.photo.url
                item.photoWidth = post.photo.width
                item.photoHeight = post.photo.height
                
                item.likes = post.likesCount
                item.comments = post.commentsCount
                item.isLiked = post.isLiked
                item.shares = post.sharesCount
                item.isShared = post.isShared
                item.isVideo = post.isVideo
                
                item.identifier = post.identificador()
                item.confidence = post.confidence()
                item.recognized_type = post.model
                item.talent = post.talent
                
                item.userId = user.id
                item.avatarUrl = user.avatarUrl
                item.displayName = user.displayName
                
                posts.append(item)
                
                
            }
            
            if discovered_post.count > 0 {
                self?.didFetch(with: posts)
                self?.offset = result.nextOffset
            }
        }
    }
    
    
    func fetchDiscoveryPosts(with limit: UInt) {
        guard !isFetching, offset != nil, output != nil else {
            return
        }
        
        service.fetchDiscoveryPosts(offset: offset!, limit: limit) { [weak self] result in
            guard result.error == nil else {
                self?.didFetch(with: result.error!)
                return
            }
            
            guard let list = result.posts, list.count > 0 else {
                self?.didFetch(with: [PostDiscoveryData]())
                return
            }
            
            var posts = [PostDiscoveryData]()
            
            for post in list.posts {
                guard let user = list.users[post.userId] else {
                    continue
                }
                
                var item = PostDiscoveryDataItem()
                
                item.id = post.id
                item.message = post.message
                item.timestamp = post.timestamp
                
                item.photoUrl = post.photo.url
                item.photoWidth = post.photo.width
                item.photoHeight = post.photo.height
                
                item.likes = post.likesCount
                item.comments = post.commentsCount
                item.isLiked = post.isLiked
                item.shares = post.sharesCount
                item.isShared = post.isShared
                item.isVideo = post.isVideo
                
                item.identifier = post.identificador()
                item.confidence = post.confidence()
                item.recognized_type = post.model
                item.talent = post.talent

                item.userId = user.id
                item.avatarUrl = user.avatarUrl
                item.displayName = user.displayName
                
                posts.append(item)
            }
            
            self?.didFetch(with: posts)
            self?.offset = result.nextOffset
        }
    }
    
    private func didFetch(with error: PostServiceError) {
        if offset != nil, offset!.isEmpty {
            output?.postDiscoveryDidRefresh(with: error)
            
        } else {
            output?.postDiscoveryDidLoadMore(with: error)
        }
        
        isFetching = false
    }
    
    private func didFetch(with data: [PostDiscoveryData]) {
        if offset != nil, offset!.isEmpty {
            output?.postDiscoveryDidRefresh(with: data)
            
        } else {
            output?.postDiscoveryDidLoadMore(with: data)
        }
        
        isFetching = false
    }
    
    private func didFetchRecommmended(with data: [PostDiscoveryData]) {
        if offset_recommended != nil, offset_recommended!.isEmpty {
            output?.postRecommendedDiscoveryDidRefresh(with: data)
            
        } else {
            output?.postDiscoveryDidLoadMore(with: data)
        }
        
        isFetching = false
    }

}

extension PostDiscoveryInteractor: PostDiscoveryInteractorInput {
    func fetchNext(withHashTag hashTag: String, with limit: UInt) {
        fetchTaggedPosts(withTag: hashTag, with: limit)
    }
    
    
    func fetchNew(withHashTag hashTag: String, with limit: UInt) {
        offset = ""
        offset_recommended  = ""
        fetchTaggedPosts(withTag: hashTag, with: limit)
    }
    
    func fetchNext(withRecognized recognized: String,  withTalentId talentId: String, with limit: UInt) {
        fetchDiscoveryPosts(withRecognized: recognized, withTalentId: talentId, with: limit)
    }

    
    func fetchNew(withRecognized recognized: String,  withTalentId talentId: String, with limit: UInt) {
        offset = ""
        offset_recommended  = ""
        fetchDiscoveryPosts(withRecognized: recognized, withTalentId: talentId, with: limit)
    }
    
    func fetchNew(with limit: UInt) {
        offset = ""
        offset_recommended  = ""
        fetchDiscoveryPosts(with: limit)
    }
    
    func fetchNext(with limit: UInt) {
        fetchDiscoveryPosts(with: limit)
    }
    
    
    func share(post id: String) {
        guard output != nil else {
            return
        }
        
        service.share(id: id) { [unowned self] error in
            self.output?.postDiscoveryDidShare(with: id, and: error)
        }
    }
    
    func unshare(post id: String) {
        guard output != nil else {
            return
        }
        
        service.unshare(id: id) { [unowned self] error in
            self.output?.postDiscoveryDidUnshare(with: id, and: error)
        }
    }
    
    func like(post id: String) {
        guard output != nil else {
            return
        }
        
        service.like(id: id) { [unowned self] error in
            self.output?.postDiscoveryDidLike(with: id, and: error)
        }
    }
    
    func unlike(post id: String) {
        guard output != nil else {
            return
        }
        
        service.unlike(id: id) { [unowned self] error in
            self.output?.postDiscoveryDidUnlike(with: id, and: error)
        }
    }
}
