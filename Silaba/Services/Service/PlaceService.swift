//
//  PlaceService.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 15/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//


import Foundation

protocol PlaceService {
    
    init(session: AuthSession)
    
    func fetchPlaceInfo(id: String, callback: ((PlaceServiceResult) -> Void)?)

}

struct PlaceServiceResult {
    
    var place: Place?
    var error: PlaceServiceError?
    var nextOffset: String?
}


enum PlaceServiceError: Error {
    
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

