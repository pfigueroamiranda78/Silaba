//
//  HomeViewController.swift
//  Photostream
//
//  Created by Mounir Ybanez on 15/08/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import UIKit

@objc protocol HomeViewControllerAction: class {
    
    func showPostComposer()
    func showPostDiscovery()
}

class HomeViewController: UITabBarController, HomeViewControllerAction {

    lazy var specialButton = UIButton()
    lazy var specialButton2 = UIButton()
    
    var specialIndex: Int? {
        didSet {
            guard let index = specialIndex else {
                specialButton.removeFromSuperview()
                return
            }
            
            guard tabBar.subviews.isValid(index) else {
                return
            }
            
            if specialButton.superview == nil {
                specialButton.backgroundColor = UIColor.clear
                specialButton.addTarget(self, action: #selector(self.showPostComposer), for: .touchUpInside)
                view.addSubview(specialButton)
            }
            
            let tabBarButtons = tabBar.subviews.filter { subview -> Bool in
                return subview.isUserInteractionEnabled
            }
            
            let subviews = tabBarButtons.sorted { (button1, button2) -> Bool in
                return button1.frame.origin.x < button2.frame.origin.x
            }
            
            let subview = subviews[index]
            let point = subview.superview!.convert(subview.frame.origin, to: view)
            let size = subview.frame.size
            let frame = CGRect(origin: point, size: size)
            specialButton.frame = frame
            
            view.bringSubview(toFront: specialButton)
        }
    }
    
    var specialIndex2: Int? {
        didSet {
            guard let index = specialIndex2 else {
                specialButton2.removeFromSuperview()
                return
            }
            
            guard tabBar.subviews.isValid(index) else {
                return
            }
            
            if specialButton2.superview == nil {
                specialButton2.backgroundColor = UIColor.clear
                specialButton2.addTarget(self, action: #selector(self.showPostDiscovery), for: .touchUpInside)
                view.addSubview(specialButton2)
            }
            
            let tabBarButtons = tabBar.subviews.filter { subview -> Bool in
                return subview.isUserInteractionEnabled
            }
            
            let subviews = tabBarButtons.sorted { (button1, button2) -> Bool in
                return button1.frame.origin.x < button2.frame.origin.x
            }
            
            let subview = subviews[index]
            let point = subview.superview!.convert(subview.frame.origin, to: view)
            let size = subview.frame.size
            let frame = CGRect(origin: point, size: size)
            specialButton2.frame = frame
            
            view.bringSubview(toFront: specialButton2)
        }
    }
    
    var presenter: HomePresenterInterface!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        specialIndex = 1
        specialIndex2 = 2
    }
    
    func showPostDiscovery() {
        presenter.presentPostDiscovery()
    }
    
    func showPostComposer() {
        presenter.presentPostComposer()
    }
}

extension HomeViewController: HomeViewInterface {
    
    var controller: UIViewController? {
        return self
    }
}
