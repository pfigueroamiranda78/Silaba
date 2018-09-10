//
//  PostListCollectionCell.swift
//  Photostream
//
//  Created by Mounir Ybanez on 07/12/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import Spring
import AVKit

protocol PostListCollectionCellDelegate: class {
    
    func didTapPhoto(cell: PostListCollectionCell)
    func didTapHeart(cell: PostListCollectionCell)
    func didTapComment(cell: PostListCollectionCell)
    func didTapCommentCount(cell: PostListCollectionCell)
    func didTapLikeCount(cell: PostListCollectionCell)
    func didTapShareCount(cell: PostListCollectionCell)
    func didTapVideo(cell: PostListCollectionCell)
    func didTapShare(cell: PostListCollectionCell)
    func didTapIdentifier(cell: PostListCollectionCell)
    func didTapHashTag(cell: PostListCollectionCell, hashTag theTag: String)
    func didTapMentionTag(cell: PostListCollectionCell, mentionTag theMention: String)
}

@objc protocol PostListCollectionCellAction: class {
    
    func didTapHeart()
    func didTapComment()
    func didTapPhoto()
    func didTapCommentCount()
    func didTapLikeCount()
    func didTapShareCount()
    func didTapVideo()
    func didTapShare()
    func didTapIdentifier()
    func didTapPlayerPhoto()
}

class PostListCollectionCell: UICollectionViewCell {
    
    weak var delegate: PostListCollectionCellDelegate?
    
