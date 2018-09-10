//
//  CommentsVC.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class CommentsVC: UITableViewController {
    
    var post: Poste!
    var PassedExperience: Reto!
    var comments = [Poste]()
    var needRefresh: Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        comments.removeAll()
        let userId = KeychainWrapper.standard.string(forKey: "uid")
        let firebasepost = Posting(withEstrategia: FirebasePostStrategy())
        
        firebasepost.getComments(withUserId: userId!, ofReto: PassedExperience, ofPost: post) { (success, comments) in
            if (success) {
                self.comments = comments!
                self.tableView.reloadData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {

        
        if (self.needRefresh) {
            comments.removeAll()
            let userId = KeychainWrapper.standard.string(forKey: "uid")
            let firebasepost = Posting(withEstrategia: FirebasePostStrategy())
            
            firebasepost.getComments(withUserId: userId!, ofReto: PassedExperience, ofPost: post) { (success, comments) in
                if (success) {
                    self.comments = comments!
                    self.tableView.reloadData()
                }
            }
            needRefresh = false
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
        // #warning Incomplete implementation, return the number of rows
        return comments.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell else { return UITableViewCell() }
        cell.configCell(post: comments[indexPath.row])

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toCommentPost"?:
            let destino = segue.destination as! CommentPost
            destino.PassedPost = self.post
            destino.PassedExperience = self.PassedExperience
        default:
            return
        }
        
    }
    
    @IBAction func goToComment(_ sender : AnyObject) {
        performSegue(withIdentifier: "toCommentPost", sender: nil)
    }
}
