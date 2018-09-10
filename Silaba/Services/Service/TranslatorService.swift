//
//  Translator.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 27/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol TranslatorService
{
    func translate(inputData: TranslateSearchData, callback:((TranslateServiceResult) -> Void)?)
}


struct TranslateSearchData {
    var source: String
    var target: String
    var text:   String
    var text2:   String
}

struct TranslateServiceResult {
    
    var translated: String?
    var translated2: String?
    var error: TranslateServiceError?
}

enum TranslateServiceError: Error {
    case notTranslation(message: String)
   
    var message: String {
        switch self {
        case .notTranslation(let message):
            return message
        }
    }
}
