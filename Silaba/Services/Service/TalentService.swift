//
//  talentService.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 21/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//


import Foundation

protocol TalentService {
    
    init(session: AuthSession)
    
    func fetchTalentAll(callback: ((TalentServiceResult) -> Void)?) 
    func fetchTalent(id: String,callback: ((TalentServiceResult) -> Void)?)

}

struct TalentServiceResult {
    
    var talents: TalentList?
    var error: TalentServiceError?
    var nextOffset: String?
}


enum TalentServiceError: Error {
    
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


