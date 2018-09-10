//
//  LikedPostModuleExtension.swift
//  Photostream
//
//  Created by Mounir Ybanez on 19/01/2017.
//  Copyright © 2017 Mounir Ybanez. All rights reserved.
//

import UIKit

extension LikedPostModule {
    
    convenience init() {
        self.init(view: LikedPostViewController())
    }
}

extension LikedPostDataItem: PostListCollectionHeaderItem { }

extension LikedPostDataItem: PostListCollectionCellItem {
    
    var identifierText: String {
        return "Reconocido comopost \(recognized_type) \(identifier) en un \(confidence.round(digit: 2))%"
    }
    
    var timeAgo: String {
        let date = NSDate(timeIntervalSince1970: timestamp)
        return date.timeAgoSinceNow()
    }
    
    var photoSize: CGSize {
        var size = CGSize.zero
        size.width = CGFloat(photoWidth)
        size.height = CGFloat(photoHeight)
        return size
    }
    
    var likesText: String {
        guard likes > 0 else {
            return ""
        }
        
        if likes > 1 {
            return "\(likes) me gustan"
            
        } else {
            return "1 me gusta"
        }
    }
    
    var sharesText: String {
        guard shares > 0 else {
            return ""
        }
        
        if shares > 1 {
            return "\(shares) veces compartido"
            
        } else {
            return "1 vez compartido"
        }
    }
    
    var commentsText: String {
        guard comments > 0 else {
            return ""
        }
        
        if comments > 1 {
            return "Ver \(comments) comentarios"
            
        } else {
            return "Ver 1 comentario"
        }
    }
}

extension LikedPostWireframeInterface {
    
    func presentVideoController(from parent: UIViewController, delegate: VideoControllerDelegate?, identifier: String, shouldComment: Bool = false, talentSource: Talent, knowledgeSource: knowledgeSource) {
        let controller = VideoController(root: nil)
        controller.identifier = identifier
        controller.style = .push
        controller.shouldComment = shouldComment
        controller.delegate = delegate
        controller.talentSource = talentSource
        controller.knowledgeSource = knowledgeSource
        
        var property = WireframeEntryProperty()
        property.controller = controller
        property.parent = parent
        
        controller.enter(with: property)
    }
    
    
    func showPostShare(from parent: UIViewController?, postId: String) {
        let module = PostSharedModule()
        module.build(root: root, postId: postId)
        
        var property = WireframeEntryProperty()
        property.parent = parent
        property.controller = module.view.controller
        
        module.wireframe.style = .push
        module.wireframe.enter(with: property)
    }
    
    func showPostTagged(from parent: UIViewController?, hashTag: String) {
        
        let module = PostDiscoveryModule()
        module.build(root: root)
        module.view.controller?.preloadView()
        
        var property = WireframeEntryProperty()
        property.parent = parent
        property.controller = module.view.controller
        
        module.wireframe.style = .push
        module.wireframe.enter(with: property)
        
        module.view.presenter.refreshHashTagPosts(withHashTag: hashTag)
    }
    
    func presentCommentController(from parent: UIViewController, delegate: CommentControllerDelegate?, postId: String, shouldComment: Bool = false) {
        let controller = CommentController(root: nil)
        controller.postId = postId
        controller.style = .push
        controller.shouldComment = shouldComment
        controller.delegate = delegate
        
        var property = WireframeEntryProperty()
        property.controller = controller
        property.parent = parent
        
        controller.enter(with: property)
    }
    
    func showUserTimeline(from parent: UIViewController?, userId: String) {
        let userTimeline = UserTimelineViewController()
        userTimeline.root = root
        userTimeline.style = .push
        userTimeline.userId = userId
        
        var property = WireframeEntryProperty()
        property.parent = parent
        property.controller = userTimeline
        
        userTimeline.enter(with: property)
    }
    
    func showPostLikes(from parent: UIViewController?, postId: String) {
        let module = PostLikeModule()
        module.build(root: root, postId: postId)
        
        var property = WireframeEntryProperty()
        property.parent = parent
        property.controller = module.view.controller
        
        module.wireframe.style = .push
        module.wireframe.enter(with: property)
    }
    
    func showPostShares(from parent: UIViewController?, postId: String) {
        let module = PostSharedModule()
        module.build(root: root, postId: postId)
        
        var property = WireframeEntryProperty()
        property.parent = parent
        property.controller = module.view.controller
        
        module.wireframe.style = .push
        module.wireframe.enter(with: property)
    }
}

extension LikedPostModuleInterface {
  
    func presentVideoController(at index: Int, shouldComment: Bool = false, with talentSrc: Talent, with knowledgeSource: knowledgeSource) {
        guard let presenter = self as? LikedPostPresenter,
            let parent = presenter.view.controller,
            let post = post(at: index) else {
                return
        }
        
        presenter.wireframe.presentVideoController(from: parent, delegate: presenter, identifier: post.identifier, shouldComment: shouldComment, talentSource: talentSrc, knowledgeSource: knowledgeSource)
    }
    
    func presentPostFromTagg(at index: Int, with hashTag: String) {
        guard let presenter = self as? LikedPostPresenter,
            let parent = presenter.view.controller else {
                return
        }
        presenter.wireframe.showPostTagged(from: parent, hashTag: hashTag)
    }
    
    func presentUserTimelineFromTag(at index: Int, with mentionTag: String) {
        guard let presenter = self as? LikedPostPresenter,
            let parent = presenter.view.controller else {
                return
        }
        presenter.interactor.fetchUserFromTag(with: mentionTag) { (result) in
            let userId = result
            presenter.wireframe.showUserTimeline(from: parent, userId: userId)
        }
    }
    
    func presentCommentController(at index: Int, shouldComment: Bool = false) {
        guard let presenter = self as? LikedPostPresenter,
            let parent = presenter.view.controller,
            let post = post(at: index) else {
                return
        }
        
        presenter.wireframe.presentCommentController(
            from: parent,
            delegate: presenter,
            postId: post.id,
            shouldComment: shouldComment
        )
    }
    
    func presentUserTimeline(at index: Int) {
        guard let presenter = self as? LikedPostPresenter,
            let parent = presenter.view.controller,
            let post = post(at: index) else {
                return
        }
        
        presenter.wireframe.showUserTimeline(from: parent, userId: post.userId)
    }
    
    func presentPostLikes(at index: Int) {
        guard let presenter = self as? LikedPostPresenter,
            let parent = presenter.view.controller,
            let post = post(at: index) else {
                return
        }
        
        presenter.wireframe.showPostLikes(from: parent, postId: post.id)
    }
    
    func presentPostShares(at index: Int) {
        guard let presenter = self as? LikedPostPresenter,
            let parent = presenter.view.controller,
            let post = post(at: index) else {
                return
        }
        
        presenter.wireframe.showPostShares(from: parent, postId: post.id)
    }
}

extension LikedPostPresenter: CommentControllerDelegate, VideoControllerDelegate {
    func videoControllerDidWrite(with postId: String) {
        guard let index = indexOf(post: postId),
            var post = post(at: index) else {
                return
        }
        
        posts[index] = post
        
        view.reload(at: index)
    }
    
    
    func commentControllerDidWrite(with postId: String) {
        guard let index = indexOf(post: postId),
            var post = post(at: index) else {
            return
        }
        
        post.comments += 1
        posts[index] = post
        
        view.reload(at: index)
    }
}
