//
//  HashTagTableViewCell.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 5/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit

class HashTagTableViewCell: UIView {

    @IBOutlet weak var tableView: UITableView!
    
    public class func fromNib(nibNameOrNil: String? = nil) -> Self {
        return fromTheNib(nibNameOrNil: nibNameOrNil, type: self)!
    }
    
    public class func fromNib<T : UIView>(nibNameOrNil: String? = nil, type: T.Type) -> T {
        let v: T? = fromTheNib(nibNameOrNil: nibNameOrNil, type: T.self)
        return v!
    }
    
    public class func fromTheNib<T : UIView>(nibNameOrNil: String? = nil, type: T.Type) -> T? {
        var view: T?
        let name: String
        if let nibName = nibNameOrNil {
            name = nibName
        } else {
            // Most nibs are demangled by practice, if not, just declare string explicitly
            name = nibName
        }
        let nibViews = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
        for v in nibViews! {
            if let tog = v as? T {
                view = tog
            }
        }
        return view
    }
    
    public class var nibName: String {
        let name = "\(self)".components(separatedBy :".").first ?? ""
        return name
    }
    public class var nib: UINib? {
        if let _ = Bundle.main.path(forResource: nibName, ofType: "nib") {
            return UINib(nibName: nibName, bundle: nil)
        } else {
            return nil
        }
    }
    
}
