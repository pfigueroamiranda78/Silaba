//
//  Post.swift
//  Photostream
//
//  Created by Mounir Ybanez on 06/08/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import Foundation
import Firebase

struct Post {
    
    var id: String
    var userId: String
    var timestamp: Double
    var likesCount: Int
    var commentsCount: Int
    var sharesCount: Int
    var isLiked: Bool
    var isShared: Bool
    var isVideo: Bool
    var message: String
    var photo: Photo
    var model: String
    var visual_identifier1: MachineLearning
    var visual_identifier2: MachineLearning
    var talent: Talent
    
    
    init() {
        id = ""
        userId = ""
        timestamp = 0
        message = ""
        commentsCount = 0
        likesCount = 0
        isLiked = false
        sharesCount = 0
        isShared = false
        photo = Photo()
        isVideo = false
        model = ""
        visual_identifier1 = MachineLearning()
        visual_identifier2 = MachineLearning()
        talent = Talent()
    }
}

extension Post: SnapshotParser {
    
    init(with snapshot: DataSnapshot, exception: String...) {
        self.init()
        
        if snapshot.hasChild("id") && !exception.contains("id") {
            id = snapshot.childSnapshot(forPath: "id").value as! String
        }
        
        if snapshot.hasChild("uid") && !exception.contains("uid") {
            userId = snapshot.childSnapshot(forPath: "uid").value as! String
        }
        
        if snapshot.hasChild("timestamp") && !exception.contains("timestamp") {
            timestamp = snapshot.childSnapshot(forPath: "timestamp").value as! Double
            timestamp = timestamp / 1000
        }
        
        if snapshot.hasChild("likes_count") && !exception.contains("likes_count") {
            likesCount = snapshot.childSnapshot(forPath: "likes_count").value as! Int
        }
        
        if snapshot.hasChild("shares_count") && !exception.contains("shares_count") {
            sharesCount = snapshot.childSnapshot(forPath: "shares_count").value as! Int
        }
        
        if snapshot.hasChild("comments_count") && !exception.contains("comments_count") {
            commentsCount = snapshot.childSnapshot(forPath: "comments_count").value as! Int
        }
        
        if snapshot.hasChild("message") && !exception.contains("message") {
            message = snapshot.childSnapshot(forPath: "message").value as! String
        }
        
        if snapshot.hasChild("visual_reconigzed_identifier1") && !exception.contains("visual_reconigzed_identifier1") {
            visual_identifier1.identifier = snapshot.childSnapshot(forPath: "visual_reconigzed_identifier1").value as! String
        }
        
        if snapshot.hasChild("visual_reconigzed_identifier2") && !exception.contains("visual_reconigzed_identifier2") {
            visual_identifier2.identifier = snapshot.childSnapshot(forPath: "visual_reconigzed_identifier2").value as! String
        }
        
        if snapshot.hasChild("visual_reconigzed_identificador1") && !exception.contains("visual_reconigzed_identificador1") {
            visual_identifier1.identificador = snapshot.childSnapshot(forPath: "visual_reconigzed_identificador1").value as! String
        }
        
        if snapshot.hasChild("visual_reconigzed_identificador2") && !exception.contains("visual_reconigzed_identificador2") {
            visual_identifier2.identificador = snapshot.childSnapshot(forPath: "visual_reconigzed_identificador2").value as! String
        }
        
        if snapshot.hasChild("visual_reconigzed_confidence1") && !exception.contains("visual_reconigzed_confidence1") {
            if let val = snapshot.childSnapshot(forPath: "visual_reconigzed_confidence1").value as? Float {
                visual_identifier1.confidence = (val as Float?)!
            }
        }
        
        if snapshot.hasChild("visual_reconigzed_confidence2") && !exception.contains("visual_reconigzed_confidence2") {
            if let val = snapshot.childSnapshot(forPath: "visual_reconigzed_confidence2").value as? Float {
                visual_identifier2.confidence = (val as Float?)!
            }
        }
        
        if snapshot.hasChild("model") && !exception.contains("model") {
            if snapshot.hasChild("model") && !exception.contains("model") {
                model  = snapshot.childSnapshot(forPath: "model").value as! String
            }
        }
        
        if snapshot.hasChild("talent") && !exception.contains("talent") {
            if snapshot.hasChild("talent") && !exception.contains("talent") {
                let talentId  = snapshot.childSnapshot(forPath: "talent").value as! String
                var postTalent = Talent()
                postTalent.id = talentId
                talent = postTalent
            }
        }
    }
}

extension Post
{
    func identificador()->String {
        if (visual_identifier1.confidence > visual_identifier2.confidence) {
            return visual_identifier1.identificador
        } else {
            return visual_identifier2.identificador
        }
    }
    
    func confidence()->Float {
        if (visual_identifier1.confidence > visual_identifier2.confidence) {
            return visual_identifier1.confidence
        } else {
            return visual_identifier2.confidence
        }
    }
}

struct PostList {
    
    var posts: [Post]
    var users: [String: User]
    var count: Int {
        return posts.count
    }
    
    init() {
        posts = [Post]()
        users = [String: User]()
    }
    
    subscript (index: Int) -> (Post, User)? {
        if posts.isValid(index) {
            let post = posts[index]
            if let user = users[post.userId] {
                return (post, user)
            }
        }
        return nil
    }
}
