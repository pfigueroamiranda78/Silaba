//
//  FirebaseUser.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 27/03/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import FirebaseAuth

class FirebaseUserWrapper: UserWrapper {
    
    private let user : User
    
    init(usr: User) {
        self.user = usr
    }
    
    override func getUserWrapper()->UserWrapper {
        return self
    }
    
}
