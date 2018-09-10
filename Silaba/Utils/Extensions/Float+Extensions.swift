//
//  Float+Extensions.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 28/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation


extension Float {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}
