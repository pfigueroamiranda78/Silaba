//
//  PostUploadInteractor.swift
//  Photostream
//
//  Created by Mounir Ybanez on 19/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import Foundation

class PostUploadInteractor: PostUploadInteractorInterface {
    
    weak var output: PostUploadInteractorOutput?
    var fileService: FileService!
    var postService: PostService!
    var machineLearningService: MachineLearningService!
    var youTubeService: VideoService!
    
    required init(fileService: FileService, postService: PostService, machineLearningService: MachineLearningService, youTubeService: VideoService) {
        self.fileService = fileService
        self.postService = postService
        self.machineLearningService = machineLearningService
        self.youTubeService = youTubeService
    }
}


extension PostUploadInteractor: PostUploadInteractorInput {
    
    func upload(with data: FileServiceImageUploadData, content: String, machineLearningList: MachineLearningList, talent: Talent) {
        // Upload first the photo
        fileService.uploadJPEGImage(data: data, track: { (progress) in
            guard progress != nil else {
                return
            }
            
            self.output?.didUpdate(with: progress!)
            
        }) { (result) in
            guard let fileId = result.fileId,
                let fileUrl = result.fileUrl,
                result.error == nil else {
                    self.output?.didFail(with: result.error!.message)
                    return
            }
            
            var uploadedPost = UploadedPost()
            
           
            // Write details of the post
            self.postService.writePost(photoId: fileId, content: content, imageReconized: machineLearningList, talent: talent, callback: { (result) in
                guard result.error == nil else {
                    self.output?.didFail(with: result.error!.message)
                    return
                }
                
                guard let posts = result.posts,
                    posts.count > 0,
                    let (post, user) = posts[0] else {
                        self.output?.didFail(with: "No se encontraron publicaciones")
                        return
                }
                
                uploadedPost.id = post.id
                uploadedPost.message = post.message
                uploadedPost.timestamp = post.timestamp / 1000
                
                uploadedPost.likes = post.likesCount
                uploadedPost.comments = post.commentsCount
                uploadedPost.isLiked = post.isLiked
                uploadedPost.isShared = post.isShared
                uploadedPost.isVideo = post.isVideo

                uploadedPost.identifier = machineLearningList.mejorIdenficador
                uploadedPost.confidence = machineLearningList.bestConfidence
                uploadedPost.recognized_type = post.model
                
                uploadedPost.photoUrl = fileUrl
                uploadedPost.photoWidth = Int(data.width)
                uploadedPost.photoHeight  = Int(data.height)
                
                uploadedPost.userId = user.id
                uploadedPost.avatarUrl = user.avatarUrl
                uploadedPost.displayName = user.displayName
                self.output?.didSucceed(with: uploadedPost)
                
            })
        }
    }
}
