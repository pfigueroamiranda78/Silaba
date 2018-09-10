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

struct PostServiceProvider: PostService {


    var session: AuthSession

    init(session: AuthSession) {
        self.session = session
         Database.database().reference().keepSynced(true)
    }

    func fetchPosts(userId: String, offset: String, limit: UInt, callback: ((PostServiceResult) -> Void)?) {
        let path = "user-post/\(userId)/posts"
        fetchUserPosts(path: path, offset: offset, limit: limit, callback: callback)
    }
    
    func getUserFromUsername(of usersname: [String], callback: (([User]) -> Void)?) {
        let uid = session.user.id
        let rootRef = Database.database().reference()
        let path0 = "user-following/\(uid)/following"
        var users = [User]()
        var userCount = 0
        
        let followingRef = rootRef.child(path0)
        followingRef.observeSingleEvent(of: .value, with: { followingSnapshot in
            for childFollowingSnapshot in followingSnapshot.children {
                guard let following = childFollowingSnapshot as? DataSnapshot else {
                    continue
                }
                let user_path = "users/\(following.key)/"
                let usersRef = rootRef.child(user_path)
                usersRef.observeSingleEvent(of: .value, with: { userSnapshot in

                    let user = User(with: userSnapshot, exception: "email")
                
                    for touser in usersname {
                        let fromuser = user.username.lowercased().replaceFirstOccurrence(of: " ", to: "")
                        let normalize_tosuer = touser.dropFirst().lowercased()
                        if (normalize_tosuer == fromuser) {
                            users.append(user)
                            break
                        }
                    }
                    userCount = userCount + 1
                    if userCount == followingSnapshot.childrenCount {
                        callback?(users)
                    }
                    
                })
            }
        })
        
    }

    func writePost(photoId: String, content: String, imageReconized: MachineLearningList, talent: Talent, callback: ((PostServiceResult) -> Void)?) {
        var result = PostServiceResult()
        guard session.isValid else {
            result.error = .authenticationNotFound(message: "Authentication not found")
            callback?(result)
            return
        }
        
        let uid = session.user.id
        let rootRef = Database.database().reference()
        let postKey = rootRef.child("posts").childByAutoId().key
        
        let path1 = "posts/\(postKey)"
        let path2 = "user-post/\(uid)/posts/\(postKey)"
        let path3 = "user-feed/\(uid)/posts/\(postKey)"
        let path4 = "user-profile/\(uid)/post_count"
        let path5 = "user-follower/\(uid)/followers"

        let postCountRef = rootRef.child(path4)
        let followerRef = rootRef.child(path5)
       
        
        postCountRef.runTransactionBlock({ (data) -> TransactionResult in
            if let val = data.value as? Int {
                data.value = val + 1
            } else {
                data.value = 1
            }
            return TransactionResult.success(withValue: data)

            }, andCompletionBlock: { (error, committed, snap) in
                guard error == nil, committed else {
                    result.error = .failedToWrite(message: "Failed to write post")
                    callback?(result)
                    return
                }
                
                followerRef.observeSingleEvent(of: .value, with: { followerSnapshot in
                    let tag_visual1 = imageReconized.machineLearningList[0].identificador.normalizeToTag()
                    let tag_visual2 = imageReconized.machineLearningList[1].identificador.normalizeToTag()
                    var tag_user = content.extractHashTag()
                    let tag_user_mention = content.extractMentionTag()
                    
                    let n_hashtag = tag_user.count
                    if (n_hashtag < 5) {
                        for _ in n_hashtag...4 {
                            tag_user.append("")
                        }
                    }
                    let postUpdate: [AnyHashable: Any] = [
                        "id": postKey,
                        "uid": uid,
                        "timestamp": ServerValue.timestamp(),
                        "message": content,
                        "photo_id": photoId,
                        "likes_count": 0,
                        "shares_count": 0,
                        "visual_reconigzed_identifier1": imageReconized.machineLearningList[0].identifier,
                        "visual_reconigzed_confidence1": imageReconized.machineLearningList[0].confidence,
                        "visual_reconigzed_identifier2": imageReconized.machineLearningList[1].identifier,
                        "visual_reconigzed_confidence2": imageReconized.machineLearningList[1].confidence,
                        "visual_reconigzed_identificador1": imageReconized.machineLearningList[0].identificador,
                        "visual_reconigzed_identificador2": imageReconized.machineLearningList[1].identificador,
                        "visual_reconigzed_identifier_hashtag1": "#" + tag_visual1,
                        "visual_reconigzed_identifier_hashtag2": "#" + tag_visual2,
                        "user_hashtag1": tag_user[0].lowercased(),
                        "user_hashtag2": tag_user[1].lowercased(),
                        "user_hashtag3": tag_user[2].lowercased(),
                        "user_hashtag4": tag_user[3].lowercased(),
                        "user_hashtag5": tag_user[4].lowercased(),
                        "model": imageReconized.machineLearningList[0].model,
                        "talent": talent.id,
                        "comments_count": 0
                    ]
                    
                    self.getUserFromUsername(of: tag_user_mention, callback:  { (users) in
                        var updates: [AnyHashable: Any] = [
                            path1: postUpdate,
                            path2: true,
                            path3: true
                        ]
                        
                        let activitiesRef = rootRef.child("activities")
                        
                        for user in users {
                           // Update follower's activity
                            let activityKey = activitiesRef.childByAutoId().key
                            let activityUpdate: [AnyHashable: Any] = [
                                "id": activityKey,
                                "type": "share",
                                "trigger_by": uid,
                                "post_id": postKey,
                                "timestamp": ServerValue.timestamp()
                            ]
                            updates["activities/\(user.id)"] = activityUpdate
                            updates["user-activity/\(user.id)/activities/\(activityKey)"] = true
                            updates["user-activity/\(user.id)/activity-mentioned/\(postKey)/\(uid)"] = [activityKey: true]
                        }
                        
                        
                       
                        
                        for childSnapshot in followerSnapshot.children {
                            guard let follower = childSnapshot as? DataSnapshot else {
                                continue
                            }
                            
                            let followerId = follower.key
                            
                            // Update follower's feed
                            updates["user-feed/\(followerId)/posts/\(postKey)"] = true
                            
                            // Update follower's activity
                            let activityKey = activitiesRef.childByAutoId().key
                            let activityUpdate: [AnyHashable: Any] = [
                                "id": activityKey,
                                "type": "post",
                                "trigger_by": uid,
                                "post_id": postKey,
                                "timestamp": ServerValue.timestamp()
                            ]
                            updates["activities/\(activityKey)"] = activityUpdate
                            updates["user-activity/\(followerId)/activities/\(activityKey)"] = true
                            updates["user-activity/\(followerId)/activity-post/\(postKey)/\(uid)/\(activityKey)"] = true
                            
                            // Update thing-talent-post
                            
                            updates["talent-thing-post/\(talent.id)/\(tag_visual1)/\(postKey)"] = ServerValue.timestamp()
                            
                            for index in 0...4 {
                                if tag_user[index].count > 1 {
                                    let thing = tag_user[index].dropFirst()
                                    updates["talent-thing-post/\(talent.id)/\(thing)/\(postKey)"] = ServerValue.timestamp()
                                }
                                
                            }
                            
                            updates["user-talent-thing-post/\(uid)/\(talent.id)/\(tag_visual1)/\(postKey)"] = true
                            
                        }
                        
                        rootRef.updateChildValues(updates, withCompletionBlock: { error, ref in
                            guard error == nil else {
                                result.error = .failedToWrite(message: "Failed to write post")
                                callback?(result)
                                return
                            }
                            Database.database().reference().keepSynced(true)
                            let postsRef = rootRef.child(path1)
                            let usersRef = rootRef.child("users/\(uid)")
                            
                            postsRef.observeSingleEvent(of: .value, with: { (postSnapshot) in
                                usersRef.observeSingleEvent(of: .value, with: { (userSnapshot) in
                                    let user = User(with: userSnapshot, exception: "email")
                                    let users = [uid: user]
                                    
                                    let post = Post(with: postSnapshot)
                                    let posts = [post]
                                    
                                    var list = PostList()
                                    list.posts = posts
                                    list.users = users
                                    
                                    result.posts = list
                                    callback?(result)
                                })
                            })
                        })
                    })
                })
        })
    }

