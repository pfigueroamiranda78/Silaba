//
//  VideoPostUploadWireframe.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/07/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit


class VideoPostUploadWireframe: VideoPostUploadWireframeInterface {
    
    var root: RootWireframeInterface?
    
    required init(root: RootWireframeInterface?, delegate: VideoPostUploadModuleDelegate?, view: VideoPostUploadViewInterface, item: VideoPostUploadItem) {
        self.root = root
        
        let auth = AuthSession()
        let fileService = FileServiceProvider(session: auth)
        let postService = PostServiceProvider(session: auth)
        let machineLearningService = MachineLearningServicesProvider(with: item.recognize_type)
        let youTubeService = YouTubeServicesProvider()
        let interactor = VideoPostUploadInteractor(fileService: fileService, postService: postService, machineLearningService: machineLearningService, youTubeService: youTubeService)
        let presenter = VideoPostUploadPresenter()
        
        interactor.output = presenter
        view.presenter = presenter
        
        presenter.item = item
        presenter.view = view
        presenter.interactor = interactor
        presenter.moduleDelegate = delegate
        presenter.wireframe = self
    }
    
    func attach(with controller: UIViewController, in parent: UIViewController) {
        parent.view.addSubview(controller.view)
        parent.addChildViewController(controller)
        controller.didMove(toParentViewController: parent)
    }
    
    func detach(with controller: UIViewController) {
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
        controller.didMove(toParentViewController: nil)
    }
}
