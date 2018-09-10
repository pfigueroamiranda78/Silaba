//
//  VideoFeedExtension.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 30/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

import DateTools

extension VideoFeedModule {
    
    convenience init() {
        self.init(view: VideoFeedViewController())
    }
}

extension VideoFeedDataItem: VideoListCellItem { }

extension VideoFeedScene {
    
    func adjust(bottomInset: CGFloat) {
        guard let view = controller?.view as? UITableView else {
            return
        }
        
        view.scrollIndicatorInsets.bottom += bottomInset
        view.contentInset.bottom += bottomInset
    }
    
    func scrollToTop(animated: Bool = false) {
        guard let view = controller?.view as? UITableView else {
            return
        }
        
        let indexPath = IndexPath(row: 0, section: 0)
        view.scrollToRow(at: indexPath, at: .top, animated: animated)
    }
}

extension VideoFeedModuleInterface {
    
    func presentUserTimeline(at index: Int) {
        guard let presenter = self as? VideoFeedPresenter,
            let parent = presenter.view.controller,
            let comment = view(at: index) else {
                return
        }
        
        presenter.wireframe.showUserTimeline(from: parent, userId: comment.authorId)
    }
}

extension VideoFeedWireframeInterface {
    
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
