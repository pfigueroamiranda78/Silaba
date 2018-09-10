//
//  Usuario.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 27/03/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol Usuario  {
    var username: String! { get set }
    var usermail: String! { get set }
    var userImg: String!  { get set }
    var userIden: String! {get set}
    
    func getUserId()->String
    func getSeguido()->[String]
    func getSiguiendo()->[String]
}
