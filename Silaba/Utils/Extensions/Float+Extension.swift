//
//  Float+Extension.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 30/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation


extension Float {
    
    func round(digit dig:Int)->String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = dig
        return formatter.string(from: (self*100) as NSNumber)!
    }
}
