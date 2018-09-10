//
//  PostSharedData.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation


protocol PostSharedData {
    
    var userId: String { set get }
    var displayName: String { set get }
    var avatarUrl: String { set get }
    var isFollowing: Bool { set get }
    var isMe: Bool { set get }
}

struct PostSharedDataItem: PostSharedData {
    
    var userId: String = ""
    var displayName: String = ""
    var avatarUrl: String = ""
    var isFollowing: Bool = false
    var isMe: Bool = false
}
