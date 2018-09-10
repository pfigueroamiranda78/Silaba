//
//  youTubeTableViewCell.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 15/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit
import SDWebImage

class youTubeListTableViewCell: UITableViewCell {

    @IBOutlet weak var imgVideoThumb: UIImageView!
    @IBOutlet weak var lblVideoName: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblUrl: UILabel!
    var url:String!
    override func awakeFromNib() {
        super.awakeFromNib()
        //imgVideoThumb.clipsToBounds = true
        // Initialization code
    }
    override func prepareForReuse() {
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //let tappedImage = tapGestureRecognizer.view as! UIImageView
        let yt="youtube://"+self.url
        var url2=URL(string:yt)!
        if !UIApplication.shared.canOpenURL(url2)  {
            let yt2 = "http://www.youtube.com/watch?v="+self.url
            url2 = URL(string:yt2)!
        }
        UIApplication.shared.open(url2, options: [:], completionHandler: nil)
    }
    
    func configCell(withVideoName videoName:String, withSubTitle subTitle:String, withVideoThumb videoThumb:String, withVideoUrl videoUrl:String) {
        self.lblVideoName.text = videoName
        self.lblSubTitle.text = subTitle
        self.url = videoUrl
        self.imageView?.getfromCache(fromUrl:videoThumb, fromProvider: .WebSDCache)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        self.imageView?.isUserInteractionEnabled = true
        self.imageView?.addGestureRecognizer(tapGestureRecognizer)
    }
    
}
