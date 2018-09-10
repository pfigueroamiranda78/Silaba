//
//  VideoFeedData.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 30/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol VideoFeedData {
    
    var id: String { set get }
    var content: String { set get }
    var timestamp: Double { set get }
    var authorName: String { set get }
    var authorId: String { set get }
    var authorAvatar: String { set get }
}

struct VideoFeedDataItem: VideoFeedData {
    
    var id: String = ""
    var content: String = ""
    var timestamp: Double = 0
    var authorName: String = ""
    var authorId: String = ""
    var authorAvatar: String = ""
}

extension Array where Element: VideoFeedData {
    
    func indexOf(comment id: String) -> VideoFeedData? {
        let index = self.index { item -> Bool in
            return item.id == id
        }
        
        guard index != nil else {
            return nil
        }
        
        return self[index!]
    }
}
