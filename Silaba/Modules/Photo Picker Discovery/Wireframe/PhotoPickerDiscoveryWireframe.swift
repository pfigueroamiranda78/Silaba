//
//  PhotoPickerDiscoveryWireframe.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 20/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit

class PhotoPickerDiscoveryWireframe: PhotoPickerDiscoveryWireframeInterface {
    
    lazy var dependencies: [PhotoPickerDiscoveryModuleDependency]? = [PhotoPickerDiscoveryModuleDependency]()
    var root: RootWireframeInterface?
    
    required init(root: RootWireframeInterface?, delegate: PhotoPickerDiscoveryModuleDelegate?, view: PhotoPickerDiscoveryViewInterface) {
        self.root = root
        
        let auth = AuthSession()
        let service = TalentServiceProvider(session: auth)
        let interactor = PhotoPickerDiscoveryInteractor(service: service)
        
        let presenter = PhotoPickerDiscoveryPresenter()
        presenter.moduleDelegate = delegate
        presenter.view = view
        presenter.wireframe = self
        presenter.interactor = interactor
        view.presenter = presenter
        interactor.output = presenter
        interactor.fetchTalentAll()
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

