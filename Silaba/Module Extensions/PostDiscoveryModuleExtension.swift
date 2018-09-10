//
//  PostDiscoveryModuleExtension.swift
//  Photostream
//
//  Created by Mounir Ybanez on 20/12/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import DateTools

extension PostDiscoveryModule {
    
    convenience init(sceneType: PostDiscoverySceneType = .grid) {
        let scene = PostDiscoveryViewController(type: sceneType)
        self.init(view: scene)
    }
}

extension PostDiscoveryScene {
    
    func isBackBarItemVisible(_ isVisible: Bool) {
        guard let controller = controller as? PostDiscoveryViewController else {
            return
        }
        
        controller.isBackBarItemVisible = isVisible
    }
}

extension PostDiscoveryWireframeInterface {
    
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
    
    func showPostDiscoveryAsList(from parent: UIViewController, posts: [PostDiscoveryData] = [PostDiscoveryData](), index: Int) {
        let module = PostDiscoveryModule(sceneType: .list)
        module.build(
            root: root,
            posts: posts,
            initialPostIndex: index
        )
        module.view.isBackBarItemVisible(true)
        
        var property = WireframeEntryProperty()
        property.controller = module.view.controller
        property.parent = parent
        
        module.wireframe.style = .push
        module.wireframe.enter(with: property)
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
}

extension PostDiscoveryModuleInterface {
  
    func presentVideoController(at index: Int, shouldComment: Bool = false, with talentSource: Talent, with knowledgeSource: knowledgeSource) {
        guard let presenter = self as? PostDiscoveryPresenter,
            let parent = presenter.view.controller,
            let post = post(at: index) else {
                return
        }
        presenter.wireframe.presentVideoController(from: parent, delegate: presenter, identifier: post.identifier, shouldComment: shouldComment, talentSource: talentSource, knowledgeSource: knowledgeSource)
    }
    
    func presentPostFromTagg(at index: Int, with hashTag: String) {
        guard let presenter = self as? NewsFeedPresenter,
            let parent = presenter.view.controller else {
                return
        }
        presenter.wireframe.showPostTagged(from: parent, hashTag: hashTag)
    }
    
    func presentUserTimelineFromTag(at index: Int, with mentionTag: String) {
        guard let presenter = self as? NewsFeedPresenter,
            let parent = presenter.view.controller else {
                return
        }
        presenter.interactor.fetchUserFromTag(with: mentionTag) { (result) in
            let userId = result
            presenter.wireframe.showUserTimeline(from: parent, userId: userId)
        }
    }
    
    func presentCommentController(at index: Int, shouldComment: Bool = false) {
        guard let presenter = self as? PostDiscoveryPresenter,
            let parent = presenter.view.controller,
            let post = post(at: index) else {
                return
        }
        
        presenter.wireframe.presentCommentController(from: parent, delegate: presenter, postId: post.id, shouldComment: shouldComment)
    }
    
    func presentPostDiscoveryAsList(with index: Int, with section: Int) {
        guard let presenter = self as? PostDiscoveryPresenter,
            let parent = presenter.view.controller else {
                return
        }
        
        if (section == presenter.sectionCount - 1) {
            presenter.wireframe.showPostDiscoveryAsList(
                from: parent,
                posts: presenter.posts,
                index: index
        )
        } else {
            presenter.wireframe.showPostDiscoveryAsList(
                from: parent,
                posts: presenter.recommmendedPost,
                index: index
            )
        }
    }
    
    func presentUserTimeline(at index: Int) {
        guard let presenter = self as? PostDiscoveryPresenter,
            let parent = presenter.view.controller,
            let post = post(at: index) else {
                return
        }
        
        presenter.wireframe.showUserTimeline(from: parent, userId: post.userId)
    }
    
    func presentPostLikes(at index: Int) {
        guard let presenter = self as? NewsFeedPresenter,
            let parent = presenter.view.controller,
            let post = post(at: index) else {
                return
        }
        
        presenter.wireframe.showPostLikes(from: parent, postId: post.id)
    }
    
    func presentPostShares(at index: Int) {
        guard let presenter = self as? NewsFeedPresenter,
            let parent = presenter.view.controller,
            let post = post(at: index) else {
                return
        }
        
        presenter.wireframe.showPostShare(from: parent, postId: post.id)
    }
}

extension PostDiscoveryPresenter: CommentControllerDelegate, VideoControllerDelegate {
    func videoControllerDidWrite(with postId: String) {
        guard let index = indexOf(post: postId) else {
            return
        }
        
        var post = posts[index]
        posts[index] = post
        view.reloadView()
    }
    
    
    func commentControllerDidWrite(with postId: String) {
        guard let index = indexOf(post: postId) else {
            return
        }
        
        var post = posts[index]
        post.comments += 1
        posts[index] = post
        view.reloadView()
    }
}

extension PostDiscoveryDataItem: PostGridCollectionCellItem { }

extension PostDiscoveryDataItem: PostListCollectionHeaderItem { }

extension PostDiscoveryDataItem: PostListCollectionCellItem {
    
    var identifierText: String {
        return "Reconocido como \(recognized_type) \(identifier) en un \(confidence.round(digit: 2))%"
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
            return "\(likes) me gusta"
            
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
