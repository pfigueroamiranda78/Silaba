//
//  TableViewController.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 27/03/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class FeedVC: UITableViewController {
    
    var posts = [Poste]()
    var currentUserImageUrl: String!
    var selectedPost : Poste!
    var reto: Reto!
    var selectedImage : UIImage!
    var needRefresh: Bool! = false

    @IBOutlet weak var tableViewCell: PostCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let firebasepost = Posting(withEstrategia: FirebasePostStrategy())
        let userId = KeychainWrapper.standard.string(forKey: "uid")
        currentUserImageUrl = KeychainWrapper.standard.string(forKey: "userImgUrl")
        posts.removeAll()
        firebasepost.getPosts(withUserId: userId!, ofReto: reto) { (success, post) in
            if (success) {
                self.posts = post!
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (self.needRefresh) {
            let firebasepost = Posting(withEstrategia: FirebasePostStrategy())
            let userId = KeychainWrapper.standard.string(forKey: "uid")
            currentUserImageUrl = KeychainWrapper.standard.string(forKey: "userImgUrl")
            posts.removeAll()
            firebasepost.getPosts(withUserId: userId!, ofReto: reto) { (success, post) in
                if (success) {
                    self.posts = post!
                    self.tableView.reloadData()
                }
            }
            needRefresh = false
        }
    }
    
    @objc func toCreatePost(_ sender: AnyObject) {
        performSegue(withIdentifier: "toCreatePost", sender: nil)
    }

    @objc func toComments(_ sender: AnyObject) {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        let indexPath: IndexPath? = tableView.indexPathForRow(at: buttonPosition)
        var fila = indexPath?.row
        fila = fila! - 1
        selectedPost = posts[fila!]
        performSegue(withIdentifier: "toComments", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toComments"?:
            let destino = segue.destination as! CommentsVC
            destino.post = self.selectedPost
            destino.PassedExperience = reto
        case "toCreatePost"?:
            let destino = segue.destination as! PostViC
            destino.PassedExperience = reto
        case "showImg"?:
            let destino = segue.destination as! showImgExperience
            destino.image = selectedImage
        default:
            return
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
        return 1 + posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ShareComments", for: indexPath) as? ShareCommentsTableViewCell {
                cell.configCell(withUserUrlImg: currentUserImageUrl)
                //cell.shareBtn.addTarget(self, action: #selector(toCreatePost), for: .touchUpInside)
                return cell
            }
        }
       
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell else {
            return UITableViewCell()
        }
        
        cell.configCell(post: posts[indexPath.row-1])
        cell.commentBtn.addTarget(self, action: #selector(toComments), for: .touchUpInside)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row > 0) {
            
            guard let cell = tableView.cellForRow(at: indexPath) as? PostCell else {
                return
            }
            selectedImage = cell.imgView.image
            performSegue(withIdentifier: "showImg", sender: nil)
        }
    }
}
