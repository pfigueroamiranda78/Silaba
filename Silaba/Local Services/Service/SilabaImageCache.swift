//
//  SilabaCache.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 19/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit

enum cacheProviders {
    case WebSDCache
    case Firebase
    case FirebaseCache
}
protocol SilabaImageCache {
    
    func getfromCache(fromUrl Url: String, fromProvider cacheProvider: cacheProviders)
    
}
