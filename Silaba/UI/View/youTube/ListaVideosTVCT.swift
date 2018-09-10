//
//  ListaVideosTVCT.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 17/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit

class ListaVideosTVCT: UITableViewController {
    
    var resultVideos = NSMutableArray()
    var selectionImage: String!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let downloadGroup = DispatchGroup()
        downloadGroup.enter()
        if (self.selectionImage != nil) {
            YouTubeServicesProvider().getVideoWithTextSearch(searchText: self.selectionImage!, nextPageToken: "") { (videosArray, succses, nextpageToken) in
                if(succses == true){
                    self.resultVideos.addObjects(from: videosArray)
                }
                downloadGroup.leave()
            }

            downloadGroup.notify(queue: DispatchQueue.main) { // 2
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultVideos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "youTubeVideoList", for: indexPath) as! youTubeListTableViewCell
        
        let videoDetails = resultVideos[indexPath.row] as! Dictionary<String, AnyObject>
        let name:String = videoDetails["videoTitle"] as! String
        let subTitle:String = videoDetails["videoSubTitle"] as! String
        let videoThumb:String = videoDetails["imageUrl"] as! String
        let videoId:String = videoDetails["videoId"] as! String
        cell.configCell(withVideoName: name, withSubTitle: subTitle, withVideoThumb: videoThumb, withVideoUrl: videoId )
        
        return cell
    }

}
