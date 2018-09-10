//
//  ThnigService.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 5/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation


protocol ThingService {
    
    init(session: AuthSession)
    func fetchThingAll(ofTalentList talentList: TalentList, limit: UInt, callback: ((ThingServiceResult) -> Void)?)
}

struct ThingServiceResult {
    
    var things: ThingList?
    var error: ThingServiceError?
    var nextOffset: String?
}


enum ThingServiceError: Error {
    
    case authenticationNotFound(message: String)
    case failedToFetch(message: String)
    
    
    var message: String {
        switch self {
        case .authenticationNotFound(let message):
            return message
        case .failedToFetch(let message):
            return message
        }
    }
}