    var photoImageView: UIImageView!
    var videoView: UIView!
    var heartButton: UIButton!
    var commentButton: UIButton!
    var videosButton: UIButton!
    var shareButton: UIButton!
    var stripView: UIView!
    var likeCountLabel: UILabel!
    var shareCountLabel: UILabel!
    var lblDuration: UILabel!
    var messageLabel: UITextView!
    var commentCountLabel: UILabel!
    var identifierLabel: UILabel!
    var timeLabel: UILabel!
    var timer = Timer()
    var playSpring : SpringImageView!
    var playerItemContext = 0
    var videoDuration: Float64 = 0
    var playerLayer : AVPlayerLayer!
    var player : AVPlayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSetup()
    }
    
    
    func initSetup() {
        videoView = UIView()
        playerLayer = AVPlayerLayer()
        
        photoImageView = UIImageView()
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.clipsToBounds = true
        photoImageView.backgroundColor = UIColor.white
        photoImageView.isUserInteractionEnabled = true
        
        heartButton = UIButton()
        heartButton.addTarget(self, action: #selector(self.didTapHeart), for: .touchUpInside)
        heartButton.setImage(#imageLiteral(resourceName: "heart"), for: .normal)
        
        commentButton = UIButton()
        commentButton.addTarget(self, action: #selector(self.didTapComment), for: .touchUpInside)
        commentButton.setImage(#imageLiteral(resourceName: "comment"), for: .normal)
        
        videosButton = UIButton()
        videosButton.addTarget(self, action: #selector(self.didTapVideo), for: .touchUpInside)
        videosButton.setImage(#imageLiteral(resourceName: "icon_camera"), for: .normal)
        
        shareButton = UIButton()
        shareButton.addTarget(self, action: #selector(self.didTapShare), for: .touchUpInside)
        shareButton.setImage(#imageLiteral(resourceName: "share_icon"), for: .normal)
        
        stripView = UIView()
        stripView.backgroundColor = UIColor(red: 223/255, green: 223/255, blue: 223/255, alpha: 1)
        
        likeCountLabel = UILabel()
        likeCountLabel.numberOfLines = 0
        likeCountLabel.font = UIFont.boldSystemFont(ofSize: 12)
        likeCountLabel.textColor = primaryColor
        likeCountLabel.isUserInteractionEnabled = true
        
        shareCountLabel = UILabel()
        shareCountLabel.numberOfLines = 0
        shareCountLabel.font = UIFont.boldSystemFont(ofSize: 12)
        shareCountLabel.textColor = primaryColor
        shareCountLabel.isUserInteractionEnabled = true
        
        messageLabel = UITextView()
        //messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 12)
        messageLabel.textColor = primaryColor
        messageLabel.isEditable = false
        messageLabel.isSelectable = true
        messageLabel.dataDetectorTypes = .link
        messageLabel.layer.cornerRadius = 10
        messageLabel.delegate = self
        
        commentCountLabel = UILabel()
        commentCountLabel.numberOfLines = 0
        commentCountLabel.font = UIFont.systemFont(ofSize: 12)
        commentCountLabel.textColor = secondaryColor
        commentCountLabel.isUserInteractionEnabled = true
        
        timeLabel = UILabel()
        timeLabel.numberOfLines = 0
        timeLabel.font = UIFont.systemFont(ofSize: 8)
        timeLabel.textColor = secondaryColor
        
        identifierLabel = UILabel()
        identifierLabel.numberOfLines = 0
        identifierLabel.font = UIFont.systemFont(ofSize: 8)
        identifierLabel.textColor = secondaryColor
        identifierLabel.isUserInteractionEnabled = true
        
        lblDuration = UILabel()
        lblDuration.font = UIFont.systemFont(ofSize: 8)
        lblDuration.textColor = secondaryColor
        lblDuration.isUserInteractionEnabled = false
       
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapPhoto))
        tap.numberOfTapsRequired = 2
        photoImageView.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapPlayerPhoto))
        tap.numberOfTapsRequired = 1
        photoImageView.addGestureRecognizer(tap)
        videoView.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapCommentCount))
        tap.numberOfTapsRequired = 1
        commentCountLabel.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapLikeCount))
        tap.numberOfTapsRequired = 1
        likeCountLabel.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapShareCount))
        tap.numberOfTapsRequired = 1
        shareCountLabel.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapIdentifier))
        tap.numberOfTapsRequired = 1
        identifierLabel.addGestureRecognizer(tap)

        addSubview(videoView)
        addSubview(photoImageView)
        addSubview(heartButton)
        addSubview(commentButton)
        addSubview(videosButton)
        addSubview(shareButton)
        addSubview(stripView)
        addSubview(likeCountLabel)
        addSubview(shareCountLabel)
        addSubview(messageLabel)
        addSubview(commentCountLabel)
        addSubview(timeLabel)
        addSubview(identifierLabel)
        addSubview(lblDuration)
        
    }
    
    override func layoutSubviews() {
        var rect = photoImageView.frame
        
        let ratio = bounds.width / rect.size.width
        rect.size.width = bounds.width
        rect.size.height = min(rect.size.width, rect.size.height * ratio)
        photoImageView.frame = rect
        videoView.frame = rect
        
        rect.origin.x = spacing * 2
        rect.origin.y = rect.size.height + (spacing * 2)
        rect.size = CGSize(width: buttonDimension, height: buttonDimension)
        heartButton.frame = rect
        
        rect.origin.x += rect.size.width + (spacing * 4)
        commentButton.frame = rect
        
        rect.origin.x += rect.size.width + (spacing * 4)
        videosButton.frame = rect
        
        rect.origin.x += rect.size.width + (spacing * 4)
        shareButton.frame = rect
        
        rect.origin.x = spacing * 2
        rect.origin.y += (spacing * 2)
        rect.origin.y += rect.size.height
        rect.size.height = 1
        rect.size.width = bounds.width - (spacing * 4)
        stripView.frame = rect
        
        if let text = likeCountLabel.text, !text.isEmpty {
            rect.origin.y += (spacing * 2) + rect.size.height
            rect.size.height = likeCountLabel.sizeThatFits(rect.size).height
            likeCountLabel.frame = rect
            
        } else {
            likeCountLabel.frame = .zero
        }
        
        if let text = shareCountLabel.text, !text.isEmpty {
            rect.origin.y += (spacing * 2) + rect.size.height
            rect.size.height = shareCountLabel.sizeThatFits(rect.size).height
            shareCountLabel.frame = rect
            
        } else {
            shareCountLabel.frame = .zero
        }
        
        if let text = messageLabel.text, !text.isEmpty {
            rect.origin.y += (spacing * 2) + rect.size.height
            rect.size.height = messageLabel.sizeThatFits(rect.size).height
            messageLabel.frame = rect
            
        } else {
            messageLabel.frame = .zero
        }
        
        if let text = commentCountLabel.text, !text.isEmpty {
            rect.origin.y += (spacing * 2) + rect.size.height
            rect.size.height = commentCountLabel.sizeThatFits(rect.size).height
            commentCountLabel.frame = rect
            
        } else {
            commentCountLabel.frame = .zero
        }
        
        if let text = identifierLabel.text, !text.isEmpty {
            rect.origin.y += (spacing * 2) + rect.size.height
            rect.size.height = identifierLabel.sizeThatFits(rect.size).height
            identifierLabel.frame = rect
        } else {
            identifierLabel.frame = .zero
        }
        
        rect.origin.y += (spacing * 2) + rect.size.height
        rect.size.height = timeLabel.sizeThatFits(rect.size).height
        timeLabel.frame = rect
    }
}

