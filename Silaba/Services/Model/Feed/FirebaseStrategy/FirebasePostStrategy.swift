//
//  FirebasePostStrategy.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class FirebasePostStrategy : Postear {
    
    var posts = [Poste]()
    var comments = [Poste]()
    
    func getPosts(withUserId UserID: String, ofReto Reto: Reto, completion: @escaping (Bool, [Poste]?) -> ()) {
        Database.database().reference().keepSynced(true)
        Database.database().reference().child("Publicaciones").queryOrdered(byChild: "experienceId").queryEqual(toValue: Reto.id).observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else
            {
                completion(false, nil)
                return
            }
            self.comments.removeAll()
            for data in snapshot.reversed() {
                guard let postDict = data.value as? Dictionary<String, AnyObject> else
                {
                    completion(false, nil)
                    return
                }
                let post = Poste(postKey: data.key, postData: postDict)
                self.comments.append(post)
            }
            completion(true, self.comments)
        }
    }
    
    func addPost(withUserId UserID: String, withTextPost TextPost: String, ofReto Reto: Reto, withImageUrl imageUrl:String, completion: @escaping (Bool, Poste?) -> ()) {
        
        Database.database().reference().child("users").child(UserID).observeSingleEvent(of: .value) { (snapshot) in
            let data = snapshot.value as! Dictionary<String, AnyObject>
            let username = data["username"]
            let userImg = data["userImg"]
            
            let post: Dictionary<String, AnyObject> = [
                "username": username as AnyObject,
                "userImg": userImg as AnyObject,
                "experienceId": Reto.id as AnyObject,
                "postText": TextPost as AnyObject,
                "imageUrl":imageUrl as AnyObject]
            //let firebasepost = Database.database().reference().child("Retos").child(Reto.id).child("Publicaciones").childByAutoId()
            let firebasepost = Database.database().reference().child("Publicaciones").childByAutoId()
            firebasepost.setValue(post)
            completion(true, nil)
            Database.database().reference().keepSynced(true)
        }
    }
    
    func addCommentPost(withUserId UserID: String, withTextPost TextPost: String, ofReto Reto: Reto, ofPost Post: Poste, completion: @escaping (Bool, Poste?) -> ()) {
        Database.database().reference().child("users").child(UserID).observeSingleEvent(of: .value) { (snapshot) in
            let data = snapshot.value as! Dictionary<String, AnyObject>
            let username = data["username"]
            let userImg = data["userImg"]
            
            let post: Dictionary<String, AnyObject> = [
                "username": username as AnyObject,
                "userImg": userImg as AnyObject,
                "postText": TextPost as AnyObject]
            let firebasepost = Database.database().reference().child("Publicaciones").child(Post.postKey).child("Comentarios").childByAutoId()
            //let firebasepost = Database.database().reference().child("Retos").child(Reto.id).child("Publicaciones").child(Post.postKey).child("Comentarios").childByAutoId()
            firebasepost.setValue(post)
            Post.clean()
            completion(true, nil)
            Database.database().reference().keepSynced(true)
        }
    }
    
    
    func getComments(withUserId UserID: String, ofReto Reto: Reto, ofPost post: Poste, completion: @escaping (Bool, [Poste]?) -> ()) {
        
        // Se ejecuta cuando los comentarios son cargados recursivamente desde la publicacion.
        Database.database().reference().keepSynced(true)
        if (post.comentarios.count > 0) {
            completion(true, post.comentarios.reversed())
            return
        }
   
    //Database.database().reference().child("Retos").child(Reto.id).child("Publicaciones").child(post.postKey).child("Comentarios") .observeSingleEvent(of: .value) { (snapshot) in
        Database.database().reference().child("Publicaciones").child(post.postKey).child("Comentarios") .observeSingleEvent(of: .value) { (snapshot) in

            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else
            {
                completion(false, nil)
                return
            }
            self.comments.removeAll()
            for data in snapshot.reversed() {
                guard let postDict = data.value as? Dictionary<String, AnyObject> else
                {
                    completion(false, nil)
                    return
                }
                let post = Poste(postKey: data.key, postData: postDict)
                self.comments.append(post)
            }
            completion(true, self.comments)
        }
    }
    
}
