//
//  PostDiscoveryPresenter.swift
//  Photostream
//
//  Created by Mounir Ybanez on 20/12/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import Foundation

protocol PostDiscoveryPresenterInterface: BaseModulePresenter, BaseModuleInteractable {

    var posts: [PostDiscoveryData] { set get }
    var limit: UInt { set get }
    var initialPostIndex: Int { set get }
    var isShownInitialPost: Bool { set get }
    func indexOf(post id: String) -> Int?
}

class PostDiscoveryPresenter: PostDiscoveryPresenterInterface {
    

    typealias ModuleView = PostDiscoveryScene
    typealias ModuleInteractor = PostDiscoveryInteractorInput
    typealias ModuleWireframe = PostDiscoveryWireframeInterface
    
    weak var view: ModuleView!
    
    var interactor: ModuleInteractor!
    var wireframe: ModuleWireframe!
    
    var posts = [PostDiscoveryData]()
    var recommmendedPost = [PostDiscoveryData]()
    
    var limit: UInt = 50
    var initialPostIndex: Int = 0
    var isShownInitialPost: Bool = false
    var recognized: String = ""
    var talentId: String = ""
    var hashTag: String = ""
    
    func indexOf(post id: String) -> Int? {
        let itemIndex = posts.index { item -> Bool in
            return item.id == id
        }
        return itemIndex
    }
}

extension PostDiscoveryPresenter: PostDiscoveryModuleInterface {

    

    
    func RecommendedPostCount(at section: Int) -> Int {
        if recommmendedPost.count < 1 {
            return 0
        }
        let TalentList = recommmendedPost.first?.getTalentList(withPostDiscoveryData: recommmendedPost)
        
        if (TalentList?.count)! < 1 {
            return 0
        }
        let Talent = TalentList?.talents[section]
        
        return (recommmendedPost.first?.getByTalent(withPostDiscoveryData: recommmendedPost, ofTalent: Talent!).count)!
    }

    func sectionName(at section: Int) -> String? {
        if recommmendedPost.count < 1 {
            return nil
        }
        let talentList =  recommmendedPost.first?.getTalentList(withPostDiscoveryData: recommmendedPost)
        
        if ((talentList?.count)! < section) {
            return nil
        }
        
        return talentList?.talents[section].id
    }
    
    var sectionCount: Int {
        if recommmendedPost.count < 1 {
            return 0
        }
        
        let result = (recommmendedPost.first?.getTalentList(withPostDiscoveryData: recommmendedPost).count)!
        // Le agrego un para sumar la seccion de resultados de la busqueda
        return result + 1
    }
    
    
    var postCount: Int {
        return posts.count
    }
    
    
    func exit() {
        var property = WireframeExitProperty()
        property.controller = view.controller
        wireframe.exit(with: property)
    }
    
    
    func viewDidLoad() {
        
        if postCount == 0 {
            initialLoad()
            
        } else {
            view.reloadView()
            view.hideInitialLoadView()
            view.hideRefreshView()
        }
    }
    
    
    func initialLoad() {
        view.showInitialLoadView()
        if (self.recognized == "") {
            interactor.fetchNew(with: limit)
        } else {
            interactor.fetchNew(withRecognized: self.recognized, withTalentId: self.talentId, with: limit)
        }
    }
    
    func refreshPosts() {
        view.hideEmptyView()
        view.showRefreshView()
        posts.removeAll()
        if (self.recognized == "") {
            interactor.fetchNew(with: limit)
        } else {
            interactor.fetchNew(withRecognized: self.recognized, withTalentId: self.talentId,with: limit)
        }
    }
    

    
    func refreshHashTagPosts(withHashTag hashTag: String) {
        view.hideEmptyView()
        view.showRefreshView()
        posts.removeAll()
        self.hashTag = hashTag.extractHashTag().first!
        if (self.hashTag == "") {
            return
        } else {
            interactor.fetchNew(withHashTag: self.hashTag, with: limit)
        }
    }
    
    func loadMorePosts() {
        if (self.recognized == "") {
            interactor.fetchNext(with: limit)
        } else {
            interactor.fetchNext(withRecognized: self.recognized, withTalentId: self.talentId,with: limit)
        }
    }
    
    func unlikePost(at index: Int) {
        guard var post = post(at: index), post.isLiked else {
            return
        }
        
        post.isLiked = false
        post.likes -= 1
        posts[index] = post
        view.reloadView()
        
        interactor.unlike(post: post.id)
    }
    
