//
//  PostSharedModule.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation


protocol PostSharedModuleInterface: BaseModuleInterface {
    
    var shareCount: Int { get }
    
    func viewDidLoad()
    func share(at index: Int) -> PostSharedDisplayData?
    
    func initialLoad()
    func refresh()
    func loadMore()
    
    func toggleFollow(at index: Int)
    func follow(at index: Int)
    func unfollow(at index: Int)
}

protocol PostSharedBuilder: BaseModuleBuilder {
    
    func build(root: RootWireframe?, postId: String)
}

class PostSharedModule: BaseModule, BaseModuleInteractable {
    
    typealias ModuleView = PostSharedScene
    typealias ModuleInteractor = PostSharedInteractor
    typealias ModulePresenter = PostSharedPresenter
    typealias ModuleWireframe = PostSharedWireframe
    
    var view: ModuleView!
    var interactor: ModuleInteractor!
    var presenter: ModulePresenter!
    var wireframe: ModuleWireframe!
    
    required init(view: ModuleView) {
        self.view = view
    }
}

extension PostSharedModule: PostSharedBuilder {
    
    func build(root: RootWireframe?) {
        let auth = AuthSession()
        let postService = PostServiceProvider(session: auth)
        let userService = UserServiceProvider(session: auth)
        interactor = PostSharedInteractor(postService: postService, userService: userService)
        presenter = PostSharedPresenter()
        wireframe = PostSharedWireframe(root: root)
        
        view.presenter = presenter
        interactor.output = presenter
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.wireframe = wireframe
    }
    
    func build(root: RootWireframe?, postId: String) {
        build(root: root)
        presenter.postId = postId
    }
}