    func like(id: String, callback: ((PostServiceError?) -> Void)?) {
        var error: PostServiceError?
        guard session.isValid else {
            error = .authenticationNotFound(message: "Authentication not found")
            callback?(error)
            return
        }
        
        let uid = session.user.id
        
        let path1 = "posts/\(id)/likes_count"
        let path2 = "post-like/\(id)/likes"
        let path3 = "posts/\(id)/uid"
        
        let rootRef = Database.database().reference()
        let likesRef = rootRef.child(path2)
        let likesCountRef = rootRef.child(path1)
        let authorRef = rootRef.child(path3)
        
        authorRef.observeSingleEvent(of: .value, with: { authorSnapshot in
            guard let authorId = authorSnapshot.value as? String else {
                error = .failedToLike(message: "Failed to like post")
                callback?(error)
                return
            }
            
            likesRef.child(uid).observeSingleEvent(of: .value, with: { (data) in
                guard !data.exists() else {
                    error = .failedToLike(message: "Already liked")
                    callback?(error)
                    return
                }
                
                likesCountRef.runTransactionBlock({ (data) -> TransactionResult in
                    if let val = data.value as? Int {
                        data.value = val + 1
                    } else {
                        data.value = 1
                    }
                    return TransactionResult.success(withValue: data)
                    
                    }, andCompletionBlock: { (err, committed, snap) in
                        guard err == nil, committed else {
                            error = .failedToLike(message: "Failed to like post")
                            callback?(error)
                            return
                        }
                        
                        var updates: [AnyHashable: Any] = [
                            "\(path2)/\(uid)": true,
                            "user-like/\(uid)/posts/\(id)": true
                        ]
                        
                        if authorId != uid {
                            let activitiesRef = rootRef.child("activities")
                            let activityKey = activitiesRef.childByAutoId().key
                            let activityUpdate: [AnyHashable: Any] = [
                                "id": activityKey,
                                "type": "like",
                                "trigger_by": uid,
                                "post_id": id,
                                "timestamp": ServerValue.timestamp()
                            ]
                            updates["activities/\(activityKey)"] = activityUpdate
                            updates["user-activity/\(authorId)/activities/\(activityKey)"] = true
                            updates["user-activity/\(authorId)/activity-like/\(id)/\(uid)"] = [activityKey: true]
                        }
                        
                        rootRef.updateChildValues(updates)
                        callback?(nil)
                })
            })
        })
    }

