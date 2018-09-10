//
//  VideoFeedPresenterInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 30/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol VideoFeedPresenterInterface: BaseModulePresenter, BaseModuleInteractable {
    
    var identifier: String! { set get }
    var talentSource: Talent! { set get }
    var knowledgeSource: knowledgeSource! { set get }
    var videos: [VideoFeedData]! { set get }
    var limit: UInt! { set get }
}
