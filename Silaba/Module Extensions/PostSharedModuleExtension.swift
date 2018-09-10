//
//  PostSharedModuleExtension.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit

extension PostSharedModule {
    
    convenience init() {
        self.init(view: PostSharedViewController())
    }
}

extension PostSharedDisplayDataItem: UserTableCellItem { }

extension PostSharedModuleInterface {
    
    func presentUserTimeline(for index: Int) {
        guard let presenter = self as? PostSharedPresenter,
            let share = share(at: index) else {
                return
        }
        
        presenter.wireframe.showUserTimeline(
            from: presenter.view.controller,
            userId: share.userId
        )
    }
}

extension PostSharedWireframeInterface {
    
    func showUserTimeline(from parent: UIViewController?, userId: String) {
        let userTimeline = UserTimelineViewController()
        userTimeline.root = root
        userTimeline.style = .push
        userTimeline.userId = userId
        
        var property = WireframeEntryProperty()
        property.parent = parent
        property.controller = userTimeline
        
        userTimeline.enter(with: property)
    }
}
