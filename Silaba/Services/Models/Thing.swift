//
//  Thing.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 5/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import Firebase

struct Thing {

    var id: String
    var timestamp: Double
    var count: Int
    
    init() {
        id = ""
        timestamp = 0
        count = 0
    }
}

extension Thing: SnapshotParser {
    
    init(with snapshot: DataSnapshot, exception: String...) {
        self.init()
        
        if snapshot.exists() {
            id = snapshot.key
            timestamp = 0
        }
        
        if snapshot.hasChildren() {
            count = Int(snapshot.childrenCount)
            for child in snapshot.children  {
                guard let post = child as? DataSnapshot else {
                    continue
                }
                timestamp = (post.value as? Double)!
            }
        }

    }
}


struct ThingList {
    
    var things: [Thing]
    
    var count: Int {
        return things.count
    }
    
    init() {
        things = [Thing]()
        
    }
}

extension ThingList {
    
    mutating func orderByTimeStamp() {
        self.things = things.sorted(by: { thing1, thing2 -> Bool in
            return thing1.count > thing2.count
        })
    }
}
