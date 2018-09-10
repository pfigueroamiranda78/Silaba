//
//  PhotoShareWireframe.swift


import UIKit

class VideoShareWireframe: VideoShareWireframeInterface {
    
    var root: RootWireframeInterface?
    
    required init(root: RootWireframeInterface?, delegate: VideoShareModuleDelegate?, view: VideoShareViewInterface) {
        self.root = root
        
        let presenter = VideoSharePresenter()
        presenter.moduleDelegate = delegate
        presenter.view = view
        presenter.wireframe = self
        
        view.presenter = presenter
    }
    
    func attachRoot(with controller: UIViewController, in window: UIWindow) {
        root?.showRoot(with: controller, in: window)
    }
    
    func push(with controller: UIViewController?, from navigationController: UINavigationController?, animated: Bool) {
        guard controller != nil, navigationController != nil else {
            return
        }
        
        navigationController!.pushViewController(controller!, animated: animated)
    }
    
    func pop(from navigationController: UINavigationController?, animated: Bool) {
        guard navigationController != nil else {
            return
        }
        
        let _ = navigationController!.popViewController(animated: animated)
    }
    
    func dismiss(with controller: UIViewController?, animated: Bool, completion: (() -> Void)?) {
        guard controller != nil else {
            return
        }

        controller!.dismiss(animated: animated, completion: completion)
    }
}
