//
//  VideoCaptureWireframeInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 11/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit

protocol VideoCaptureWireframeInterface: class {
    
    var root: RootWireframeInterface? { set get }
    
    init(root: RootWireframeInterface?, delegate: VideoCaptureModuleDelegate?, view: VideoCaptureViewInterface)
    
    func attachRoot(with controller: UIViewController, in window: UIWindow)
    
    func present(with controller: UIViewController?, from parent: UIViewController?, animated: Bool, completion: (() -> Void)?)
}
