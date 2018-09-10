//
//  Retando.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 4/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

final class Retando : Retar {

    
    private let estrategia : Retar
    
    init(withEstrategia estrategia: Retar) {
        self.estrategia  = estrategia
    }
    
    func getRetos(withTag Tag: String, withLimit Limit: Int, completion: ((Bool, [Reto]?) -> (Void))?) {
        self.estrategia.getRetos(withTag: Tag, withLimit: Limit) { (success, reto) in
            completion!(success, reto)
        }
    }
    

    func getRetos(withUserId UserID: String, withFollowers Followers: Bool, completion:((Bool, [Reto]?) -> (Void))?) {
        self.estrategia.getRetos(withUserId: UserID, withFollowers: Followers) { (success, reto) in
            completion!(success, reto)
        }
    }
    
    func addReto(withUserId UserID: String, withLat Lat: Double, withLon Lon: Double, withDescription Des: String, withAddres Addr: String, withImageUrl imageUrl:String, withTag tag:String, completion:((Bool, [Reto]?) -> (Void))?) {
        self.estrategia.addReto(withUserId: UserID, withLat: Lat, withLon: Lon, withDescription: Des, withAddres: Addr, withImageUrl: imageUrl , withTag: tag) { (success, reto) in
            completion!(success, reto)
        }
    }
}
