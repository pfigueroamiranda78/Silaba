//
//  VideoPostUploadWireframeInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/07/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit

protocol VideoPostUploadWireframeInterface: class {
    
    var root: RootWireframeInterface? { set get }
    
    init(root: RootWireframeInterface?, delegate:VideoPostUploadModuleDelegate?, view: VideoPostUploadViewInterface, item: VideoPostUploadItem)
    
    func attach(with controller: UIViewController, in parent: UIViewController)
    func detach(with controller: UIViewController)
}
