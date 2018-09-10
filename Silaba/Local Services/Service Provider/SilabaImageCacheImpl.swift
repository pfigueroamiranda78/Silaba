//
//  SilabaImageCacheImpl.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 19/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorageCache


extension UIImageView : SilabaImageCache{
    
    func getfromCache(fromUrl Url: String, fromProvider cacheProvider: cacheProviders) {
        switch cacheProvider {
        case .WebSDCache:
            self.sd_setImage(with: NSURL(string: (Url))! as URL)
        case .Firebase:
            let firebaseStorage = SilabaStoring(withEstrategia: FirebaseStorageStrategy())
             firebaseStorage.Download(withUrl: Url) { (success, Data, meta) in
                if (success) {
                    let img = UIImage(data: Data!)
                    self.image = img
                }
             }
        case .FirebaseCache :
            self.setImage(downloadURL: Url)
        }
        
    }
}
