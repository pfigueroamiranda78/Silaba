//
//  Postear.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol Postear
{
    /* Publicaciones */
    func getPosts(withUserId UserID: String, ofReto Reto: Reto, completion: @escaping (Bool, [Poste]?)->())
    func addPost(withUserId UserID: String, withTextPost TextPost: String, ofReto Reto: Reto, withImageUrl imageUrl:String, completion: @escaping (Bool, Poste?)->())
    
    /* Comentarios a publicaciones */
    func getComments(withUserId UserID: String, ofReto Reto: Reto, ofPost Post: Poste, completion: @escaping (Bool, [Poste]?)->())
    func addCommentPost(withUserId UserID: String, withTextPost TextPost: String, ofReto Reto: Reto, ofPost Post: Poste,  completion: @escaping (Bool, Poste?)->())
}

