//
//  Procesar.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 6/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

final class SilabaStoring: SilabaStorage {
    
    private let estrategia : SilabaStorage
    
    init(withEstrategia estrategia: SilabaStorage) {
        self.estrategia  = estrategia
    }
    
    func Upload(theData data: Data, theTag tag: String, completion: ((Bool, String?)-> (Void))?)  {
        self.estrategia.Upload(theData: data, theTag:  tag) { (success, ref) in
            completion!(success, ref)
        }
    }
    
    func Download(withUrl Url: String, completion: ((Bool, Data?, String?) -> (Void))?) {
        if Url.isEmpty {
            completion!(false, nil, nil)
        }
        self.estrategia.Download(withUrl: Url) { (success, data, tag) in
            completion!(success, data, tag)
        }
    }
    
    
}
