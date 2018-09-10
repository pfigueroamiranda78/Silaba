//
//  PostCell.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import SDWebImage

class PostCell: UITableViewCell {

    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postText: UILabel!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var imgView: UIImageView!
    var post: Poste!
    let currentUser = KeychainWrapper.standard.string(forKey: "uid")
    
    override func prepareForReuse() {
        userImg.sd_cancelCurrentImageLoad()
        userImg.layer.removeAllAnimations()
        userImg.image = nil
        imgView.sd_cancelCurrentImageLoad()
        imgView.layer.removeAllAnimations()
        imgView.image = nil
    }
    
    func configCell(post: Poste) {
       
        self.username.text = post.username
        self.postText.text = post.postText
        if (post.DataImgUser != nil) {
            let img = UIImage(data: post.DataImgUser!)
            self.userImg.image = img
        } else {
            self.userImg?.getfromCache(fromUrl:post.userImg, fromProvider: .WebSDCache)

        }
        
        if (post.DataImgPost != nil) {
            let img = UIImage(data: post.DataImgPost!)
            self.imgView.image = img
        } else {
            if (post.imageUrl.isEmpty) {
                return
            }
            self.imgView?.getfromCache(fromUrl:post.imageUrl, fromProvider: .WebSDCache)

        }
    }
}
