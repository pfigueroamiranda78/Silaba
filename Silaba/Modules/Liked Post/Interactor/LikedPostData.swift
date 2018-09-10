//
//  LikedPostData.swift
//  Photostream
//
//  Created by Mounir Ybanez on 19/01/2017.
//  Copyright © 2017 Mounir Ybanez. All rights reserved.
//

protocol LikedPostData {

    var id: String { set get }
    var message: String { set get }
    var timestamp: Double { set get }
    
    var photoUrl: String { set get }
    var photoWidth: Int { set get }
    var photoHeight: Int { set get }
    
    var likes: Int { set get }
    var shares: Int { set get }
    var comments: Int { set get }
    var isLiked: Bool { set get }
    var isShared: Bool { set get }
    var isVideo: Bool { set get }
    
    var userId: String { set get }
    var avatarUrl: String { set get }
    var displayName: String { set get }
    
    var recognized_type: String { set get }
    var identifier: String { set get }
    var confidence: Float { set get }
    var talent: Talent { set get }
    
}

struct LikedPostDataItem: LikedPostData {
    
    var id: String = ""
    var message: String = ""
    var timestamp: Double = 0
    
    var photoUrl: String = ""
    var photoWidth: Int = 0
    var photoHeight: Int = 0
    
    var likes: Int = 0
    var comments: Int = 0
    var isLiked: Bool = false
    var shares: Int = 0
    var isShared: Bool = false
    var isVideo: Bool = false
    
    var userId: String = ""
    var avatarUrl: String = ""
    var displayName: String = ""
    var identifier: String = ""
    var recognized_type: String = ""
    var talent: Talent = Talent()
    var confidence: Float = 0
}
