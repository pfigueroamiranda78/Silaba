//
//  VideoPostUploadPresenter.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/07/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import AVKit

class VideoPostUploadPresenter: VideoPostUploadPresenterInterface {
    
    weak var moduleDelegate: VideoPostUploadModuleDelegate?
    weak var view: VideoPostUploadViewInterface!
    var wireframe: VideoPostUploadWireframeInterface!
    var interactor: VideoPostUploadInteractorInput!
    var item: VideoPostUploadItem!
}

extension VideoPostUploadPresenter: VideoPostUploadModuleInterface {
    
    func upload() {
        interactor.upload(with: item.imageData, content: item.content, machineLearningList: item.machineLearningList, talent: item.talent)
    }
    
    func willShowVideo() {
        view.show(video: item.video)
    }
    
    func detach() {
        guard let controller = view.controller else {
            return
        }
        
        wireframe.detach(with: controller)
    }
}

extension VideoPostUploadPresenter: VideoPostUploadInteractorOutput {
    
    
    func didFailVideo(with message: String) {
        moduleDelegate?.postUploadVideoDidFail(with: message)
        view.didFail(with: message)
    }
    
    func didSucceedVideo(with post: UploadedPost) {
        moduleDelegate?.postUploadVideoDidSucceed(with: post)
        view.didSucceed()
    }
    
    func didUpdateVideo(with progress: Progress) {
        view.didUpdate(with: progress)
    }
}
