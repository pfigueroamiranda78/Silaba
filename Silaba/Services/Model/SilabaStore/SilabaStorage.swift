//
//  Imagen.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 6/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol SilabaStorage {

    func Upload(theData data: Data, theTag tag: String, completion: ((Bool, String?)-> (Void))?)
    func Download(withUrl Url: String, completion:  ((Bool, Data?, String?) -> (Void))?)
    
}