    func unlike(id: String, callback: ((PostServiceError?) -> Void)?) {
        var error: PostServiceError?
        guard session.isValid else {
            error = .authenticationNotFound(message: "Authentication not found")
            callback?(error)
            return
        }
        
        let uid = session.user.id
        
        let path1 = "posts/\(id)/likes_count"
        let path2 = "post-like/\(id)/likes"
        let path3 = "posts/\(id)/uid"
        
        let rootRef = Database.database().reference()
        let likesRef = rootRef.child(path2)
        let likesCountRef = rootRef.child(path1)
        let authorRef = rootRef.child(path3)
        
        authorRef.observeSingleEvent(of: .value, with: { authorSnapshot in
            guard let authorId = authorSnapshot.value as? String else {
                error = .failedToUnlike(message: "Failed to unlike post")
                callback?(error)
                return
            }
            
            let userActivityLikeRef = rootRef.child("user-activity/\(authorId)/activity-like/\(id)/\(uid)")
            
            userActivityLikeRef.observeSingleEvent(of: .value, with: { userActivitySnapshot in
                likesRef.observeSingleEvent(of: .value, with: { (data) in
                    guard data.exists() else {
                        error = .failedToUnlike(message: "Post does not exist")
                        callback?(error)
                        return
                    }
                    
                    likesCountRef.runTransactionBlock({ (data) -> TransactionResult in
                        if let val = data.value as? Int , val > 0 {
                            data.value = val - 1
                        } else {
                            data.value = 0
                        }
                        return TransactionResult.success(withValue: data)
                        
                        }, andCompletionBlock: { (err, committed, snap) in
                            guard err == nil, committed else {
                                error = .failedToUnlike(message: "Failed to unlike post")
                                callback?(error)
                                return
                            }
                            
                            var updates: [AnyHashable: Any] = [
                                "\(path2)/\(uid)": NSNull(),
                                "user-like/\(uid)/posts/\(id)": NSNull()
                            ]
                            
                            if authorId != uid {
                                for child in userActivitySnapshot.children {
                                    guard let activitySnapshot = child as? DataSnapshot else {
                                        continue
                                    }
                                    
                                    let activityKey = activitySnapshot.key
                                    
                                    // Removal of activities
                                    updates["activities/\(activityKey)"] = NSNull()
                                    updates["user-activity/\(authorId)/activities/\(activityKey)"] = NSNull()
                                }
                                
                                updates["user-activity/\(authorId)/activity-like/\(id)/\(uid)"] = NSNull()
                            }
                            
                            rootRef.updateChildValues(updates)
                            callback?(nil)
                    })
                })
            })
        })
    }
    
    
    func share(id: String, callback: ((PostServiceError?) -> Void)?) {
        var error: PostServiceError?
        guard session.isValid else {
            error = .authenticationNotFound(message: "Authentication not found")
            callback?(error)
            return
        }
        
        let uid = session.user.id
        
        let path1 = "posts/\(id)/shares_count"
        let path2 = "post-share/\(id)/shares"
        let path3 = "posts/\(id)/uid"
       
        
        let rootRef = Database.database().reference()
        let likesRef = rootRef.child(path2)
        let likesCountRef = rootRef.child(path1)
        let authorRef = rootRef.child(path3)
        
        authorRef.observeSingleEvent(of: .value, with: { authorSnapshot in
            guard let authorId = authorSnapshot.value as? String else {
                error = .failedToLike(message: "Failed to share post")
                callback?(error)
                return
            }
            
            likesRef.child(uid).observeSingleEvent(of: .value, with: { (data) in
                guard !data.exists() else {
                    error = .failedToLike(message: "Already share")
                    callback?(error)
                    return
                }
                
                
                likesCountRef.runTransactionBlock({ (data) -> TransactionResult in
                    if let val = data.value as? Int {
                        data.value = val + 1
                    } else {
                        data.value = 1
                    }
                    return TransactionResult.success(withValue: data)
                    
                }, andCompletionBlock: { (err, committed, snap) in
                    guard err == nil, committed else {
                        error = .failedToLike(message: "Failed to share post")
                        callback?(error)
                        return
                    }
                    let postRef = rootRef.child("posts")
                    let postRefKey = postRef.childByAutoId().key
                    
                    var updates: [AnyHashable: Any] = [
                        "\(path2)/\(uid)/\(postRefKey)": true,
                        "user-share/\(uid)/posts/\(id)":true
                        
                    ]
                    
                    let path5 = "user-follower/\(uid)/followers"
                    let followerRef = rootRef.child(path5)
                    
                    let userFeedUpdate: [AnyHashable: Any] = [
                        "timestamp": ServerValue.timestamp(),
                        "type": "share",
                        "postid": id
                    ]
                    
                    followerRef.observeSingleEvent(of: .value, with: { (followerSnapshot) in
                        
                        for childSnapshot in followerSnapshot.children {
                            guard let follower = childSnapshot as? DataSnapshot else {
                                continue
                            }
                            
                            let followerId = follower.key
                            
                            // Update follower's feed
                           
                            updates["user-feed/\(followerId)/posts/\(postRefKey)/shared"] = userFeedUpdate
                            
                        }
                        
                        if authorId != uid {
                            let activitiesRef = rootRef.child("activities")
                            let activityKey = activitiesRef.childByAutoId().key
                            let activityUpdate: [AnyHashable: Any] = [
                                "id": activityKey,
                                "type": "share",
                                "trigger_by": uid,
                                "post_id": id,
                                "timestamp": ServerValue.timestamp()
                            ]
                            updates["activities/\(activityKey)"] = activityUpdate
                            updates["user-activity/\(authorId)/activities/\(activityKey)"] = true
                            updates["user-activity/\(authorId)/activity-share/\(id)/\(uid)"] = [activityKey: true]
                            
                            updates["user-feed/\(uid)/posts/\(postRefKey)/shared"] = userFeedUpdate
                            
                            
                        }
                        
                        rootRef.updateChildValues(updates)
                        callback?(nil)
                    })
                    
                })
            })
        })
    }
    
    func unshare(id: String, callback: ((PostServiceError?) -> Void)?) {
        var error: PostServiceError?
        guard session.isValid else {
            error = .authenticationNotFound(message: "Authentication not found")
            callback?(error)
            return
        }
        
        let uid = session.user.id
        
        
        let path1 = "posts/\(id)/shares_count"
        let path2 = "post-share/\(id)/shares"
        let path3 = "posts/\(id)/uid"
        
        
        let rootRef = Database.database().reference()
        
        let likesRef = rootRef.child(path2)
        let likesCountRef = rootRef.child(path1)
        let authorRef = rootRef.child(path3)
        
        
        authorRef.observeSingleEvent(of: .value, with: { authorSnapshot in
            guard let authorId = authorSnapshot.value as? String else {
                error = .failedToUnlike(message: "Failed to unshare post")
                callback?(error)
                return
            }
            
            let userActivityLikeRef = rootRef.child("user-activity/\(authorId)/activity-share/\(id)/\(uid)")
            
            userActivityLikeRef.observeSingleEvent(of: .value, with: { userActivitySnapshot in
                likesRef.observeSingleEvent(of: .value, with: { (data) in
                    guard data.exists() else {
                        error = .failedToUnlike(message: "Post does not exist")
                        callback?(error)
                        return
                    }
                    var fake_postId: String = ""
                    let postShareSnapshot = data.childSnapshot(forPath: "\(uid)")
                    
                    for child in postShareSnapshot.children {
                        guard let postShareChild = child as? DataSnapshot else {
                            continue
                        }
           
                        
                        fake_postId = postShareChild.key
                        

                    }
                    
                    if (fake_postId == "") {
                        error = .failedToUnlike(message: "Failed to unshare post")
                        callback?(error)
                        return
                    }
                    
                    likesCountRef.runTransactionBlock({ (data) -> TransactionResult in
                        if let val = data.value as? Int , val > 0 {
                            data.value = val - 1
                        } else {
                            data.value = 0
                        }
                        return TransactionResult.success(withValue: data)
                        
                    }, andCompletionBlock: { (err, committed, snap) in
                        guard err == nil, committed else {
                            error = .failedToUnlike(message: "Failed to unshare post")
                            callback?(error)
                            return
                        }
                        
                        
                        let path5 = "user-follower/\(uid)/followers"
                        let followerRef = rootRef.child(path5)

                        
                        var updates: [AnyHashable: Any] = [
                            "\(path2)/\(uid)": NSNull(),
                            "user-share/\(uid)/posts/\(id)": NSNull()
                        ]
                        
                        
                        followerRef.observeSingleEvent(of: .value, with: { (followerSnapshot) in
                            
                            for childSnapshot in followerSnapshot.children {
                                guard let follower = childSnapshot as? DataSnapshot else {
                                    continue
                                }
                                
                                let followerId = follower.key
                                
                                // Update follower's feed
                                updates["user-feed/\(followerId)/posts/\(fake_postId)"] =  NSNull()
                               
                            }
                            
                            if authorId != uid {
                                for child in userActivitySnapshot.children {
                                    guard let activitySnapshot = child as? DataSnapshot else {
                                        continue
                                    }
                                    
                                    let activityKey = activitySnapshot.key
                                    
                                    // Removal of activities
                                    updates["activities/\(activityKey)"] = NSNull()
                                    updates["user-activity/\(authorId)/activities/\(activityKey)"] = NSNull()
                                }
                                
                                updates["user-activity/\(authorId)/activity-share/\(id)/\(uid)"] = NSNull()
                                updates["user-feed/\(uid)/posts/\(fake_postId)"] = NSNull()
                            }
                            
                            rootRef.updateChildValues(updates)
                            callback?(nil)
                        })
 
                    })
                })
            })
        })
    }
    
    
    

