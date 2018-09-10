//
//  Talent.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 21/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import Firebase

struct Talent {
    
    var id: String
    var competencia: String
   
    
    init() {
        id = ""
        competencia = ""
        
    }
}

extension Talent: SnapshotParser {
    
    init(with snapshot: DataSnapshot, exception: String...) {
        self.init()
        
        if snapshot.hasChild("Nombre") && !exception.contains("Nombre") {
            id = snapshot.childSnapshot(forPath: "Nombre").value as! String
        }
        
        if snapshot.hasChild("Competencia") && !exception.contains("Competencia") {
            competencia = snapshot.childSnapshot(forPath: "Competencia").value as! String
        }
    }
}


struct TalentList {
    
    var talents: [Talent]
    
    var count: Int {
        return talents.count
    }
    
    init() {
        talents = [Talent]()
        
    }
}