    func likePost(at index: Int) {
        guard var post = post(at: index), !post.isLiked else {
            return
        }
        
        post.isLiked = true
        post.likes += 1
        posts[index] = post
        view.reloadView()
        
        interactor.like(post: post.id)
    }
    
    
    func unsharePost(at index: Int) {
        guard var post = post(at: index), post.isShared else {
            return
        }
        
        post.isShared = false
        post.shares -= 1
        posts[index] = post
        view.reloadView()
        
        interactor.unshare(post: post.id)
    }
    
    func sharePost(at index: Int) {
        guard var post = post(at: index), !post.isShared else {
            return
        }
        
        post.isShared = true
        post.shares += 1
        posts[index] = post
        view.reloadView()
        
        interactor.share(post: post.id)
    }
    
    
    func toggleLike(at index: Int) {
        guard let post = post(at: index) else {
            return
        }
        
        if post.isLiked {
            unlikePost(at: index)
        } else {
            likePost(at: index)
        }
    }
    
    func toggleShare(at index: Int) {
        guard let post = post(at: index) else {
            return
        }
        
        if post.isShared {
            unsharePost(at: index)
        } else {
            sharePost(at: index)
        }
    }
    
    func post(at index: Int) -> PostDiscoveryData? {
        guard posts.isValid(index) else {
            return nil
        }
        
        return posts[index]
    }
    
    func RecommendedPost(at index: Int, at section: Int) -> PostDiscoveryData? {
        
        if recommmendedPost.count < 1 {
            return nil
        }
        let TalentList = recommmendedPost.first?.getTalentList(withPostDiscoveryData: recommmendedPost)
        
        if (TalentList?.count)! < 1 {
            return nil
        }
        
        let Talent = TalentList?.talents[section]
        
        let recommendedPost = recommmendedPost.first?.getByTalent(withPostDiscoveryData: recommmendedPost, ofTalent: Talent!)
        guard (recommendedPost?.isValid(index))! else {
            return nil
        }
        
        return recommendedPost?[index]
    }
    
    func initialPostWillShow() {
        guard !isShownInitialPost, posts.isValid(initialPostIndex) else {
            return
        }
        
        view.showInitialPost(at: initialPostIndex)
        isShownInitialPost = true
    }
}

extension PostDiscoveryPresenter: PostDiscoveryInteractorOutput {
    

    func postDiscovertDidLoadTalents(withTalentList talentList: TalentList) {
       view.showInitialLoadView()
    }
    
 
    func postRecommendedDiscoveryDidRefresh(with data: [PostDiscoveryData]) {
        view.hideInitialLoadView()
        view.hideRefreshView()
        
        recommmendedPost.removeAll()
        recommmendedPost.append(contentsOf: data)
        
        if posts.count == 0 {
            view.showEmptyView()
        }
        
        view.didRefresh(with: nil)
        view.reloadView()
    }
    
    func postRecommendedDiscoveryDidLoadMores(with data: [PostDiscoveryData]) {
        view.didLoadMore(with: nil)
        
        guard data.count > 0 else {
            return
        }
        
        recommmendedPost.append(contentsOf: data)
        view.reloadView()
    }
    
    func postDiscoveryDidRefresh(with data: [PostDiscoveryData]) {
        view.hideInitialLoadView()
        view.hideRefreshView()
        
        posts.removeAll()
        posts.append(contentsOf: data)
        
        if posts.count == 0 {
            view.showEmptyView()
        }
        
        view.didRefresh(with: nil)
        view.reloadView()
    }
    
    func postDiscoveryDidLoadMore(with data: [PostDiscoveryData]) {
        view.didLoadMore(with: nil)
        
        guard data.count > 0 else {
            return
        }
        
        posts.append(contentsOf: data)
        view.reloadView()
    }
    
    func postDiscoveryDidRefresh(with error: PostServiceError) {
        view.hideInitialLoadView()
        view.hideRefreshView()
        
        view.didRefresh(with: error.message)
    }
    
    func postDiscoveryDidLoadMore(with error: PostServiceError) {
         view.didLoadMore(with: error.message)
    }
    
    func postDiscoveryDidLike(with postId: String, and error: PostServiceError?) {
        view.didLike(with: error?.message)
    }
    
    func postDiscoveryDidUnlike(with postId: String, and error: PostServiceError?) {
        view.didUnlike(with: error?.message)
    }
    
    func postDiscoveryDidShare(with postId: String, and error: PostServiceError?) {
        view.didLike(with: error?.message)
    }
    
    func postDiscoveryDidUnshare(with postId: String, and error: PostServiceError?) {
        view.didUnlike(with: error?.message)
    }
    
}
