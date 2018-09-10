//
//  AuthWrapper.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 27/03/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

protocol AuthWrapper {
    
    func authByEmail(withEmail Email: String, withPassword Password: String, completion: @escaping (Bool, UserAdapter)->())
    func getSingleton()-> AuthWrapper
}
