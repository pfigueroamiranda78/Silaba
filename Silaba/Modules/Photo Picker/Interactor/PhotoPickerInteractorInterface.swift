//
//  PhotoPickerInteractorInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 21/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol PhotoPickerInteractorInterface: class {
    
    var output: PhotoPickerInteractorOutput? { set get }
    
    init(service: TalentService, service_thing: ThingService, service_users: UserService)
}
