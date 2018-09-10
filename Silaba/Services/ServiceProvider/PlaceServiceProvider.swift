//
//  PlaceServiceProvider.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 15/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation


//
//  PostServiceProvider.swift
//  Photostream
//
//  Created by Mounir Ybanez on 06/08/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

struct PlaceServiceProvider: PlaceService {
    
    func fetchPlaceInfo(id: String, callback: ((PlaceServiceResult) -> Void)?) {
        var result = PlaceServiceResult()
        
        guard session.isValid else {
            result.error = .authenticationNotFound(message: "Authentication not found")
            callback?(result)
            return
        }
        
        let path1 = "places/\(id.replaceFirstOccurrence(of: " ", to: ""))"
        let rootRef = Database.database().reference()
        let placeRef = rootRef.child(path1)
        
        placeRef.observeSingleEvent(of: .value, with: { placeSnapshot in
            guard placeSnapshot.exists(),
                let _ = placeSnapshot.childSnapshot(forPath: "uid").value as? String else {
                    result.error = .failedToFetch(message: "Place not found")
                    callback?(result)
                    return
            }
            
            let place = Place(with: placeSnapshot)
            result.place = place
            callback?(result)
            return
        })
    }
    
    var session: AuthSession
    
    init(session: AuthSession) {
        self.session = session
        Database.database().reference().keepSynced(true)
    }
    
}
