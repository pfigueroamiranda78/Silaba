    //
//  FirebaseAuthWrapper.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 27/03/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class FirebaseAuthStrategy :Autenticar {

    
    func ByEmail(withEmail Email: String, withPassword Password: String, completion: @escaping (Bool, Usuario?) -> ()) {
        Auth.auth().signIn(withEmail: Email, password: Password) { (user, error) in
        
            if error == nil {
                Database.database().reference().child("users").child((user?.uid)!).observeSingleEvent(of: .value) { (snapshot) in
                    let userData = snapshot.value as! Dictionary<String, AnyObject>
                    if  error == nil {
                        let usr = FirebaseUser(withUser: user!, userData: userData)
                        completion(true, usr)
                    } else {
                        completion(false, nil)
                    }
                }
            } else {
                completion(false, nil)
            }
        }
    }
    
    func addUser(fromUserId UserId:String, toUser Usuario: Usuario, completion: @escaping (Bool) -> ()) {
        let userData = [
            "userId": Usuario.userIden
            ] as [String : Any]
        
         let firebaseSiguiendo = Database.database().reference().child("users").child(UserId).child("Siguiendo").childByAutoId()
         firebaseSiguiendo.setValue(userData)
        
        let userToData = [
            "userId": UserId
        ]
        let firebaseSeguido = Database.database().reference().child("users").child(Usuario.userIden).child("Seguido").childByAutoId()
        firebaseSeguido.setValue(userToData)
        Database.database().reference().keepSynced(true)
         completion(true)
    }
    
    func addUser(fromUserId UserId:String, toUserId UserIdTo: String, completion: @escaping (Bool) -> ()) {
        let userData = [
            "userId": UserIdTo
            ] as [String : Any]
        
        let firebaseSiguiendo = Database.database().reference().child("users").child(UserId).child("Siguiendo").childByAutoId()
        firebaseSiguiendo.setValue(userData)
        
        let userToData = [
            "userId": UserId
        ]
        let firebaseSeguido = Database.database().reference().child("users").child(UserIdTo).child("Seguido").childByAutoId()
        firebaseSeguido.setValue(userToData)
        Database.database().reference().keepSynced(true)
        completion(true)
    }
    
    func createUser(withEmail Email: String, withPassword Password: String, completion: @escaping (Bool, Usuario?) -> ()) {
        Auth.auth().createUser(withEmail: Email, password: Password) { (user, error) in
            if  error == nil {
                let usr = FirebaseUser(withUser: user!)
                Database.database().reference().keepSynced(true)
                completion(true, usr)
            } else {
                completion(false, nil)
            }
        }
    }
    
    func storeUser(withUserId UserId:String, withUsername Username: String, withUserImg UserImage: Data?, withEmail Email: String, completion: @escaping (Bool, Usuario?) -> ()) {
        
        var imageURL: String!
        let imgUid = NSUUID().uuidString
        let metaData = StorageMetadata()
        
        Storage.storage().reference().child(imgUid).putData(UserImage!, metadata: metaData) { (metadata, error) in
            
            if (error == nil) {
                imageURL = metadata?.downloadURL()?.absoluteString
                let userData = [
                    "username": Username,
                    "userImg": imageURL,
                    "userEmail": Email
                ] as [String : Any]
      
                Database.database().reference().child("users").child(UserId).setValue(userData)
                Database.database().reference().keepSynced(true)
                self.getUser(withUserId: UserId, completion: { (usuario) in
                    completion(true, usuario)
                })
                
            } else {
                completion(false, nil)
            }
        }
    }

    func getUser(withUserId userId: String, completion: @escaping (Usuario?) -> ()) {
        Database.database().reference().keepSynced(true)
        Database.database().reference().child("users").child(userId).observeSingleEvent(of: .value) { (snapshot) in

            let userData = snapshot.value as! Dictionary<String, AnyObject>
            let User = Auth.auth().currentUser
            let newUser = FirebaseUser(withUser: User!, userData: userData)
            completion(newUser)
        }
    }
    
    func getUsers(withEmail Email: String, completion: @escaping (Usuario?) -> ()) {
        Database.database().reference().keepSynced(true)
        Database.database().reference().child("users").queryOrdered(byChild: "userEmail").queryEqual(toValue: Email).observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else
            {
                completion(nil)
                return
            }
            
            for data in snapshot.reversed() {
                guard let userDict = data.value as? Dictionary<String, AnyObject> else
                {
                    completion(nil)
                    return
                }
                
                let User = Auth.auth().currentUser
                let newUser = FirebaseUser(withUser: User!, userData: userDict)
                newUser.usermail = Email
                newUser.userIden = data.key
                completion(newUser)
                return
            }
        }
    }
    
    func getUsers(withUsername Username: String, completion: @escaping ([Usuario]?) -> ()) {
        var Users=[Usuario]()
        Database.database().reference().keepSynced(true)
        Database.database().reference().child("users").queryOrdered(byChild: "username").queryStarting(atValue: Username).observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else
            {
                completion(nil)
                return
            }
            Users.removeAll()
            for data in snapshot.reversed() {
                guard let userDict = data.value as? Dictionary<String, AnyObject> else
                {
                    completion(nil)
                    return
                }
                let User = Auth.auth().currentUser
                let newUser = FirebaseUser(withUser: User!, userData: userDict)
                newUser.userIden = data.key
                newUser.username = Username
                Users.append(newUser)
            }
            completion(Users)
        }
    }
    
    func SignOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out %@", signOutError)
        }
    }
    
    func getUserUrlImage(withUserId UserId: String, completion: @escaping (Bool, String?) -> ()) {
        Database.database().reference().keepSynced(true)
        Database.database().reference().child("users").child(UserId).observeSingleEvent(of: .value) { (snapshot) in
            
            if let postDict = snapshot.value as? [String : AnyObject] {
                let ImgUrl = postDict["userImg"] as! String
                completion(true, ImgUrl)
            } else {
                completion(false, nil)
            }
        }
    }

        
    func getUserImage(withUserId UserId: String, completion: @escaping (Bool, Data?) -> ()) {
        Database.database().reference().keepSynced(true)
        Database.database().reference().child("users").child(UserId).observeSingleEvent(of: .value) { (snapshot) in

            if let postDict = snapshot.value as? [String : AnyObject] {
                let ImgUrl = postDict["userImg"] as! String
                let httpReference = Storage.storage().reference(forURL: ImgUrl)
                httpReference.getData(maxSize: 1 * 1024 * 1024) {data, error in
                    if error != nil {
                        completion(false, data)
                    }
                    else {
                        completion(true, data)
                    }
                }
            }
        }
    }
    
    func getPostImage(withPostUrl PostUrl: String, completion: @escaping (Bool, Data?) -> ()) {
        let ref = Storage.storage().reference(forURL: PostUrl)
        ref.getData(maxSize: 100000000, completion: { (data, error) in
            if error != nil {
                completion(false, data)
            } else {
                if let imgData = data {
                    completion(true, imgData)
                }
            }
            
        })
    }
    
}
