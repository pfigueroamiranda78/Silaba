//
//  PhotoPickerInteractorOutput.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 21/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol PhotoPickerInteractorOutput: class {
   
    func photoPickerDidFetchTalent(with result: TalentServiceResult)
    func photoPickerDidFetchThing(with result: ThingServiceResult)
    func photoPickerDidiFecthFollowing(with result: UserServiceFollowListResult)
    
}
