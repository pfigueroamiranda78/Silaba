//
//  Retar.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 4/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol Retar {
    func getRetos(withUserId UserID: String, withFollowers Followers: Bool, completion:((Bool, [Reto]?) -> (Void))?)
    func addReto(withUserId UserID: String, withLat Lat:Double, withLon Lon:Double, withDescription Des:String, withAddres Addr: String, withImageUrl imageUrl:String, withTag tag:String, completion:((Bool, [Reto]?) -> (Void))?)
    func getRetos(withTag Tag:String, withLimit Limit:Int, completion:((Bool, [Reto]?) -> (Void))? )
}
