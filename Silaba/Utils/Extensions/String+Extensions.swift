//
//  String+Extensions.swift
//  Photostream
//
//  Created by Mounir Ybanez on 17/08/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import Foundation

extension String {

    var length: Int {
        return self.count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    func substring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
    func reverse() -> String {
        let count = self.count
        if count == 0 { return "" }
        var result = ""
        for i in 0..<count {
            result = self[i] + result
        }
        return result
    }
    
    func NSRangeFromRange(range: Range<String.Index>) -> NSRange? {
        let utf16view = self.utf16
        
        if let from = range.lowerBound.samePosition(in: utf16view), let to = range.upperBound.samePosition(in: utf16view) {
            return NSMakeRange(utf16view.distance(from: utf16view.startIndex, to: from), utf16view.distance(from: from, to: to))
        }
        return nil
    }
    
    mutating func dropTrailingNonAlphaNumericCharacters() {
        let nonAlphaNumericCharacters = NSCharacterSet.alphanumerics.inverted
        let characterArray = components(separatedBy: nonAlphaNumericCharacters)
        if let first = characterArray.first {
            self = first
        }
    }
    
}

extension String {
    
    func contains(s: String) -> Bool
    {
        return (self.range(of:s) != nil) ? true : false
    }
    
    func replaceFirstOccurrence(of target: String, to replacement: String) -> String {
        if let range = self.range(of: target) {
            return self.replacingCharacters(in: range, with: replacement)
        }
        return self
    }
    
    func normalizeToTag() -> String {
        return self.filter({ " ".contains($0) == false }).filter({ "-".contains($0) == false }).filter({ "/".contains($0) == false })
    }
    
    func extractHashTag()->[String] {
        return self.extract(ofTag: "#[a-z0-9]+")
    }
    
    func extractMentionTag()->[String] {
        return self.extract(ofTag: "@[a-z0-9.]+")
    }
    
    func extract(ofTag tag:String)-> [String] {
        do {
            let regex = try NSRegularExpression(pattern: tag, options: .caseInsensitive)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
