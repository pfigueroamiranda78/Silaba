//
//  TalentServiceProvider.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 21/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

struct TalentServiceProvider: TalentService {
    
   
    
    func fetchTalentAll(callback: ((TalentServiceResult) -> Void)?) {
        var result = TalentServiceResult()
        
        guard session.isValid else {
            result.error = .authenticationNotFound(message: "Authentication not found")
            callback?(result)
            return
        }
        var talents = [Talent]()
        let path1 = "talents"
        let rootRef = Database.database().reference()
        let talentRef = rootRef.child(path1).queryOrdered(byChild: "Nombre")
        
        talentRef.observe(.value, with: { talentSnapshot in
            guard talentSnapshot.childrenCount > 0 else {
                result.talents = TalentList()
                result.error = .failedToFetch(message: "Talent not found")
                callback?(result)
                return
            }
            
            for child in talentSnapshot.children {
                guard let talentChild = child as? DataSnapshot else {
                    continue
                }
                
                let talent = Talent(with: talentChild)
                talents.append(talent)
            }
            

            var talentList = TalentList()
            talentList.talents = talents
            result.talents = talentList
            callback?(result)
            return
        
        })
    }
    
    func fetchTalent(id: String, callback: ((TalentServiceResult) -> Void)?) {
        var result = TalentServiceResult()
        
        guard session.isValid else {
            result.error = .authenticationNotFound(message: "Authentication not found")
            callback?(result)
            return
        }
        
        let path1 = "talent/\(id.replaceFirstOccurrence(of: " ", to: ""))"
        let rootRef = Database.database().reference()
        let talentRef = rootRef.child(path1)
        
        talentRef.observeSingleEvent(of: .value, with: { talentSnapshot in
            guard talentSnapshot.exists(),
                let _ = talentSnapshot.childSnapshot(forPath: "Nombre").value as? String else {
                    result.error = .failedToFetch(message: "Talent not found")
                    callback?(result)
                    return
            }
            
            let talent = Talent(with: talentSnapshot)
            var listTalent = TalentList()
            listTalent.talents.append(talent)
            result.talents = listTalent
            callback?(result)
            return
        })
    }
    
    var session: AuthSession
    
    init(session: AuthSession) {
        self.session = session
        Database.database().reference().keepSynced(true)
    }
    
}
