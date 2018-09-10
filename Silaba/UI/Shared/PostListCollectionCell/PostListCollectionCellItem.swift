//
//  PostListCollectionCellItem.swift
//  Photostream
//
//  Created by Mounir Ybanez on 08/12/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import Kingfisher
import AVKit
import Spring

protocol PostListCollectionCellItem {
    
    var message: String { get }
    var displayName: String { get }
    var avatarUrl: String { get }
    var photoUrl: String { get }
    var photoSize: CGSize { get }
    var timeAgo: String { get }
    var isLiked: Bool { get }
    var isShared: Bool { get }
    var isVideo: Bool { get }
    var likesText: String { get }
    var sharesText: String { get }
    var commentsText: String { get }
    var identifierText: String { get }
}

protocol PostListCollectionCellConfig {
    
    var dynamicHeight: CGFloat { get }
    
    func configure(with item: PostListCollectionCellItem?, isPrototype: Bool)
    func set(message: String, displayName: String)
    func set(photo url: String)
    func set(video url: String)
    func set(liked: Bool)
    func set(shared: Bool)
}

extension PostListCollectionCell: PostListCollectionCellConfig {
    
    var dynamicHeight: CGFloat {
        var height = timeLabel.frame.origin.y
        height += timeLabel.frame.size.height
        height += (spacing * 2)
        return height
    }
    
    
    func configure(with item: PostListCollectionCellItem?, isPrototype: Bool = false) {
        guard let item = item else {
            return
        }
        
        if !isPrototype {
            set(photo: item.photoUrl)
        }
        
      
        set(message: item.message, displayName: item.displayName)
        set(liked: item.isLiked)
        set(shared: item.isShared)
        
        timeLabel.text = item.timeAgo.uppercased()
        likeCountLabel.text = item.likesText
        shareCountLabel.text = item.sharesText
        commentCountLabel.text = item.commentsText
        if item.isVideo {
            set(video: item.photoUrl)
            photoImageView.isHidden = true
        } else {
            photoImageView.isHidden = false
        }
        photoImageView.frame.size = item.photoSize
        videoView.frame.size = item.photoSize
        identifierLabel.text = item.identifierText.uppercased()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func set(message: String, displayName: String) {
        guard !message.isEmpty else {
            messageLabel.attributedText = NSAttributedString(string: "")
            return
        }
        
        let font = messageLabel.font!
        let semiBold = UIFont.systemFont(ofSize: font.pointSize, weight: UIFont.Weight.semibold)
        let regular = UIFont.systemFont(ofSize: font.pointSize)
        let name = NSAttributedString(string: displayName, attributes: [NSAttributedStringKey.font: semiBold])
        let message = NSAttributedString(string: message, attributes: [NSAttributedStringKey.font: regular])
        let text = NSMutableAttributedString()
        text.append(name)
        text.append(NSAttributedString(string: " "))
        text.append(message)
        messageLabel.attributedText = text
        messageLabel.resolveHashTags()
        
    }
    
    func set(video url: String) {
        guard let downloadUrl = URL(string: url) else {
            return
        }
        
        var playerItem : AVPlayerItem!
        
        CacheManager.shared.getFileWith(stringUrl: downloadUrl.absoluteString) { result in
            
            switch result {
            case .success(let url):
                playerItem = CachingPlayerItem(url: url)
                self.player = AVPlayer(playerItem: playerItem)
                //player = AVPlayer(url: downloadUrl)
                self.player.automaticallyWaitsToMinimizeStalling = false
                self.player.currentItem?.addObserver(self,
                                                forKeyPath: #keyPath(AVPlayerItem.status),
                                                options: [.old, .new],
                                                context: &self.playerItemContext)
                
                self.playerLayer.player = self.player
            // do some magic with path to saved video
            case .failure(let error): break
                // handle errror
            }
        }
        //showVideo()
    }
    
    
    func showVideo() {
        let item = self.player.currentItem as! CachingPlayerItem
        item.download()
        self.playerLayer.frame = self.videoView.bounds
        self.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.videoView.layer.addSublayer(self.playerLayer)
        
        playSpring = SpringImageView(image: #imageLiteral(resourceName: "video24x24"))
        playSpring.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        videoView.addSubviewAtCenter(playSpring)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { _ in
            self.player.seek(to: kCMTimeZero)
            self.timer.invalidate()
            self.videoView.addSubviewAtCenter(self.playSpring)
            self.showDurationVideo()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItemStatus
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            // Switch over status value
            switch status {
            case .readyToPlay:
                showVideo()
                break
            // Player item is ready to play.
            case .failed: break
            // Player item failed. See error.
            case .unknown: break
                // Player item is not yet ready.
            }
        }
    }
    
    func set(photo url: String) {
        guard let downloadUrl = URL(string: url) else {
            return
        }
        
        let resource = ImageResource(downloadURL: downloadUrl)
        
        photoImageView.backgroundColor = UIColor.lightGray
        photoImageView.kf.setImage(
            with: resource,
            placeholder: nil,
            options: nil,
            progressBlock: nil) { [weak self] (_, _, _, _) in
            self?.photoImageView.backgroundColor = UIColor.white
        }
    }
    
    func set(liked: Bool) {
        if liked {
            heartButton.setImage(UIImage(named: "heart_pink"), for: .normal)
        } else {
            heartButton.setImage(UIImage(named: "heart"), for: .normal)
        }
    }
    
    func set(shared: Bool) {
        if shared {
            shareButton.setImage(UIImage(named: "shared_icon_blue"), for: .normal)
        } else {
            shareButton.setImage(UIImage(named: "share_icon"), for: .normal)
        }
    }
}
