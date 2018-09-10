//
//  PhotoPickerWireframe.swift
//  Photostream
//
//  Created by Mounir Ybanez on 09/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import UIKit

class PhotoPickerWireframe: PhotoPickerWireframeInterface {

    lazy var dependencies: [PhotoPickerModuleDependency]? = [PhotoPickerModuleDependency]()
    var root: RootWireframeInterface?
    
    required init(root: RootWireframeInterface?, delegate: PhotoPickerModuleDelegate?, view: PhotoPickerViewInterface) {
        self.root = root
    
        let presenter = PhotoPickerPresenter()
        presenter.moduleDelegate = delegate
        presenter.view = view
        presenter.wireframe = self
        let auth = AuthSession()
        let service = TalentServiceProvider(session: auth)
        let service_thing = ThingServiceProvider(session: auth)
        let service_user = UserServiceProvider(session: auth)
        let interactor = PhotoPickerInteractor(service: service, service_thing: service_thing, service_users: service_user)
    
        view.presenter = presenter
        presenter.interactor = interactor
        interactor.output = presenter
    }
    
    func attachRoot(with controller: UIViewController, in window: UIWindow) {
        root?.showRoot(with: controller, in: window)
    }
    
    func present(with controller: UIViewController?, from: UIViewController?, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard controller != nil else {
            return
        }
        
        from?.present(controller!, animated: animated, completion: completion)
    }
    
    func dismiss(with controller: UIViewController?, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard controller != nil else {
            return
        }
        
        controller!.dismiss(animated: animated, completion: completion)
    }
    
    func dependency<T>() -> T? {
        guard dependencies != nil, dependencies!.count > 0 else {
            return nil
        }
        
        let result = dependencies!.filter { (dependency) -> Bool in
            return type(of: dependency) == T.self
        }
        
        guard result.count > 0 else {
            return nil
        }
        
        return result[0] as? T
    }
}
