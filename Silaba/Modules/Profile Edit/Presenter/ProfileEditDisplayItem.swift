//
//  ProfileEditDisplayItem.swift
//  Photostream
//
//  Created by Mounir Ybanez on 09/01/2017.
//  Copyright © 2017 Mounir Ybanez. All rights reserved.
//

enum ProfileEditDisplayItemType {
    
    case none
    case username
    case firstName
    case lastName
    case bio
    
    var labelText: String {
        switch self {
            
        case .username:
            return "Nombre de usuario"
        
        case .firstName:
            return "Nombres"
        
        case .lastName:
            return "Apellidos"
        
        case .bio:
            return "Biografía"
        
        case .none:
            return ""
        }
    }
}

struct ProfileEditDisplayItem {
    
    var infoEditText: String = ""
    var isEditable: Bool = false
    var type: ProfileEditDisplayItemType = .none
}
