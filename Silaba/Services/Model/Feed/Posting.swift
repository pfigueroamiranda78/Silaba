//
//  Posting.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

final class Posting : Postear {

    
    private let estrategia : Postear
    
    init(withEstrategia estrategia: Postear) {
        self.estrategia  = estrategia
    }
    
    func getPosts(withUserId UserID: String, ofReto Reto: Reto, completion: @escaping (Bool, [Poste]?) -> ()) {
        self.estrategia.getPosts(withUserId: UserID, ofReto: Reto) { (success, posts) in
            completion(success, posts)
        }
    }
    
    func addPost(withUserId UserID: String, withTextPost TextPost: String, ofReto Reto: Reto, withImageUrl imageUrl:String, completion: @escaping (Bool, Poste?) -> ()) {
        self.estrategia.addPost(withUserId: UserID, withTextPost: TextPost, ofReto: Reto, withImageUrl: imageUrl) { (success, post) in
            completion(success, post)
        }
    }
    
    
    func addCommentPost(withUserId UserID: String, withTextPost TextPost: String, ofReto Reto: Reto, ofPost Post: Poste, completion: @escaping (Bool, Poste?) -> ()) {
        self.estrategia.addCommentPost(withUserId: UserID, withTextPost: TextPost, ofReto: Reto, ofPost: Post) { (success, post) in
            completion(success, post)
        }
    }
    
    
    func getComments(withUserId UserID: String, ofReto Reto: Reto, ofPost Post: Poste, completion: @escaping (Bool, [Poste]?) -> ()) {
        self.estrategia.getComments(withUserId: UserID, ofReto: Reto, ofPost: Post) { (success, post) in
            completion(success, post)
        }
    }
}
