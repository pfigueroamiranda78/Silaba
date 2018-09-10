//
//  VideoPostUploadView.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/07/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class VideoPostUploadView: UIView {
    
    fileprivate let uniformLength: CGFloat = 44
    fileprivate let uniformSpacing: CGFloat = 4
    fileprivate var fixHeight: CGFloat {
        return uniformSpacing + (uniformLength * 2)
    }
    
    var videoView: AVPlayerLayer!
    var progressView: UIProgressView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSetup()
    }
    
    override func layoutSubviews() {
        var rect = CGRect(x: uniformSpacing, y: uniformSpacing, width: uniformLength, height: uniformLength)
        videoView.frame = rect
        
        rect = progressView.frame
        rect.origin.x = uniformLength + (uniformSpacing * 2)
        //rect.origin.y = videoView.center.y
        rect.size.width = frame.size.width - (uniformLength + (uniformSpacing * 3))
        progressView.frame = rect
    }
    
    func initSetup() {
        backgroundColor = UIColor.white
        
        videoView = AVPlayerLayer()
        videoView.videoGravity = AVLayerVideoGravity.resizeAspectFill
       
        progressView = UIProgressView()
        progressView.tintColor = UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1.0)
        
        layer.addSublayer(videoView)
        addSubview(progressView)
    }
}
