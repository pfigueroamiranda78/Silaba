//
//  VideoCaptureWireframe.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 11/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit

class VideoCaptureWireframe: VideoCaptureWireframeInterface {
    
    var root: RootWireframeInterface?
    
    required init(root: RootWireframeInterface?, delegate: VideoCaptureModuleDelegate?, view: VideoCaptureViewInterface) {
        self.root = root
        
        let presenter = VideoCapturePresenter()
        presenter.moduleDelegate = delegate
        presenter.view = view
        presenter.wireframe = self
        let auth = AuthSession()
        let service = PlaceServiceProvider(session: auth)
        let machineLearningService = MachineLearningServicesProvider(with: "objeto")
        let translatorService = GoogleTranslator()
        let interactor = VideoCaptureInteractor(service: service, machineLearningService: machineLearningService, translatorService: translatorService)
        interactor.output = presenter
        presenter.interactor = interactor
        view.presenter = presenter
        
    }
    
    func attachRoot(with controller: UIViewController, in window: UIWindow) {
        root?.showRoot(with: controller, in: window)
    }
    
    func present(with controller: UIViewController?, from parent: UIViewController?, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard controller != nil, parent != nil else {
            return
        }
        
        parent!.present(controller!, animated: animated, completion: completion)
    }
}

