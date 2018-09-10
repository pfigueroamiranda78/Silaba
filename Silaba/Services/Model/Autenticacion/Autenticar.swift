//
//  Autenticar.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 27/03/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol Autenticar {
    
    func ByEmail(withEmail Email: String, withPassword Password: String, completion: @escaping (Bool, Usuario?)->())
    
    func addUser(fromUserId UserId:String, toUser Usuario: Usuario, completion: @escaping (Bool)->())
    
    func addUser(fromUserId UserId:String, toUserId UserIdTo: String, completion: @escaping (Bool) -> ())
    
    func createUser(withEmail Email: String, withPassword Password: String, completion: @escaping (Bool, Usuario?)->())
    
    func storeUser(withUserId UserId:String, withUsername Username:String, withUserImg UserImage: Data?, withEmail Email: String, completion: @escaping (Bool, Usuario?)->())

    func getUser(withUserId userId: String, completion: @escaping (Usuario?) -> ())
    
    func getUsers(withEmail Email: String, completion: @escaping (Usuario?)->())
    
    func getUsers(withUsername Username: String, completion: @escaping ([Usuario]?)->())
    
    func getUserImage(withUserId UserId:String, completion: @escaping (Bool, Data?)->())
    
    func getUserUrlImage(withUserId UserId:String, completion: @escaping (Bool, String?)->())
    
    func getPostImage(withPostUrl PostUrl:String, completion: @escaping (Bool, Data?)->())
    
    func SignOut()
}
