//
//  VideoCaptureModuleExtension.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 11/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit

extension VideoCaptureWireframe {
    
    class func createViewController() -> VideoCaptureViewController {
        let sb = UIStoryboard(name: "VideoCaptureModuleStoryboard", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "VideoCaptureViewController")
        return vc as! VideoCaptureViewController
    }
}
