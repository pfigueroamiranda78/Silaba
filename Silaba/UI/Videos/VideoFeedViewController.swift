//
//  VideoFeedViewController.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 30/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit



@objc protocol VideoFeedViewControllerAction: class {
    
    func back()
    func triggerRefresh()
}

class VideoFeedViewController: UITableViewController, VideoFeedViewControllerAction {
    
    var presenter: VideoFeedModuleInterface!
    var indicatorView: UIActivityIndicatorView!
    var emptyView: VideoFeedEmptyView!
    var refreshView: UIRefreshControl!
    
    var shouldShowInitialLoadView: Bool = false {
        didSet {
            guard oldValue != shouldShowInitialLoadView else {
                return
            }
            
            if shouldShowInitialLoadView {
                tableView.backgroundView = indicatorView
                indicatorView.startAnimating()
            } else {
                indicatorView.stopAnimating()
                tableView.backgroundView = nil
            }
        }
    }
    
    var shouldShowEmptyView: Bool = false {
        didSet {
            guard oldValue != shouldShowEmptyView else {
                return
            }
            
            if shouldShowEmptyView {
                emptyView.frame.size = tableView.bounds.size
                tableView.backgroundView = emptyView
            } else {
                tableView.backgroundView = nil
            }
        }
    }
    
    var shouldShowRefreshView: Bool = false {
        didSet {
            if refreshView.superview == nil {
                tableView.addSubview(refreshView)
            }
            
            guard oldValue != shouldShowRefreshView else {
                return
            }
            
            if shouldShowRefreshView {
                refreshView.beginRefreshing()
            } else {
                refreshView.endRefreshing()
            }
        }
    }
    
    var prototype = VideoListCell()
    
    override func loadView() {
        super.loadView()
        
        refreshView = UIRefreshControl()
        refreshView.addTarget(self, action: #selector(self.triggerRefresh), for: .valueChanged)
        
        indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicatorView.hidesWhenStopped = true
        
        emptyView = VideoFeedEmptyView()
        emptyView.messageLabel.text = "Sin videos"
        
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        
        VideoListCell.register(in: tableView)
        
        title = "Videos"
        
        let barItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back_nav_icon"), style: .plain, target: self, action: #selector(self.back))
        navigationItem.leftBarButtonItem = barItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.refreshVideos()
    }
    
    func back() {
        presenter.exit()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.videoCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = VideoListCell.dequeue(from: tableView)!
        let video = presenter.view(at: indexPath.row) as? VideoListCellItem
        cell.configure(with: video)
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let video = presenter.view(at: indexPath.row) as? VideoListCellItem
        prototype.configure(with: video, isPrototype: true)
        return prototype.dynamicHeight
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == presenter.videoCount - 10 {
            presenter.loadMoreVideos()
        }
    }
    
    func triggerRefresh() {
        presenter.refreshVideos()
    }
}

extension VideoFeedViewController: VideoFeedScene {
    func didRefreshVideos(with error: String?) {
    
    }
    
    func didLoadMoreVideos(with error: String?) {
    
    }
    
    var controller: UIViewController? {
        return self
    }
    
    func reload() {
        tableView.reloadData()
    }
    
    func showEmptyView() {
        shouldShowEmptyView = true
    }
    
    func showInitialLoadView() {
        shouldShowInitialLoadView = true
    }
    
    func showRefreshView() {
        shouldShowRefreshView = true
    }
    
    func hideEmptyView() {
        shouldShowEmptyView = false
    }
    
    func hideInitialLoadView() {
        shouldShowInitialLoadView = false
    }
    
    func hideRefreshView() {
        shouldShowRefreshView = false
    }
}


extension VideoFeedViewController: VideoListCellDelegate {
    
    func didTapAuthor(cell: VideoListCell) {
        guard let index = tableView.indexPath(for: cell)?.row else {
            return
        }
        
        guard let video = presenter.view(at: index) as? VideoListCellItem else {
            return
        }
        
        let yt="youtube://"+video.id
        var url2=URL(string:yt)!
        if !UIApplication.shared.canOpenURL(url2)  {
            let yt2 = "http://www.youtube.com/watch?v="+video.id
            url2 = URL(string:yt2)!
        }
        UIApplication.shared.open(url2, options: [:], completionHandler: nil)
    }
}
