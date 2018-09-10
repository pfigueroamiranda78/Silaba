//
//  SinglePostInteractor.swift
//  Photostream
//
//  Created by Mounir Ybanez on 18/01/2017.
//  Copyright © 2017 Mounir Ybanez. All rights reserved.
//

protocol SinglePostInteractorInput: BaseModuleInteractorInput {
    
    func fetchPost(id: String)
    func likePost(id: String)
    func unlikePost(id: String)
    func sharePost(id: String)
    func unsharePost(id: String)
    func fetchUserFromTag(with metionTag: String, callback:((String) -> Void)?)
}

protocol SinglePostInteractorOutput: BaseModuleInteractorOutput {
    
    func didFetchPost(data: SinglePostData)
    func didFetchPost(error: PostServiceError)
    
    func didLike(error: PostServiceError?)
    func didUnlike(error: PostServiceError?)
    
    func didShare(error: PostServiceError?)
    func didUnshare(error: PostServiceError?)
}

protocol SinglePostInteractorInterface: BaseModuleInteractor {
    
    var service: PostService! { set get }
    
    init(service: PostService)
}

class SinglePostInteractor: SinglePostInteractorInterface {

    typealias Output = SinglePostInteractorOutput
    
    weak var output: Output?
    var service: PostService!
    
    required init(service: PostService) {
        self.service = service
    }
}

extension SinglePostInteractor: SinglePostInteractorInput {
    
    func fetchPost(id: String) {
        guard output != nil else {
            return
        }
        
        
        service.fetchPostInfo(id: id) { [weak self] result in
            guard result.error == nil else {
                self?.output?.didFetchPost(error: result.error!)
                return
            }
            
            guard let list = result.posts, list.count == 1,
                let (post, user) = list[0] else {
                let error = PostServiceError.failedToFetch(message: "Obtuve un error al traer los datos de la publicación, por favor intenta de nuevo luego")
                self?.output?.didFetchPost(error: error)
                return
            }
            
            var item = SinglePostDataItem()
            
            item.id = post.id
            item.message = post.message
            item.timestamp = post.timestamp
            
            item.photoUrl = post.photo.url
            item.photoWidth = post.photo.width
            item.photoHeight = post.photo.height

            item.identifier = post.identificador()
            item.confidence = post.confidence()

            item.likes = post.likesCount
            item.comments = post.commentsCount
            item.shares = post.sharesCount
            
            item.isShared = post.isShared
            item.isLiked = post.isLiked
            item.isVideo = post.isVideo
            item.recognized_type = post.model
            item.talent = post.talent
            
            item.userId = user.id
            item.avatarUrl = user.avatarUrl
            item.displayName = user.displayName
            
            self?.output?.didFetchPost(data: item)
        }
    }
    
    func fetchUserFromTag(with metionTag: String, callback:((String) -> Void)?) {
        var userInput = [String]()
        userInput.append(String(metionTag))
        
        service.getUserFromUsername(of: userInput) { (users) in
            if users.count < 1 {
                callback!("")
                return
            }
            callback!((users.first?.id)!)
        }
    }
    
    func sharePost(id: String) {
        guard output != nil else {
            return
        }
        
        service.share(id: id) { [weak self] error in
            self?.output?.didShare(error: error)
        }
    }
    
    func unsharePost(id: String) {
        guard output != nil else {
            return
        }
        
        service.unshare(id: id) { [weak self] error in
            self?.output?.didUnshare(error: error)
        }
    }
    
    func likePost(id: String) {
        guard output != nil else {
            return
        }
        
        service.like(id: id) { [weak self] error in
            self?.output?.didLike(error: error)
        }
    }
    
    func unlikePost(id: String) {
        guard output != nil else {
            return
        }
        
        service.unlike(id: id) { [weak self] error in
            self?.output?.didUnlike(error: error)
        }
    }
}
