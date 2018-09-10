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


class ExperienceCell: UITableViewCell {

    @IBOutlet weak var listExperiencesSimilars: UIButton!
    @IBOutlet weak var listVideos: UIButton!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postText: UILabel!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblClassification: UILabel!
    var reUse: Bool = false
    
    override func prepareForReuse() {
        userImg.sd_cancelCurrentImageLoad()
        userImg.layer.removeAllAnimations()
        userImg.image = nil
        imgView.sd_cancelCurrentImageLoad()
        imgView.layer.removeAllAnimations()
        imgView.image = nil
    }
    
    func configCell(reto: Reto) {
    
        self.username.text = reto.username
        self.postText.text = reto.description
        
        
        if (reto.DataImgUser != nil) {
            let img = UIImage(data: reto.DataImgUser)
            self.userImg.image = img
        } else {
            self.userImg?.getfromCache(fromUrl: reto.userImg, fromProvider: .WebSDCache)
        }
       
        if (reto.imageUrl.isEmpty) {
            return
        }
        if (reto.DataImgReto != nil) {
            let img = UIImage(data: reto.DataImgReto)
            self.imgView.image = img
            self.lblClassification.text = reto.tag
        } else {
            self.imgView?.getfromCache(fromUrl: reto.imageUrl, fromProvider: .WebSDCache)
        }
        
        reUse = true
    }

}
