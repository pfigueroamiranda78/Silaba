//
//  NewsFeedServiceProvider.swift
//  Photostream
//
//  Created by Mounir Ybanez on 22/10/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct NewsFeedServiceProvider: NewsFeedService {
    
    var session: AuthSession
    
    init(session: AuthSession) {
        self.session = session
        Database.database().reference().keepSynced(true)
    }
    
    func fetchNewsFeed(offset: String, limit: UInt, callback: ((NewsFeedServiceResult) -> Void)?) {
        var result = NewsFeedServiceResult()
        guard session.isValid else {
            result.error = .authenticationNotFound(message: "Authentication not found")
            callback?(result)
            return
        }
        
        let uid = session.user.id
        let rootRef = Database.database().reference()
        let feedRef = rootRef.child("user-feed").child(uid)
        let postsRef = feedRef.child("posts")
        var query = postsRef.queryOrderedByKey()
        
        if !offset.isEmpty {
            query = query.queryEnding(atValue: offset)
        }
        
        query = query.queryLimited(toLast: limit + 1)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            guard snapshot.childrenCount > 0 else {
                result.posts = PostList()
                callback?(result)
                return
            }
            
            var posts = [Post]()
            var users = [String: User]()
            
            for child in snapshot.children {
                var timestamp:Double = 0
                var original_post_id: String = ""
                guard let post = child as? DataSnapshot else {
                    continue
                }
                
                var postKey = post.key
                
                let hasSharedChild = snapshot.hasChild("\(postKey)/shared")
                if (hasSharedChild) {
                    timestamp = (snapshot.childSnapshot(forPath: "\(postKey)/shared/timestamp").value as? Double)!
                    original_post_id = (snapshot.childSnapshot(forPath: "\(postKey)/shared/postid").value as? String)!
                    postKey = original_post_id
                }
                let postRef = rootRef.child("posts").child(postKey)
                
                postRef.observeSingleEvent(of: .value, with: { (postSnapshot) in
                    guard let userId = postSnapshot.childSnapshot(forPath: "uid").value as? String,
                        let photoId = postSnapshot.childSnapshot(forPath: "photo_id").value as? String else {
                        return
                    }
                    
                    let userRef = rootRef.child("users").child(userId)
                    let photoRef = rootRef.child("photos").child(photoId)
                    let likesRef = rootRef.child("post-like/\(postKey)/likes")
                    let sharesRef = rootRef.child("post-share/\(postKey)/shares")
                    
                    userRef.observeSingleEvent(of: .value, with: { (userSnapshot) in
                        photoRef.observeSingleEvent(of: .value, with: { (photoSnapshot) in
                            likesRef.observeSingleEvent(of: .value, with: { (likesSnapshot) in
                                sharesRef.observeSingleEvent(of: .value, with: { (sharesSnapshot) in
                                    if users[userId] == nil {
                                        users[userId] = User(with: userSnapshot, exception: "email")
                                    }
                                    
                                    var post = Post(with: postSnapshot)
                                    post.photo = Photo(with: photoSnapshot)
                                    post.isVideo = post.photo.isVideo
                                    
                                    if likesSnapshot.hasChild(uid) {
                                        post.isLiked = true
                                    }
                                    
                                    if sharesSnapshot.hasChild(uid) {
                                        post.isShared = true
                                        if (hasSharedChild) {
                                            post.timestamp = timestamp
                                            post.id = original_post_id
                                        }
                                        
                                    }
                                    
                                   
                                    
                                    posts.append(post)
                                    
                                    let postCount = UInt(posts.count)
                                    if postCount == snapshot.childrenCount {
                                        if postCount == limit + 1 {
                                            let removedPost = posts.removeFirst()
                                            result.nextOffset = removedPost.id
                                        }
                                        
                                        let sorted = posts.sorted(by: { post1, post2 -> Bool in
                                            return post1.timestamp > post2.timestamp
                                        })
                                        
                                        var postList = PostList()
                                        postList.posts = sorted
                                        postList.users = users
                                        result.posts = postList
                                        
                                        callback?(result)
                                    }
                                })
                            })
                        })
                    })
                })
            }
        })
    }
}
