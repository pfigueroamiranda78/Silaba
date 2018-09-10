//
//  FirebaseRetoStrategy.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 4/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class FirebaseRetoStrategy: Retar {
    
    func getRetos(withUserId UserID: String, withFollowers Followers: Bool, completion:((Bool, [Reto]?) -> (Void))? ){
        
        var Allretos = [Reto]()
        var fUser: FirebaseUser!
        var totalSeguidos: Int = 0
        
        let userGroup = DispatchGroup()
        userGroup.enter()
        Database.database().reference().child("users").child(UserID).observeSingleEvent(of: .value) { (snapshot) in
            let userData = snapshot.value as! Dictionary<String, AnyObject>
            let User = Auth.auth().currentUser
            fUser = FirebaseUser(withUser: User!, userData: userData)
            userGroup.leave()
        }
        
        let userRetos = DispatchGroup()
        userRetos.enter()
        userGroup.notify(queue: DispatchQueue.main) { // Los que sigue el usuario se cargaron
            totalSeguidos = fUser.getSiguiendo().count
            self.getRetos(withField: "userid", withData: UserID) { (success, retos) in
                for reto in retos! {
                    Allretos.append(reto)
                }
                userRetos.leave()
            }
        }

        userRetos.notify(queue: DispatchQueue.main) { // Ya cargó los retos del usuario
            if (Followers) {
                if (totalSeguidos==0) {
                    completion!(true, Allretos)
                }
                for seguido in (fUser.getSiguiendo()) {
                    let followingRetos = DispatchGroup()
                    followingRetos.enter()
                    self.getRetos(withField: "userid", withData: seguido) { (success, retos) in
                        for reto in retos! {
                            Allretos.append(reto)
                        }
                        followingRetos.leave()
                        totalSeguidos = totalSeguidos - 1
                    }
                    followingRetos.notify(queue: DispatchQueue.main) {
                        if (totalSeguidos==0 ) {
                            completion!(true, Allretos)
                        }
                    }
                }
            } else {
                completion!(true, Allretos)
            }
        }
    }
    
    
    func getRetos(withTag Tag:String, withLimit Limit:Int, completion:((Bool, [Reto]?) -> (Void))? ){
        let userRetos = DispatchGroup()
        var Allretos = [Reto]()
        userRetos.enter()
        
        self.getRetos(withField: "Tag", withData: Tag) { (success, retos) in
            for reto in retos! {
                Allretos.append(reto)
            }
            userRetos.leave()
        }
        
        userRetos.notify(queue: DispatchQueue.main) {
            completion!(true, Allretos)
        }
    }
    
    func getRetos(withField Field: String, withData DataID: String, completion:((Bool, [Reto]?) -> (Void))? ){
        
        var retos = [Reto]()
        let fRetos = DispatchGroup()
        Database.database().reference().keepSynced(true)
        let ref = Database.database().reference()
        fRetos.enter()
        ref.child("Retos").queryOrdered(byChild: Field).queryEqual(toValue: DataID).observe(.value, with: { (snapshot) in
            let shot = snapshot.children.allObjects as? [DataSnapshot]
            
            for data in (shot?.reversed())! {
                let retoDict = data.value as? Dictionary<String, AnyObject>
                let reto = Reto(RetoId: data.key, retoData: retoDict!)
                retos.append(reto)
            }
            fRetos.leave()
        })
        fRetos.notify(queue: DispatchQueue.main) { // 2
            completion!(true, retos)
        }
    }
    
    
    
    func addReto(withUserId UserID: String, withLat Lat: Double, withLon Lon: Double, withDescription Des: String, withAddres Addr: String, withImageUrl imageUrl:String, withTag tag:String, completion:((Bool, [Reto]?) -> (Void))?) {
            Database.database().reference().child("users").child(UserID).observeSingleEvent(of: .value) { (snapshot) in
            let data = snapshot.value as! Dictionary<String, AnyObject>
            let username = data["username"]
            let userImg = data["userImg"]
            
            let reto: Dictionary<String, AnyObject> = [
                "userid": UserID as AnyObject,
                "username": username as AnyObject,
                "userImg": userImg as AnyObject,
                "LatReto": Lat as AnyObject,
                "LonReto": Lon as AnyObject,
                "DesReto": Des as AnyObject,
                "AddrReto": Addr as AnyObject,
                "Tag": tag as AnyObject,
                "imageUrl":imageUrl as AnyObject]
            let firebasereto = Database.database().reference().child("Retos").childByAutoId()
            firebasereto.setValue(reto)
                completion!(true, nil)
            Database.database().reference().keepSynced(true)
        }
    }
    
    
}