    func fetchLikes(id: String, offset: String, limit: UInt, callback: ((PostServiceLikeResult) -> Void)?) {
        var result = PostServiceLikeResult()
        guard session.isValid else {
            result.error = .authenticationNotFound(message: "Authentication not found.")
            callback?(result)
            return
        }
        
        let uid = session.user.id
  
        let path1 = "post-like/\(id)/likes"
        let path2 = "users"
        let path3 = "user-following/\(uid)/following"
        
        let rootRef = Database.database().reference()
        let likesRef = rootRef.child(path1)
        let usersRef = rootRef.child(path2)
        let followingRef = rootRef.child(path3)
        
        var query = likesRef.queryOrderedByKey()
        
        if !offset.isEmpty {
            query = query.queryEnding(atValue: offset)
        }
        
        query = query.queryLimited(toLast: limit + 1)
        query.observeSingleEvent(of: .value, with: { (data) in
            guard data.exists(), data.childrenCount > 0 else {
                result.likes = [User]()
                callback?(result)
                return
            }
            
            var users = [User]()
            var following = [String: Bool]()
            
            for child in data.children {
                guard let userChild = child as? DataSnapshot else {
                    continue
                }
                
                let userKey = userChild.key
                let userRef = usersRef.child(userKey)
                let isFollowingRef = followingRef.child(userKey)
                
                isFollowingRef.observeSingleEvent(of: .value, with: { isFollowingSnapshot in
                    userRef.observeSingleEvent(of: .value, with: { (userSnapshot) in
                        let user = User(with: userSnapshot, exception: "email")
                        
                        if following[userKey] == nil &&
                            (isFollowingSnapshot.exists() || userKey == uid) {
                            following[userKey] = userKey == uid
                        }
                        
                        users.append(user)
                        
                        let userCount = UInt(users.count)
                        if userCount == data.childrenCount {
                            if userCount == limit + 1 {
                                let removedUser = users.removeFirst()
                                result.nextOffset = removedUser.id
                            }
                            
                            result.likes = users
                            result.following = following
                            callback?(result)
                        }
                    })
                })
            }
        })
    }
    
    
    func fetchShares(id: String, offset: String, limit: UInt, callback: ((PostServiceShareResult) -> Void)?) {
        var result = PostServiceShareResult()
        guard session.isValid else {
            result.error = .authenticationNotFound(message: "Authentication not found.")
            callback?(result)
            return
        }
        
        let uid = session.user.id
        
        let path1 = "post-share/\(id)/shares"
        let path2 = "users"
        let path3 = "user-following/\(uid)/following"
        
        let rootRef = Database.database().reference()
        let likesRef = rootRef.child(path1)
        let usersRef = rootRef.child(path2)
        let followingRef = rootRef.child(path3)
        
        var query = likesRef.queryOrderedByKey()
        
        if !offset.isEmpty {
            query = query.queryEnding(atValue: offset)
        }
        
        query = query.queryLimited(toLast: limit + 1)
        query.observeSingleEvent(of: .value, with: { (data) in
            guard data.exists(), data.childrenCount > 0 else {
                result.shares = [User]()
                callback?(result)
                return
            }
            
            var users = [User]()
            var following = [String: Bool]()
            
            for child in data.children {
                guard let userChild = child as? DataSnapshot else {
                    continue
                }
                
                let userKey = userChild.key
                let userRef = usersRef.child(userKey)
                let isFollowingRef = followingRef.child(userKey)
                
                isFollowingRef.observeSingleEvent(of: .value, with: { isFollowingSnapshot in
                    userRef.observeSingleEvent(of: .value, with: { (userSnapshot) in
                        let user = User(with: userSnapshot, exception: "email")
                        
                        if following[userKey] == nil &&
                            (isFollowingSnapshot.exists() || userKey == uid) {
                            following[userKey] = userKey == uid
                        }
                        
                        users.append(user)
                        
                        let userCount = UInt(users.count)
                        if userCount == data.childrenCount {
                            if userCount == limit + 1 {
                                let removedUser = users.removeFirst()
                                result.nextOffset = removedUser.id
                            }
                            
                            result.shares = users
                            result.following = following
                            callback?(result)
                        }
                    })
                })
            }
        })
    }
    
    func fetchPostInfo(id: String, callback: ((PostServiceResult) -> Void)?) {
        var result = PostServiceResult()
        
        guard session.isValid else {
            result.error = .authenticationNotFound(message: "Authentication not found")
            callback?(result)
            return
        }
        
        let uid = session.user.id
        let path1 = "posts/\(id)"
        let rootRef = Database.database().reference()
        let postRef = rootRef.child(path1)
        
        postRef.observeSingleEvent(of: .value, with: { postSnapshot in
            guard postSnapshot.exists(),
                let photoId = postSnapshot.childSnapshot(forPath: "photo_id").value as? String else {
                result.error = .failedToFetch(message: "Post not found")
                callback?(result)
                return
            }
            var timestamp:Double = 0
            var original_post_id: String = ""
            var posts = [Post]()
            var users = [String: User]()
            
            let post = Post(with: postSnapshot)
            var posterId = post.userId
            
            let hasSharedChild = postSnapshot.hasChild("\(posterId)/shared")
            if (hasSharedChild) {
                timestamp = (postSnapshot.childSnapshot(forPath: "\(posterId)/shared/timestamp").value as? Double)!
                original_post_id = (postSnapshot.childSnapshot(forPath: "\(posterId)/shared/postid").value as? String)!
                posterId = original_post_id
            }
            
            let userRef = rootRef.child("users").child(posterId)
            let photoRef = rootRef.child("photos").child(photoId)
            let likesRef = rootRef.child("post-like/\(id)/likes")
            let sharesRef = rootRef.child("post-share/\(posterId)/shares")
            
            userRef.observeSingleEvent(of: .value, with: { (userSnapshot) in
                photoRef.observeSingleEvent(of: .value, with: { (photoSnapshot) in
                    likesRef.observeSingleEvent(of: .value, with: { (likesSnapshot) in
                        sharesRef.observeSingleEvent(of: .value, with: { (sharesSnapshot) in
                            if users[posterId] == nil {
                                let user = User(with: userSnapshot, exception: "email")
                                users[posterId] = user
                            }
                            
                            let photo = Photo(with: photoSnapshot)
                            var post = Post(with: postSnapshot)
                            post.photo = photo
                            post.isVideo = post.photo.isVideo
                            post.isLiked = likesSnapshot.hasChild(uid)
                            
                            if sharesSnapshot.hasChild(uid) {
                                post.isShared = true
                                if (hasSharedChild) {
                                    post.timestamp = timestamp
                                    post.id = original_post_id
                                }
                                
                            }
                            
                            posts.append(post)
                            
                            var list = PostList()
                            list.posts = posts
                            list.users = users
                            
                            result.posts = list
                            
                            callback?(result)
                            
                        })
                    })
                })
            })
        })
    }
    
    
    func updateUserSearch(uid: String, recognized: String, talentId: String, nResults: Int) {
        let rootRef = Database.database().reference()
        
        let searchRef = rootRef.child("user-talent-thing-search/\(uid)/\(talentId)/\(recognized)/")
        let searchRefKey = searchRef.childByAutoId().key
        let searchRef_next = rootRef.child("user-talent-thing-search/\(uid)/\(talentId)/\(recognized)/\(searchRefKey)")
        let searchUpdate: [AnyHashable: Any] = [
            "id": searchRefKey,
            "type": "search",
            "count_search": nResults,
            "timestamp": ServerValue.timestamp()
        ]
        
        searchRef_next.updateChildValues(searchUpdate, withCompletionBlock: { error, ref in
            guard error == nil else {
                return
            }
            Database.database().reference().keepSynced(true)
        })
    }
    