extension PostListCollectionCell: PostListCollectionCellAction {
    func didTapPlayerPhoto() {
        
        if (self.player.isPlaying) {
            self.player.pause()
            self.timer.invalidate()
            self.showAnimatedPause {
                self.videoView.addSubviewAtCenter(self.playSpring)
            }
        } else {
            self.player.play()
            self.runTimer()
            self.playSpring.removeFromSuperview()
            self.showAnimatedPlay { }
        }
        
    }
    
    func didTapShare() {
        delegate?.didTapShare(cell: self)
    }
    
    func didTapVideo() {
        delegate?.didTapVideo(cell: self)
    }
    
    func didTapHeart() {
        delegate?.didTapHeart(cell: self)
    }
    
    func didTapComment() {
        delegate?.didTapComment(cell: self)
    }
    
    func didTapPhoto() {
        animateHeartButton { }
        showAnimatedHeart {
            self.delegate?.didTapPhoto(cell: self)
        }
    }
    
    func didTapCommentCount() {
        delegate?.didTapCommentCount(cell: self)
    }
    
    func didTapLikeCount() {
        delegate?.didTapLikeCount(cell: self)
    }
    
    func didTapShareCount() {
        delegate?.didTapShareCount(cell: self)
    }
    
    func didTapIdentifier() {
        delegate?.didTapIdentifier(cell: self)
    }
}

