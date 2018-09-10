//
//  PhotoPickerInteractor.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 15/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit
import GPUImage


class PhotoPickerInteractor: PhotoPickerInteractorInterface {
    
    weak var output: PhotoPickerInteractorOutput?
    var service: TalentService!
    var service_thing: ThingService!
    var service_users: UserService!
    
    required init(service: TalentService, service_thing: ThingService, service_users: UserService) {
        self.service = service
        self.service_thing = service_thing
        self.service_users = service_users
    }
}

extension PhotoPickerInteractor: PhotoPickerInteractorInput {

    
    func fetchTalentAll() {
        let limit: UInt = 100
        
        service.fetchTalentAll() { (talentResult) in
            self.output?.photoPickerDidFetchTalent(with: talentResult)
            
            self.service_thing.fetchThingAll(ofTalentList: talentResult.talents!, limit: limit) { (thingResult) in
                
                self.output?.photoPickerDidFetchThing(with: thingResult)
               
            }
            let uid = AuthSession().user.id
            
            self.service_users.fetchFollowing(id: uid, offset: "", limit: limit, callback: { (userResult) in
                self.output?.photoPickerDidiFecthFollowing(with: userResult)
            })
        }
    }
}
