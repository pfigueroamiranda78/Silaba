//
//  VideoListCellItem.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 30/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

//
//  CommentListCellItem.swift
//  Photostream
//
//  Created by Mounir Ybanez on 29/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import Kingfisher
import DateTools

protocol VideoListCellItem {
    
    var timestamp: Double { get }
    var authorName: String { get }
    var authorAvatar: String { get }
    var timeAgo: String { get }
    var content: String { get }
    var id: String { get }
}

extension VideoListCellItem {
    
    var timeAgo: String {
        let date = NSDate(timeIntervalSince1970: timestamp)
        return date.timeAgoSinceNow()
    }
}

protocol VideoListCellConfig {
    
    var dynamicHeight: CGFloat { get }
    func configure(with item: VideoListCellItem?, isPrototype: Bool)
    func set(photo url: String, placeholder image: UIImage)
    func set(author name: String)
    func set(content: String)
    func set(time: String)
    func set(id: String)
}

extension VideoListCell: VideoListCellConfig {
    
    fileprivate var authorImage: UIImage {
        let frame = CGRect(x: 0, y: 0, width: photoLength, height: photoLength)
        let font = UIFont.systemFont(ofSize: 12)
        let text: String = authorLabel.text![0]
        let image = UILabel.createPlaceholderImageWithFrame(frame, text: text, font: font)
        return image
    }
    
    var dynamicHeight: CGFloat {
        let height1 = timeLabel.frame.origin.y + timeLabel.frame.size.height + spacing
        let height2 = photoLength + (spacing * 2)
        return max(height1, height2)
    }
    
    func configure(with item: VideoListCellItem?, isPrototype: Bool = false) {
        guard item != nil else {
            return
        }
        
        set(author: item!.authorName)
        set(content: item!.content)
        set(time: item!.timeAgo.uppercased())
        set(id: item!.id)
        
        
        if !isPrototype {
            set(photo: item!.authorAvatar, placeholder: authorImage)
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func set(photo url: String, placeholder image: UIImage) {
        guard let photoUrl = URL(string: url) else {
            authorPhoto.image = image
            return
        }
        
        let resource = ImageResource(downloadURL: photoUrl)
        authorPhoto.kf.setImage(with: resource, placeholder: image, options: nil, progressBlock: nil, completionHandler: nil)
    }
    
    func set(author name: String) {
        authorLabel.text = name
    }
    
    func set(content: String) {
        contentLabel.text = content
    }
    
    func set(time: String) {
        timeLabel.text = time
    }
    
    func set(id: String) {
        videoId.text = id
    }
}
