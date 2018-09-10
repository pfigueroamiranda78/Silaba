//
//  VideoShareModuleExtension.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 29/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit

extension VideoShareWireframe {
    
    class func createViewController() -> VideoShareViewController {
        let sb = UIStoryboard(name: "VideoShareModuleStoryboard", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "VideoShareViewController")
        return vc as! VideoShareViewController
    }
}
