//
//  Autenticacion.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 27/03/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

final class Autenticacion: Autenticar {

    private let estrategia : Autenticar
    
    init(withEstrategia estrategia: Autenticar) {
        self.estrategia  = estrategia
    }
    // Autenticacion por email
    func ByEmail(withEmail Email: String, withPassword Password: String, completion: @escaping (Bool, Usuario?) -> ()) {
        
        self.estrategia.ByEmail(withEmail: Email, withPassword: Password) { (sucess, user) in
            completion(sucess, user)
        }
    }
    // Adiciona a alguien que quiero seguir
    func addUser(fromUserId UserId:String, toUser Usuario: Usuario, completion: @escaping (Bool) -> ()) {
        self.estrategia.addUser(fromUserId: UserId, toUser: Usuario) { (success) in
            completion(success)
        }
    }
    func addUser(fromUserId UserId: String, toUserId UserIdTo: String, completion: @escaping (Bool) -> ()) {
        self.estrategia.addUser(fromUserId: UserId, toUserId: UserIdTo) { (success) in
            completion(success)
        }
    }
    // Crea un usuario para registro
    func createUser(withEmail Email: String, withPassword Password: String, completion: @escaping (Bool, Usuario?) -> ()) {
        
        self.estrategia.createUser(withEmail: Email, withPassword: Password) { (sucess, user) in
            completion(sucess, user)
        }
    }
    // Adicionar datos al usuario registrado.
    func storeUser(withUserId UserId:String, withUsername Username: String, withUserImg UserImage: Data?, withEmail Email: String, completion: @escaping (Bool, Usuario?) -> ()) {

        self.estrategia.storeUser(withUserId: UserId, withUsername: Username, withUserImg: UserImage, withEmail: Email) { (sucess, user) in
            completion(sucess, user)
        }
    }
    // Devuelve los datos del usuario por su ID
    func getUser(withUserId userId: String, completion: @escaping (Usuario?) -> ()) {
        self.estrategia.getUser(withUserId: userId) { (Usuario) in
            completion(Usuario)
        }

    }
    // Devuelve los datos del usuario por su email
    func getUsers(withEmail Email: String, completion: @escaping (Usuario?) -> ()) {
        self.estrategia.getUsers(withEmail: Email) { (Usuario) in
            completion(Usuario)
        }
    }
    // Devuelve un conjunto de usuarios y sus datos del usuario por su nombre
    func getUsers(withUsername Username: String, completion: @escaping ([Usuario]?) -> ()) {
        self.estrategia.getUsers(withUsername: Username) { (Usuarios) in
            completion(Usuarios)
        }
    }
    
    func SignOut() {
        self.estrategia.SignOut()
    }
    
    func getUserImage(withUserId UserId: String, completion: @escaping (Bool, Data?) -> ()) {
        self.estrategia.getUserImage(withUserId: UserId) { (success, data) in
            completion(success, data)
        }
    }
    
    func getUserUrlImage(withUserId UserId: String, completion: @escaping (Bool, String?) -> ()) {
        self.estrategia.getUserUrlImage(withUserId: UserId) { (success, url) in
            completion(success, url)
        }
    }
    
    func getPostImage(withPostUrl PostUrl: String, completion: @escaping (Bool, Data?) -> ()) {
        self.estrategia.getPostImage(withPostUrl: PostUrl) { (success, data) in
            completion(success, data)
        }
    }

}
