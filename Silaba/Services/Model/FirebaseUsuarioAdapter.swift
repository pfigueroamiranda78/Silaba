//
//  FirebaseUserWrapper.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 27/03/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import FirebaseAuth

final class FirebaseUser: FirebaseAuth.User, Usuario {
    
    var seguido = [String]()
    var siguiendo = [String]()
    var userIden: String!
    var username: String!
    var usermail: String!
    var userImg: String!
    
    private let usr : FirebaseAuth.User
    
    init(withUser user: FirebaseAuth.User) {
        self.usr = user
    }
    
    init(withUser user: FirebaseAuth.User, userData: Dictionary<String, AnyObject>) {
        self.usr = user
        if let name = userData["username"] as? String {
            username = name
        }
        
        if let Img = userData["userImg"] as? String {
            userImg = Img
        }
        
        if let email = userData["usermail"] as? String {
            usermail = email
        }
        
        if let seguidos = userData["Seguido"] as? Dictionary<String, AnyObject> {
            for (_, value) in seguidos {
                let dict = value as? Dictionary<String, AnyObject>
                for (_, value2) in dict! {
                    let stId = value2 as! String
                    self.seguido.append(stId)
                }
            }
        }
        if let seguidos = userData["Siguiendo"] as? Dictionary<String, AnyObject> {
            for (_, value) in seguidos {
                let dict = value as? Dictionary<String, AnyObject>
                for (_, value2) in dict! {
                    let stId = value2 as! String
                    self.siguiendo.append(stId)
                }
            }
        }
    }
    func getSeguido() -> [String] {
        return self.seguido
    }
    func getSiguiendo() -> [String] {
        return self.siguiendo
    }
    func getUserId() -> String {
        return self.usr.uid
    }
}
