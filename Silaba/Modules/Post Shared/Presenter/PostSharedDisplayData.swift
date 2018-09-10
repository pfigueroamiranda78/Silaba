//
//  PostSharedDisplayData.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//


import Foundation
protocol PostSharedDisplayData: PostSharedData {
    
    var isBusy: Bool { set get }
}

struct PostSharedDisplayDataItem: PostSharedDisplayData {
    
    var userId: String = ""
    var displayName: String = ""
    var avatarUrl: String = ""
    var isFollowing: Bool = false
    var isMe: Bool = false
    var isBusy: Bool = false
}