    func fetchTaggedPosts(tag: String,  offset: String, limit: UInt, callback: ((PostServiceResult) -> Void)?) {
        
        var result = PostServiceResult()
        guard session.isValid else {
            result.error = .authenticationNotFound(message: "Authentication not found")
            callback?(result)
            return
        }
        
        self.fetchDiscoveryPosts(ofAttribute: "user_hashtag1", ofAttributeVale: tag, talentId: "Arte", offset: offset, limit: limit) { (resultado1) in
            self.fetchDiscoveryPosts(ofAttribute: "user_hashtag2", ofAttributeVale: tag, talentId: "Arte", offset: offset, limit: limit) { (resultado2) in
                self.fetchDiscoveryPosts(ofAttribute: "user_hashtag3", ofAttributeVale: tag, talentId: "Arte", offset: offset, limit: limit) { (resultado3) in
                    self.fetchDiscoveryPosts(ofAttribute: "user_hashtag4", ofAttributeVale: tag, talentId: "Arte", offset: offset, limit: limit) { (resultado4) in
                        self.fetchDiscoveryPosts(ofAttribute: "user_hashtag5", ofAttributeVale: tag, talentId: "Arte", offset: offset, limit: limit) { (resultado5) in
                            result.posts = PostList()
                            let post1 = resultado1.posts
                            let post2 = resultado2.posts
                            let post3 = resultado3.posts
                            let post4 = resultado4.posts
                            let post5 = resultado5.posts
                            result.add(thePostList: post1!)
                            result.add(thePostList: post2!)
                            result.add(thePostList: post3!)
                            result.add(thePostList: post4!)
                            result.add(thePostList: post5!)
                            callback?(result)
                        }
                    }
                }
            }
        }
    }
    
