//
//  Place.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 15/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import Firebase

struct Place {
    
    var id: String
    var userId: String
    var banner: String
    var name: String
    var url: String
    var services_url: String
    
    
    init() {
        id = ""
        userId = ""
        banner = ""
        name = ""
        url = ""
        services_url = ""
    }
}

extension Place: SnapshotParser {
    
    init(with snapshot: DataSnapshot, exception: String...) {
        self.init()
        
        if snapshot.hasChild("id") && !exception.contains("id") {
            id = snapshot.childSnapshot(forPath: "id").value as! String
        }
        
        if snapshot.hasChild("uid") && !exception.contains("uid") {
            userId = snapshot.childSnapshot(forPath: "uid").value as! String
        }
        
        if snapshot.hasChild("banner") && !exception.contains("banner") {
            banner = snapshot.childSnapshot(forPath: "banner").value as! String
        }
        
        if snapshot.hasChild("url") && !exception.contains("url") {
            url = snapshot.childSnapshot(forPath: "url").value as! String
        }
        
        if snapshot.hasChild("services_url") && !exception.contains("services_url") {
            services_url = snapshot.childSnapshot(forPath: "services_url").value as! String
        }
    }
}


struct PlaceList {
    
    var places: [Place]
   
    var count: Int {
        return places.count
    }
    
    init() {
        places = [Place]()
      
    }
}

