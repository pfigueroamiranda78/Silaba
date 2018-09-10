//
//  PhotoCaptureWireframe.swift
//  Photostream
//
//  Created by Mounir Ybanez on 10/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import UIKit

class PhotoCaptureWireframe: PhotoCaptureWireframeInterface {

    var root: RootWireframeInterface?
    
    required init(root: RootWireframeInterface?, delegate: PhotoCaptureModuleDelegate?, view: PhotoCaptureViewInterface) {
        self.root = root
        
        let presenter = PhotoCapturePresenter()
        presenter.moduleDelegate = delegate
        presenter.view = view
        presenter.wireframe = self
        let auth = AuthSession()
        let service = PlaceServiceProvider(session: auth)
        let machineLearningService = MachineLearningServicesProvider(with: "objeto")
        let translatorService = GoogleTranslator()
        let interactor = PhotoCaptureInteractor(service: service, machineLearningService: machineLearningService, translatorService: translatorService)
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
