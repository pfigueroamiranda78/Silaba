//
//  CommentCell.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postText: UILabel!
    
    var post: Poste!

    override func prepareForReuse() {
        userImg.sd_cancelCurrentImageLoad()
        userImg.layer.removeAllAnimations()
        userImg.image = nil
    }
    
    func configCell(post: Poste) {
        self.post = post
        self.username.text = post.username
        self.postText.text = post.postText
        if (post.DataImgUser != nil) {
            let img = UIImage(data: post.DataImgUser!)
            self.userImg.image = img
        } else {
            self.userImg?.getfromCache(fromUrl: post.userImg, fromProvider: .WebSDCache )

        }
    }

}
