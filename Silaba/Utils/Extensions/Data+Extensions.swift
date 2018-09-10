//
//  Data+Extensions.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 27/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

extension Date {
    
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    init(millis: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(millis / 1000))
        self.addTimeInterval(TimeInterval(Double(millis % 1000) / 1000 ))
    }
    
}
