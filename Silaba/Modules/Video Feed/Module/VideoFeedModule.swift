//
//  VideoFeedModule.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 30/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

class VideoFeedModule: BaseModule, BaseModuleInteractable {
    
    typealias ModuleWireframe = VideoFeedWireframe
    typealias ModuleView = VideoFeedScene
    typealias ModulePresenter = VideoFeedPresenter
    typealias ModuleInteractor = VideoFeedInteractor
    
    var view: ModuleView!
    var interactor: ModuleInteractor!
    var presenter: ModulePresenter!
    var wireframe: ModuleWireframe!
    
    required init(view: ModuleView) {
        self.view = view
    }
}

protocol VideoFeedBuilder: BaseModuleBuilder {
    
    func build(root: RootWireframe?, identifier: String, talentSource: Talent, knowledgeSource: knowledgeSource)
}

extension VideoFeedModule: VideoFeedBuilder {
    
    func build(root: RootWireframe?) {
        let service = YouTubeServicesProvider()
        interactor = VideoFeedInteractor(service: service)
        presenter = VideoFeedPresenter()
        wireframe = VideoFeedWireframe(root: root)
        
        presenter.interactor = interactor
        presenter.view = view
        presenter.wireframe = wireframe
        
        interactor.output = presenter
        view.presenter = presenter
    }
    
    func build(root: RootWireframe?, identifier: String, talentSource: Talent,  knowledgeSource: knowledgeSource) {
        build(root: root)
        presenter.identifier = identifier
        presenter.talentSource = talentSource
        presenter.knowledgeSource = knowledgeSource
    }
}
