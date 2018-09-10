//
//  ShareCommentsTableViewCell.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 2/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import SDWebImage

class SharePublicationTableViewCell: UITableViewCell {

    @IBOutlet weak var shareBtn :  UIButton!
    @IBOutlet weak var userImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        userImgView.sd_cancelCurrentImageLoad()
        userImgView.layer.removeAllAnimations()
        userImgView.image = nil
    }
    
    func configCell(userUrl url: String) {
        self.userImgView?.getfromCache(fromUrl:url, fromProvider: .WebSDCache)
    }
}
