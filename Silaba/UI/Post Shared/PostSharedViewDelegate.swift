//
//  PostSharedViewDelegate.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

import UIKit

extension PostSharedViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row == presenter.shareCount - 10 else {
            return
        }
        
        presenter.loadMore()
    }
}

extension PostSharedViewController: UserTableCellDelegate {
    
    func didTapAction(cell: UserTableCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        presenter.toggleFollow(at: indexPath.row)
    }
    
    func didTapDisplayName(cell: UserTableCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        presenter.presentUserTimeline(for: indexPath.row)
    }
}
