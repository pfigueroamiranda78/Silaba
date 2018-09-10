//
//  SearchVC.swift
//  SOYoutube
//
//  Created by Hitesh on 11/7/16.
//  Copyright © 2016 myCompany. All rights reserved.
//

import UIKit

class SearchTVC: UITableViewController {

    @IBOutlet weak var tblSearchVideos: UITableView!
    @IBOutlet weak var searchBarvideo: UISearchBar!
    
    var arrSearch = NSMutableArray()
    
    @IBOutlet weak var actionBack: UIButton!
    
    
    //MARK: - UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSearch.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell? {
        let cell:VideoListCell = tableView.dequeueReusableCell(withIdentifier: "VideoListSearchCell", for: indexPath as IndexPath) as! VideoListCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        let videoDetails = arrSearch[indexPath.row] as! Dictionary<String, AnyObject>
        
        cell.lblVideoName.text = videoDetails["videoTitle"] as? String
        cell.lblSubTitle.text = videoDetails["videoSubTitle"] as? String
        
        cell.imgVideoThumb.sd_setImage(with: NSURL(string: (videoDetails["imageUrl"] as? String)!)! as URL)
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

    }


    @IBAction func actionBack(sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
