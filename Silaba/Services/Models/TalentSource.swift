//
//  TalentSource.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 5/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Firebase

struct TalentSrc {
    
    var id: String = ""
    var timestamp: Double = 0
    var type: talentSource = .general
    var url: String = ""
}

enum talentSource: String {
    case numbers
    case history
    case art
    case science
    case technology
    case general
}
struct TalentSrcList {
    
    var talentSources = [TalentSrc]()
    var count: Int {
        return talentSources.count
    }
}

extension TalentSrc: SnapshotParser {
    
    init(with snapshot: DataSnapshot, exception: String...) {
        self.init()
        
        
        
        if snapshot.hasChild("id") && !exception.contains("id") {
            id = snapshot.childSnapshot(forPath: "id").value as! String
        }
        
        if snapshot.hasChild("timestamp") && !exception.contains("timestamp") {
            timestamp = snapshot.childSnapshot(forPath: "timestamp").value as! Double
            timestamp = timestamp / 1000
        }
        
        if snapshot.hasChild("url") && !exception.contains("url") {
            url = snapshot.childSnapshot(forPath: "url").value as! String
        }
        
        if snapshot.hasChild("type") && !exception.contains("type") {
            let typeString = snapshot.childSnapshot(forPath: "type").value as! String
            
            switch typeString.lowercased() {
            case "numbers" :
                type = .numbers
                
            case "history" :
                type = .history
                
            case "art" :
                type = .art
                
            case "science" :
                type = .science
                
            case "technology" :
                type = .technology
                
            case "general" :
                type = .general
        
            default:
                type = .general
            }
        }
    }
}

