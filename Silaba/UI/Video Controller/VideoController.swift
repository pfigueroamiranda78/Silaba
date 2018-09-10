//
//  CommentController.swift
//  Photostream
//
//  Created by Mounir Ybanez on 30/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import UIKit

protocol VideoControllerDelegate: class {
    
    func videoControllerDidWrite(with postId: String)
}

protocol VideoControllerInterface: BaseModuleWireframe {
    
    var identifier: String! { set get }
    var feed: VideoFeedPresenter! { set get }
    var shouldComment: Bool { set get }
    var delegate: VideoControllerDelegate? { set get }
    var talentSource: Talent! { set get }
    var knowledgeSource: knowledgeSource! { set get }
    
    func setupFeed()
   
}

@objc protocol VideoControllerAction: class {
    
    func back()
}

extension VideoControllerInterface {
    
    func setupModules() {
        setupFeed()
    }
}

class VideoController: UIViewController, VideoControllerInterface, VideoControllerAction {
   
    weak var delegate: VideoControllerDelegate?
    var style: WireframeStyle!
    var root: RootWireframe?
    var identifier: String!
    var shouldComment: Bool = false
    var talentSource: Talent!
    var knowledgeSource: knowledgeSource!
    var feed: VideoFeedPresenter!
   
    var isModuleSetup: Bool = false {
        didSet {
            guard !oldValue, isModuleSetup else {
                return
            }
            setupModules()

        }
    }
    
    required convenience init(root: RootWireframe?) {
        self.init()
        self.root = root
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.white
        
        title = "Videos"
        
        let barItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back_nav_icon"), style: .plain, target: self, action: #selector(self.back))
        navigationItem.leftBarButtonItem = barItem
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isModuleSetup = true
    }
    
    func back() {
        var property = WireframeExitProperty()
        property.controller = self
        exit(with: property)
    }
    
    func setupFeed() {
        let module = VideoFeedModule()
        module.build(root: root, identifier: identifier, talentSource: self.talentSource, knowledgeSource: knowledgeSource)
        module.wireframe.style = .attach
        feed = module.presenter
        
        let controller = module.view.controller!
        controller.view.frame.origin = .zero
        controller.view.frame.size = view.frame.size
        
        var property = WireframeEntryProperty()
        property.controller = controller
        property.parent = self
        
        module.wireframe.enter(with: property)
    }
}
