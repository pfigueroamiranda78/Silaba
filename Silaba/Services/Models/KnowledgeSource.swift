//
//  KnowledgeSource.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 4/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Firebase

struct KnowledgeSrc {
    
    var id: String = ""
    var timestamp: Double = 0
    var type: knowledgeSource = .recommend
    var url: String = ""
}

enum knowledgeSource: String {
    case videos
    case traduction
    case general
    case silabers
    case recommend
    case wikipedia
    case opendata
    case realityAugmented
}

struct KnowledgeSrcList {
    
    var knowledgeSources = [KnowledgeSrc]()
    var count: Int {
        return knowledgeSources.count
    }
}

extension KnowledgeSrc: SnapshotParser {
    
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
            case "general" :
                type = .general
                
            case "silabers" :
                type = .silabers
                
            case "recommend" :
                type = .recommend
                
            case "wikipedia" :
                type = .wikipedia
                
            case "opendata" :
                type = .opendata
                
            case "realityAugmented" :
                type = .realityAugmented
            default:
                 type = .recommend
            }
        }
    }
}
