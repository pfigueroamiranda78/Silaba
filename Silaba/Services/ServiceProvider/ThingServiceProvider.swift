//
//  ThingServiceProvider.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 5/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

struct ThingServiceProvider: ThingService {
    
    func fetchThingAll(ofTalentList talentList: TalentList, limit: UInt, callback: ((ThingServiceResult) -> Void)?) {
        var result = ThingServiceResult()
        
        guard session.isValid else {
            result.error = .authenticationNotFound(message: "Authentication not found")
            callback?(result)
            return
        }
        var things = [Thing]()
        
        let rootRef = Database.database().reference()
        var nTalents = talentList.talents.count
        
        for talent in talentList.talents {
            let path1 = "talent-thing-post/\(talent.id)"
            var thingRef = rootRef.child(path1).queryOrderedByKey()
            thingRef = thingRef.queryLimited(toLast: limit + 1)
            
            thingRef.observe(.value, with: { thingSnapshot in
                
                for child in thingSnapshot.children {
                    guard let thing = child as? DataSnapshot else {
                        continue
                    }
                    
                    let the_thing = Thing(with: thing)
                    things.append(the_thing)
        
                }
                nTalents = nTalents - 1
                if (nTalents == 1) {
                    var thingList = ThingList()
                    thingList.things = things
                    thingList.orderByTimeStamp()
                    result.things = thingList
                    callback?(result)
                    return
                }
            })
        }
        
    }
    
    var session: AuthSession
    
    init(session: AuthSession) {
        self.session = session
        Database.database().reference().keepSynced(true)
    }
    
}
