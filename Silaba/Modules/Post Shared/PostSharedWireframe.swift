//
//  PostSharedWirefrae.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol PostSharedWireframeInterface: BaseModuleWireframe { }

class PostSharedWireframe: PostSharedWireframeInterface {
    
    var root: RootWireframe?
    var style: WireframeStyle!
    
    required init(root: RootWireframe?) {
        self.root = root
    }
}
