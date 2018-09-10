//
//  PostService.swift
//  Photostream
//
//  Created by Mounir Ybanez on 06/08/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import Foundation

protocol PostService {

    init(session: AuthSession)
    
    func fetchPostInfo(id: String, callback: ((PostServiceResult) -> Void)?)
    func fetchPosts(userId: String, offset: String, limit: UInt, callback: ((PostServiceResult) -> Void)?)
    func writePost(photoId: String, content: String, imageReconized: MachineLearningList, talent: Talent, callback: ((PostServiceResult) -> Void)?)
    
    func fetchLikes(id: String, offset: String, limit: UInt, callback: ((PostServiceLikeResult) -> Void)?)
    func like(id: String, callback: ((PostServiceError?) -> Void)?)
    func unlike(id: String, callback: ((PostServiceError?) -> Void)?)
    
    func fetchShares(id: String, offset: String, limit: UInt, callback: ((PostServiceShareResult) -> Void)?)
    func share(id: String, callback: ((PostServiceError?) -> Void)?)
    func unshare(id: String, callback: ((PostServiceError?) -> Void)?)
    func getUserFromUsername(of usersname: [String], callback: (([User]) -> Void)?)
    
    func fetchDiscoveryPosts(offset: String, limit: UInt, callback: ((PostServiceResult) -> Void)?)
    func fetchDiscoveryPosts(recognized: String, talentId: String, offset: String, limit: UInt, callback: ((PostServiceResult) -> Void)?)
    func fetchLikedPosts(userId: String, offset: String, limit: UInt, callback: ((PostServiceResult) -> Void)?)
    func fetchRecommendPosts(withRecognized recognized: String, withTalentId talentId: String, offset: String, limit: UInt, callback: ((PostServiceResult) -> Void)?)
    func fetchRecommendPosts(offset: String, limit: UInt, callback: ((PostServiceResult) -> Void)?)
    func fetchTaggedPosts(tag: String,  offset: String, limit: UInt, callback: ((PostServiceResult) -> Void)?)
}

struct PostServiceResult {

    var posts: PostList?
    var error: PostServiceError?
    var nextOffset: String?
}

struct PostServiceLikeResult {
    
    var likes: [User]?
    var error: PostServiceError?
    var nextOffset: String?
    var following: [String: Bool]?
}

struct PostServiceShareResult {
    
    var shares: [User]?
    var error: PostServiceError?
    var nextOffset: String?
    var following: [String: Bool]?
}


enum PostServiceError: Error {
    
    case authenticationNotFound(message: String)
    case failedToFetch(message: String)
    case failedToWrite(message: String)
    case failedToLike(message: String)
    case failedToUnlike(message: String)
    case failedToFetchLikes(message: String)
    
    case failedToShare(message: String)
    case failedToUnshare(message: String)
    case failedToFetchShares(message: String)
    
    var message: String {
        switch self {
        case .authenticationNotFound(let message),
             .failedToFetch(let message),
             .failedToWrite(let message),
             .failedToLike(let message),
             .failedToUnlike(let message),
             .failedToFetchLikes(let message),
             .failedToShare(let message),
             .failedToUnshare(let message),
             .failedToFetchShares(let message):
            return message
        }
    }
}

extension PostServiceResult {
    
    mutating func add(thePostList postList: PostList ) {
        let thePosts = postList.posts
        let theUsers = postList.users
        for post in thePosts {
            self.posts?.posts.append(post)
            self.posts?.users[post.userId] = theUsers[post.userId]
        }
    }
}
