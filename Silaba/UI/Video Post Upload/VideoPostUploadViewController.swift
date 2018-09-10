//
//  VideoPostUploadViewController.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/07/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import Photos

class VideoPostUploadViewController: UIViewController {
    
    var presenter: VideoPostUploadModuleInterface!

    var uploadView: VideoPostUploadView! {
        return view as! VideoPostUploadView
    }
    
    override func loadView() {
        let width: CGFloat = UIScreen.main.bounds.size.width
        let height: CGFloat = 44 + (4 * 2)
        let size = CGSize(width: width, height: height)
        let frame = CGRect(origin: .zero, size: size)
        
        preferredContentSize = size
        view = VideoPostUploadView(frame: frame)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.willShowVideo()
        presenter.upload()
    }
}

extension VideoPostUploadViewController: VideoPostUploadViewInterface {
    
    var controller: UIViewController? {
        return self
    }
    
    func show(video: AVPlayerItem) {
        let videoUrl = (video.asset as? AVURLAsset)?.url
        let player = AVPlayer(url: videoUrl!)
        uploadView.videoView.player = player
     }

    func didSucceed() {
        presenter.detach()
    }
    
    func didFail(with message: String) {
        print("Post Upload View Controller: did fail ==>", message)
    }
    
    func didUpdate(with progress: Progress) {
        let percentage = Float(progress.fractionCompleted)
        uploadView.progressView.setProgress(percentage, animated: true)
    }
}