    func fetchDiscoveryPosts(recognized: String, talentId: String, offset: String, limit: UInt, callback: ((PostServiceResult) -> Void)?) {
        var result = PostServiceResult()
        var nResult : Int = 0
        
        guard session.isValid else {
            result.error = .authenticationNotFound(message: "Authentication not found")
            callback?(result)
            return
        }
        
        let uid = session.user.id
        let path1 = "posts"
        let rootRef = Database.database().reference()
        let postsRef = rootRef.child(path1)
        
        var query = postsRef.queryOrdered(byChild: "visual_reconigzed_identificador1").queryEqual(toValue: recognized)
        if !offset.isEmpty {
            query = query.queryEnding(atValue: offset)
        }
        
        query = query.queryLimited(toLast: limit + 1)
        
        query.observeSingleEvent(of: .value, with: { queryResult -> Void in
            guard queryResult.childrenCount > 0 else {
                result.posts = PostList()
                self.updateUserSearch(uid: uid, recognized: recognized, talentId: talentId, nResults: nResult )
                callback?(result)
                return
            }
            
            var posts = [Post]()
            var users = [String: User]()
            var discoveryPosts = [String]()
            var discoveryPostAuthors = [String]()
            var totalValues = queryResult.children.allObjects.count
            var postCount = 0
            for child in queryResult.children {
                guard let postSnapshot = child as? DataSnapshot,
                    let posterId = postSnapshot.childSnapshot(forPath: "uid").value as? String,
                    let photoId = postSnapshot.childSnapshot(forPath: "photo_id").value as? String else {
                        continue
                }
                var timestamp:Double = 0
                var original_post_id: String = ""
                var postId = postSnapshot.key
                let hasSharedChild = postSnapshot.hasChild("\(postId)/shared")
                if (hasSharedChild) {
                    timestamp = (postSnapshot.childSnapshot(forPath: "\(postId)/shared/timestamp").value as? Double)!
                    original_post_id = (postSnapshot.childSnapshot(forPath: "\(postId)/shared/postid").value as? String)!
                    postId = original_post_id
                }
                
                
                let postTalent = postSnapshot.childSnapshot(forPath: "talent").value as? String
                if (postTalent != talentId) {
                    totalValues = totalValues - 1
                    if (totalValues == 0) {
                        self.updateUserSearch(uid: uid, recognized: recognized, talentId: talentId, nResults: 0 )
                        result.posts = PostList()
                        callback?(result)
                    }
                    continue
                }
                let userRef = rootRef.child("users").child(posterId)
                let photoRef = rootRef.child("photos").child(photoId)
                let likedRef = rootRef.child("post-likes").child(postId).child(uid)
                let followingRef = rootRef.child("user-following").child(uid).child("following").child(posterId)
                let sharesRef = rootRef.child("post-share/\(posterId)/shares")
                
                followingRef.observeSingleEvent(of: .value, with: { followingSnapshot in
                    likedRef.observeSingleEvent(of: .value, with: { likedSnapshot in
                        userRef.observeSingleEvent(of: .value, with: { userSnapshot in
                            photoRef.observeSingleEvent(of: .value, with: { photoSnapshot in
                                 sharesRef.observeSingleEvent(of: .value, with: { (sharesSnapshot) in
                                    if users[posterId] == nil {
                                        let user = User(with: userSnapshot)
                                        users[posterId] = user
                                    }
                                    
                                    var post = Post(with: postSnapshot)
                                    let photo = Photo(with: photoSnapshot)
                                    
                                    post.photo = photo
                                    post.isVideo = post.photo.isVideo
                                    post.isLiked = likedSnapshot.exists()
                                    
                                    if sharesSnapshot.hasChild(uid) {
                                        post.isShared = true
                                        if (hasSharedChild) {
                                            post.timestamp = timestamp
                                            post.id = original_post_id
                                        }
                                        
                                    }
                                    
                                    posts.append(post)
                                   
                                    //if !followingSnapshot.exists() && posterId != uid {
                                    if posterId != uid {
                                        discoveryPosts.append(postId)
                                        
                                        if !discoveryPostAuthors.contains(posterId) {
                                            discoveryPostAuthors.append(posterId)
                                        }
                                    }
                                    
                                    //let postCount = UInt(posts.count)
                                    postCount = postCount + 1
                                    
                                    //if postCount == queryResult.childrenCount {
                                    if postCount == totalValues {
                                        if postCount == limit + 1 {
                                            let removedPost = posts.removeFirst()
                                            result.nextOffset = removedPost.id
                                        }
                                        
                                        var list = PostList()
                                        
                                        // Filtered posts based on the post id in
                                        // 'discoveryPosts' array.
                                        list.posts = posts.filter({ post -> Bool in
                                            return discoveryPosts.contains(post.id)
                                        }).sorted(by: { post1, post2 -> Bool in
                                            return post1.timestamp > post2.timestamp
                                        })
                                        
                                        // Filtered users based on the user id in
                                        // 'discoveryPostAuthors' array.
                                        let filteredUsers = users.filter({ (entry: (key: String, value: User)) -> Bool in
                                            return discoveryPostAuthors.contains(entry.key)
                                        })
                                        
                                        // Filtered users is reduced and converted
                                        // to dictionary with type '[String: User]'
                                        list.users = filteredUsers.reduce([String: User]()) { dict, entry -> [String: User] in
                                            var info = dict
                                            info[entry.key] = entry.value
                                            return info
                                        }
                                        
                                        //list.posts = posts
                                        list.posts = list.posts.sorted(by:{ $0.likesCount > $1.likesCount })
                                        result.posts = list
                                        nResult = list.count
                                        self.updateUserSearch(uid: uid, recognized: recognized, talentId: talentId, nResults: nResult )
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
    
    func fetchDiscoveryPosts(ofAttribute att: String, ofAttributeVale value: String, talentId: String, offset: String, limit: UInt, callback: ((PostServiceResult) -> Void)?) {
        var result = PostServiceResult()
        var nResult : Int = 0
        
        guard session.isValid else {
            result.error = .authenticationNotFound(message: "Authentication not found")
            callback?(result)
            return
        }
        
        let uid = session.user.id
        let path1 = "posts"
        let rootRef = Database.database().reference()
        let postsRef = rootRef.child(path1)
        
        var query = postsRef.queryOrdered(byChild: att).queryEqual(toValue: value)
        if !offset.isEmpty {
            query = query.queryEnding(atValue: offset)
        }
        
        query = query.queryLimited(toLast: limit + 1)
        
        query.observeSingleEvent(of: .value, with: { queryResult -> Void in
            guard queryResult.childrenCount > 0 else {
                result.posts = PostList()
                callback?(result)
                return
            }
            
            var posts = [Post]()
            var users = [String: User]()
            var discoveryPosts = [String]()
            var discoveryPostAuthors = [String]()
            var totalValues = queryResult.children.allObjects.count
            var postCount = 0
            for child in queryResult.children {
                guard let postSnapshot = child as? DataSnapshot,
                    let posterId = postSnapshot.childSnapshot(forPath: "uid").value as? String,
                    let photoId = postSnapshot.childSnapshot(forPath: "photo_id").value as? String else {
                        continue
                }
                
                var postId = postSnapshot.key
                var timestamp:Double = 0
                var original_post_id: String = ""
                let hasSharedChild = postSnapshot.hasChild("\(postId)/shared")
                if (hasSharedChild) {
                    timestamp = (postSnapshot.childSnapshot(forPath: "\(postId)/shared/timestamp").value as? Double)!
                    original_post_id = (postSnapshot.childSnapshot(forPath: "\(postId)/shared/postid").value as? String)!
                    postId = original_post_id
                }
                
                let userRef = rootRef.child("users").child(posterId)
                let photoRef = rootRef.child("photos").child(photoId)
                let likedRef = rootRef.child("post-likes").child(postId).child(uid)
                let followingRef = rootRef.child("user-following").child(uid).child("following").child(posterId)
                let sharesRef = rootRef.child("post-share/\(posterId)/shares")
                
                followingRef.observeSingleEvent(of: .value, with: { followingSnapshot in
                    likedRef.observeSingleEvent(of: .value, with: { likedSnapshot in
                        userRef.observeSingleEvent(of: .value, with: { userSnapshot in
                            photoRef.observeSingleEvent(of: .value, with: { photoSnapshot in
                                 sharesRef.observeSingleEvent(of: .value, with: { (sharesSnapshot) in
                                    if users[posterId] == nil {
                                        let user = User(with: userSnapshot)
                                        users[posterId] = user
                                    }
                                    
                                    var post = Post(with: postSnapshot)
                                    let photo = Photo(with: photoSnapshot)
                                    
                                    post.photo = photo
                                    post.isVideo = post.photo.isVideo
                                    post.isLiked = likedSnapshot.exists()
                                    
                                    if sharesSnapshot.hasChild(uid) {
                                        post.isShared = true
                                        if (hasSharedChild) {
                                            post.timestamp = timestamp
                                            post.id = original_post_id
                                        }
                                        
                                    }
                                    
                                    posts.append(post)
                                    
                                    //if !followingSnapshot.exists() && posterId != uid {
                                    if posterId != uid {
                                        discoveryPosts.append(postId)
                                        
                                        if !discoveryPostAuthors.contains(posterId) {
                                            discoveryPostAuthors.append(posterId)
                                        }
                                    }
                                    
                                    //let postCount = UInt(posts.count)
                                    postCount = postCount + 1
                                    
                                    //if postCount == queryResult.childrenCount {
                                    if postCount == totalValues {
                                        if postCount == limit + 1 {
                                            let removedPost = posts.removeFirst()
                                            result.nextOffset = removedPost.id
                                        }
                                        
                                        var list = PostList()
                                        
                                        // Filtered posts based on the post id in
                                        // 'discoveryPosts' array.
                                        list.posts = posts.filter({ post -> Bool in
                                            return discoveryPosts.contains(post.id)
                                        }).sorted(by: { post1, post2 -> Bool in
                                            return post1.timestamp > post2.timestamp
                                        })
                                        
                                        // Filtered users based on the user id in
                                        // 'discoveryPostAuthors' array.
                                        let filteredUsers = users.filter({ (entry: (key: String, value: User)) -> Bool in
                                            return discoveryPostAuthors.contains(entry.key)
                                        })
                                        
                                        // Filtered users is reduced and converted
                                        // to dictionary with type '[String: User]'
                                        list.users = filteredUsers.reduce([String: User]()) { dict, entry -> [String: User] in
                                            var info = dict
                                            info[entry.key] = entry.value
                                            return info
                                        }
                                        
                                        //list.posts = posts
                                        list.posts = list.posts.sorted(by:{ $0.likesCount > $1.likesCount })
                                        result.posts = list
                                        nResult = list.count
                                       
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
    
    
    
    func fetchRecommendPosts(offset: String, limit: UInt, callback: ((PostServiceResult) -> Void)?) {
        var result = PostServiceResult()
       
        guard session.isValid else {
            result.error = .authenticationNotFound(message: "Authentication not found")
            callback?(result)
            return
        }
        
        let uid = session.user.id
        result.posts = PostList()
        
        let path1 = "user-talent-thing-post/\(uid)/"
       
        let rootRef = Database.database().reference()
        let postsRef = rootRef.child(path1)
        
        var query = postsRef.queryOrdered(byChild: "key")
        if !offset.isEmpty {
            query = query.queryEnding(atValue: offset)
        }
        
        query = query.queryLimited(toLast: limit + 1)
        
        query.observeSingleEvent(of: .value, with: { queryResult -> Void in
            guard queryResult.childrenCount > 0 else {
                result.posts = PostList()
                callback?(result)
                return
            }
            
            var nChild = queryResult.childrenCount
            for child in queryResult.children {
                 guard let user_talent = child as? DataSnapshot,
                    let t_talentId = user_talent.key as? String,  user_talent.childrenCount > 0 else {
                    continue
                 }
                
                 nChild = nChild + user_talent.childrenCount - 1
                 for child2 in user_talent.children {
                    guard let user_talent_thing = child2 as? DataSnapshot,
                        let t_recognized = user_talent_thing.key as? String else {
                            continue
                    }

                    self.fetchDiscoveryPosts(recognized: t_recognized, talentId: t_talentId, offset: offset, limit: limit, callback: { (result1) in
                        let posts = result1.posts?.posts
                        let users = result1.posts?.users
                        for post in posts! {
                            result.posts?.posts.append(post)
                            result.posts?.users[post.userId] = users?[post.userId]
                        }
                        
                        nChild = nChild - 1
                        if (nChild == 0) {
                            callback?(result)
                        }
                    })
                 }
            }
        })
    }
    
   
    
    func fetchRecommendPosts(withRecognized recognized: String, withTalentId talentId: String, offset: String, limit: UInt, callback: ((PostServiceResult) -> Void)?) {
        var result = PostServiceResult()
        var isRecongnizedProcessed:Bool = false
        
        guard session.isValid else {
            result.error = .authenticationNotFound(message: "Authentication not found")
            callback?(result)
            return
        }
        
        let uid = session.user.id
        result.posts = PostList()
        
        let path1 = "user-talent-thing-post/\(uid)/\(talentId)"
        let path2 = "user-talent-thing-search/\(uid)/\(talentId)"
        

        let rootRef = Database.database().reference()
        let postsRef = rootRef.child(path1)
        
        var query = postsRef.queryOrdered(byChild: "key")
        if !offset.isEmpty {
            query = query.queryEnding(atValue: offset)
        }
        
        query = query.queryLimited(toLast: limit + 1)
        
        query.observeSingleEvent(of: .value, with: { queryResult -> Void in
            guard queryResult.childrenCount > 0 else {
                result.posts = PostList()
                callback?(result)
                return
            }
            
            var nChild = queryResult.childrenCount

            for child in queryResult.children {
                
                guard let user_talent_thing = child as? DataSnapshot,
                    let recognized_f = user_talent_thing.key as? String,  user_talent_thing.childrenCount > 0 else {
                        continue
                }
                
                if (recognized == recognized_f) {
                    isRecongnizedProcessed = true
                }
                
           
                
                self.fetchDiscoveryPosts(recognized: recognized_f, talentId: talentId, offset: offset, limit: limit, callback: { (result1) in
                    let posts = result1.posts?.posts
                    let users = result1.posts?.users
                    for post in posts! {
                        result.posts?.posts.append(post)
                        result.posts?.users[post.userId] = users?[post.userId]
                    }
      
                
                    nChild = nChild - 1
                    if (nChild == 0) {
                        
                        if (!isRecongnizedProcessed) {
                            self.fetchDiscoveryPosts(recognized: recognized, talentId: talentId, offset: offset, limit: limit, callback: { (result1) in
                                guard let posts = result1.posts?.posts, let users = result1.posts?.users else {
                                    callback?(result)
                                    return
                                }
                                for post in posts {
                                    result.posts?.posts.append(post)
                                    result.posts?.users[post.userId] = users[post.userId]
                                }
                                callback?(result)
                            })
                        } else {
                            callback?(result)
                        }
                    }
                })
            }
        })
    }
    
    
    
    func fetchDiscoveryPosts(offset: String, limit: UInt, callback: ((PostServiceResult) -> Void)?) {
        var result = PostServiceResult()
        guard session.isValid else {
            result.error = .authenticationNotFound(message: "Authentication not found")
            callback?(result)
            return
        }
        
        let uid = session.user.id
        let path1 = "posts"
        let rootRef = Database.database().reference()
        let postsRef = rootRef.child(path1)
        
        var query = postsRef.queryOrderedByKey()
        
        if !offset.isEmpty {
            query = query.queryEnding(atValue: offset)
        }
        
        query = query.queryLimited(toLast: limit + 1)
        
        query.observeSingleEvent(of: .value, with: { queryResult -> Void in
            guard queryResult.childrenCount > 0 else {
                result.posts = PostList()
                callback?(result)
                return
            }
            
            var posts = [Post]()
            var users = [String: User]()
            var discoveryPosts = [String]()
            var discoveryPostAuthors = [String]()
            
            for child in queryResult.children {
                guard let postSnapshot = child as? DataSnapshot,
                    let posterId = postSnapshot.childSnapshot(forPath: "uid").value as? String,
                    let photoId = postSnapshot.childSnapshot(forPath: "photo_id").value as? String else {
                    continue
                }
                
                var postId = postSnapshot.key
                var timestamp:Double = 0
                var original_post_id: String = ""
                
                let hasSharedChild = postSnapshot.hasChild("\(postId)/shared")
                if (hasSharedChild) {
                    timestamp = (postSnapshot.childSnapshot(forPath: "\(postId)/shared/timestamp").value as? Double)!
                    original_post_id = (postSnapshot.childSnapshot(forPath: "\(postId)/shared/postid").value as? String)!
                    postId = original_post_id
                }
                let userRef = rootRef.child("users").child(posterId)
                let photoRef = rootRef.child("photos").child(photoId)
                let likedRef = rootRef.child("post-likes").child(postId).child(uid)
                let followingRef = rootRef.child("user-following").child(uid).child("following").child(posterId)
                let sharesRef = rootRef.child("post-share/\(posterId)/shares")
                
                followingRef.observeSingleEvent(of: .value, with: { followingSnapshot in
                    likedRef.observeSingleEvent(of: .value, with: { likedSnapshot in
                        userRef.observeSingleEvent(of: .value, with: { userSnapshot in
                            photoRef.observeSingleEvent(of: .value, with: { photoSnapshot in
                                 sharesRef.observeSingleEvent(of: .value, with: { (sharesSnapshot) in
                                    if users[posterId] == nil {
                                        let user = User(with: userSnapshot)
                                        users[posterId] = user
                                    }
                                    
                                    var post = Post(with: postSnapshot)
                                    let photo = Photo(with: photoSnapshot)
                                    
                                    post.photo = photo
                                    post.isVideo = post.photo.isVideo
                                    post.isLiked = likedSnapshot.exists()
                                    
                                    if sharesSnapshot.hasChild(uid) {
                                        post.isShared = true
                                        if (hasSharedChild) {
                                            post.timestamp = timestamp
                                            post.id = original_post_id
                                        }
                                        
                                    }
                                    
                                    posts.append(post)
                                    
                                    if !followingSnapshot.exists() && posterId != uid {
                                        discoveryPosts.append(postId)
                                        
                                        if !discoveryPostAuthors.contains(posterId) {
                                            discoveryPostAuthors.append(posterId)
                                        }
                                    }
                                    
                                    let postCount = UInt(posts.count)
                                    if postCount == queryResult.childrenCount {
                                        if postCount == limit + 1 {
                                            let removedPost = posts.removeFirst()
                                            result.nextOffset = removedPost.id
                                        }
                                        
                                        var list = PostList()
                                        
                                        // Filtered posts based on the post id in
                                        // 'discoveryPosts' array.
                                        list.posts = posts.filter({ post -> Bool in
                                            return discoveryPosts.contains(post.id)
                                        }).sorted(by: { post1, post2 -> Bool in
                                            return post1.timestamp > post2.timestamp
                                        })
                                        
                                        // Filtered users based on the user id in
                                        // 'discoveryPostAuthors' array.
                                        let filteredUsers = users.filter({ (entry: (key: String, value: User)) -> Bool in
                                            return discoveryPostAuthors.contains(entry.key)
                                        })
                                        
                                        // Filtered users is reduced and converted
                                        // to dictionary with type '[String: User]'
                                        list.users = filteredUsers.reduce([String: User]()) { dict, entry -> [String: User] in
                                            var info = dict
                                            info[entry.key] = entry.value
                                            return info
                                        }
                                        
                                        result.posts = list
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
    
    func fetchLikedPosts(userId: String, offset: String, limit: UInt, callback: ((PostServiceResult) -> Void)?) {
        let path = "user-like/\(userId)/posts"
        fetchUserPosts(path: path, offset: offset, limit: limit, callback: callback)
    }
}

extension PostServiceProvider {
    
    fileprivate func fetchUserPosts(path: String, offset: String, limit: UInt, callback: ((PostServiceResult) -> Void)?) {
        var result = PostServiceResult()
        guard session.isValid else {
            result.error = .authenticationNotFound(message: "Authentication not found")
            callback?(result)
            return
        }
        
        let uid = session.user.id
        let rootRef = Database.database().reference()
        let usersRef = rootRef.child("users")
        let postsRef = rootRef.child("posts")
        let photosRef = rootRef.child("photos")
        let userPostRef = rootRef.child(path)
        var query = userPostRef.queryOrderedByKey()
        
        if !offset.isEmpty {
            query = query.queryEnding(atValue: offset)
        }
        
        query = query.queryLimited(toLast: limit + 1)
        query.observeSingleEvent(of: .value, with: { (data) in
            guard data.childrenCount > 0 else {
                result.posts = PostList()
                callback?(result)
                return
            }
            
            var posts = [Post]()
            var users = [String: User]()
            
            for child in data.children {
                guard let userPost = child as? DataSnapshot else {
                    continue
                }
                
                var postId = userPost.key
               
                let hasSharedChild = userPost.hasChild("\(postId)/shared")
                if (hasSharedChild) {
                    postId = (userPost.childSnapshot(forPath: "\(postId)/shared/postid").value as? String)!
                }
                
                let postRef = postsRef.child(postId)
                
                postRef.observeSingleEvent(of: .value, with: { (postSnapshot) in
                    guard let posterId = postSnapshot.childSnapshot(forPath: "uid").value as? String,
                        let photoId = postSnapshot.childSnapshot(forPath: "photo_id").value as? String else {
                            return
                    }
                    
                    let userRef = usersRef.child(posterId)
                    let photoRef = photosRef.child(photoId)
                    let likesRef = rootRef.child("post-like/\(postId)/likes")
                    let sharesRef = rootRef.child("post-share/\(postId)/shares")
                    
                    userRef.observeSingleEvent(of: .value, with: { (userSnapshot) in
                        photoRef.observeSingleEvent(of: .value, with: { (photoSnapshot) in
                            likesRef.observeSingleEvent(of: .value, with: { (likesSnapshot) in
                                if users[posterId] == nil {
                                    let user = User(with: userSnapshot, exception: "email")
                                    users[posterId] = user
                                }
                                
                                let photo = Photo(with: photoSnapshot)
                                var post = Post(with: postSnapshot)
                                post.photo = photo
                                post.isVideo = post.photo.isVideo
                                
                                if likesSnapshot.hasChild(uid) {
                                    post.isLiked = true
                                }
                                
                               
                                posts.append(post)
                                
                                let postCount = UInt(posts.count)
                                if postCount == data.childrenCount {
                                    if postCount == limit + 1 {
                                        let removedPost = posts.removeFirst()
                                        result.nextOffset = removedPost.id
                                    }
                                    
                                    let sorted = posts.sorted(by: { post1, post2 -> Bool in
                                        return post1.timestamp > post2.timestamp
                                    })
                                    
                                    var list = PostList()
                                    list.posts = sorted
                                    list.users = users
                                    result.posts = list
                                    callback?(result)
                                }
                            })
                        })
                    })
                })
            }
        })
    }
}