extension PostListCollectionCell {
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateDuration)), userInfo: nil, repeats: true)
    }
    
    @objc func updateDuration() {
        let minutes = self.videoDuration / 60
        let diffMinutes = Float(minutes) - Float(Int(minutes))
        let remainSeconds = 60 * diffMinutes
        self.lblDuration.text = String(Int(minutes)) + ":" +  String(Int(remainSeconds))
        self.videoDuration = self.videoDuration - 1
    }
    
    func showDurationVideo() {
        let duration : CMTime = (self.player.currentItem!.asset.duration)
        let seconds : Float64 = CMTimeGetSeconds(duration)
        self.videoDuration = seconds
        updateDuration()
    }
    
    func showAnimatedShare(completion: @escaping () -> Void) {
        let share = SpringImageView(image: #imageLiteral(resourceName: "shared_icon_blue"))
        share.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        photoImageView.addSubviewAtCenter(share)
        share.autohide = true
        share.autostart = false
        share.animation = "pop"
        share.duration = 1.0
        share.animateToNext {
            share.animation = "fadeOut"
            share.duration = 0.5
            share.animateToNext {
                share.removeFromSuperview()
                completion()
            }
        }
    }
    
    func showAnimatedPlay(completion: @escaping () -> Void) {
        let share = SpringImageView(image: #imageLiteral(resourceName: "video24x24"))
        share.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        videoView.addSubviewAtCenter(share)
        share.autohide = true
        share.autostart = false
        share.animation = "pop"
        share.duration = 1.0
        share.animateToNext {
            share.animation = "fadeOut"
            share.duration = 0.5
            share.animateToNext {
                share.removeFromSuperview()
                completion()
            }
        }
    }
    
    func showAnimatedPause(completion: @escaping () -> Void) {
        let share = SpringImageView(image: #imageLiteral(resourceName: "pause 24x24"))
        share.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        videoView.addSubviewAtCenter(share)
        share.autohide = true
        share.autostart = false
        share.animation = "pop"
        share.duration = 1.0
        share.animateToNext {
            share.animation = "fadeOut"
            share.duration = 0.5
            share.animateToNext {
                share.removeFromSuperview()
                completion()
            }
        }
        
    }
    
    func animateShareButton(completion: @escaping () -> Void) {
        shareButton.isHidden = true
        let share = SpringImageView(image: #imageLiteral(resourceName: "shared_icon_blue"))
        share.frame = shareButton.frame
        addSubview(share)
        
        share.autohide = true
        share.autostart = false
        share.animation = "pop"
        share.duration = 1.0
        share.animateToNext { [weak self] in
            share.removeFromSuperview()
            self?.shareButton.setImage(#imageLiteral(resourceName: "shared_icon_blue"), for: .normal)
            self?.shareButton.isHidden = false
            completion()
        }
    }
    

    func showAnimatedHeart(completion: @escaping () -> Void) {
        let heart = SpringImageView(image: #imageLiteral(resourceName: "heart_pink"))
        heart.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        photoImageView.addSubviewAtCenter(heart)
        heart.autohide = true
        heart.autostart = false
        heart.animation = "pop"
        heart.duration = 1.0
        heart.animateToNext {
            heart.animation = "fadeOut"
            heart.duration = 0.5
            heart.animateToNext {
                heart.removeFromSuperview()
                completion()
            }
        }
    }
    
    func animateHeartButton(completion: @escaping () -> Void) {
        heartButton.isHidden = true
        let heart = SpringImageView(image: #imageLiteral(resourceName: "heart_pink"))
        heart.frame = heartButton.frame
        addSubview(heart)
        
        heart.autohide = true
        heart.autostart = false
        heart.animation = "pop"
        heart.duration = 1.0
        heart.animateToNext { [weak self] in
            heart.removeFromSuperview()
            self?.heartButton.setImage(#imageLiteral(resourceName: "heart_pink"), for: .normal)
            self?.heartButton.isHidden = false
            completion()
        }
    }
}

extension PostListCollectionCell {
    
    func toggleHeart(liked: Bool, completion: @escaping() -> Void) {
        if liked {
            heartButton.setImage(#imageLiteral(resourceName: "heart"), for: .normal)
            completion()
            
        } else {
            animateHeartButton { }
            showAnimatedHeart {
                completion()
            }
        }
    }
    
    
    func toggleShare(share: Bool, completion: @escaping() -> Void) {
        if share {
            shareButton.setImage(#imageLiteral(resourceName: "share_icon"), for: .normal)
            completion()
            
        } else {
            animateShareButton { }
            showAnimatedShare {
                completion()
            }
        }
    }
}

extension PostListCollectionCell {
    
    var spacing: CGFloat {
        return 4
    }
    
    var buttonDimension: CGFloat {
        return 24
    }
    
    var secondaryColor: UIColor {
        return UIColor(red: 157/255, green: 157/255, blue: 157/255, alpha: 1)
    }
    
    var primaryColor: UIColor {
        return UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1)
    }
}

extension PostListCollectionCell {
    
    static var reuseId: String {
        return "PostListColllectionCell"
    }
    
    class func register(in view: UICollectionView) {
        view.register(self, forCellWithReuseIdentifier: self.reuseId)
    }
    
    class func dequeue(from view: UICollectionView, for indexPath: IndexPath) -> PostListCollectionCell? {
        let cell = view.dequeueReusableCell(withReuseIdentifier: self.reuseId, for: indexPath)
        return cell as? PostListCollectionCell
    }
}


extension PostListCollectionCell : UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        // check for our fake URL scheme hash:helloWorld
        
        let content = textView.text.substring(with: characterRange)?.lowercased()
        
        
        switch URL.scheme {
        case "hash" :
            delegate?.didTapHashTag(cell: self, hashTag: content!)
            return true
        case "mention" :
            delegate?.didTapMentionTag(cell: self, mentionTag: content!)
            return true
        default:
            UIApplication.shared.open(URL, options: [:])
        }
        
        return true
    }
    
}
