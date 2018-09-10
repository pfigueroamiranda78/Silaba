//
//  PostSharedViewDataSource.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit

extension PostSharedViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.shareCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UserTableCell.dequeue(from: tableView)!
        let item = presenter.share(at: indexPath.row) as? UserTableCellItem
        cell.configure(item: item)
        cell.delegate = self
        return cell
    }
}

