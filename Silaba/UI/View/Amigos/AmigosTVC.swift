//
//  AmigosTVC.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 5/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class AmigosTVC: UITableViewController {

    var usermail: String!
    var Usuarios = [Usuario]()
    var currentUserId: String!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentUserId = KeychainWrapper.standard.string(forKey: "uid")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        return 1+Usuarios.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AmigoCell")
                as? AmigoCell else {
                    return UITableViewCell()
            }
            cell.configCell(isFromTableView: self)
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListaAmigosCell") as? ListaAmigosCell else {
            return UITableViewCell()
        }
        
        cell.configCell(withUserId: self.currentUserId, usuario: Usuarios[indexPath.row-1])
        return cell
    }
    
   

}
