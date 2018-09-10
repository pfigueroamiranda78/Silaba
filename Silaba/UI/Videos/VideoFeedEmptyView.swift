//
//  VideoFeedEmptyView.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 30/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit

class VideoFeedEmptyView: UIView {
    
    var messageLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSetup()
    }
    
    func initSetup() {
        messageLabel = UILabel()
        messageLabel.textAlignment = .center
        
        addSubview(messageLabel)
    }
    
    override func layoutSubviews() {
        messageLabel.frame.size = CGSize(width: frame.width - (2 * 8), height: 21)
        messageLabel.center = center
    }
}



