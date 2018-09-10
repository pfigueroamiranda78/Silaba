//
//  AmigoCell.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 5/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class AmigoCell: UITableViewCell {

    @IBOutlet weak var usermail: UITextField!
    var tableView: AmigosTVC!
    
    @IBAction func buscarAmigos(_ sender: Any) {
        
        tableView.usermail = self.getUsermail()
        tableView.Usuarios.removeAll()
        let firebase = Autenticacion(withEstrategia: FirebaseAuthStrategy())
        firebase.getUsers(withEmail: self.getUsermail()) { (Usuario) in
            self.tableView.Usuarios.append(Usuario!)
            self.tableView.tableView.reloadData()
        }
        firebase.getUsers(withUsername: self.getUsermail()) { (Usuario) in
            for usuario in Usuario! {
                self.tableView.Usuarios.append(usuario)
                self.tableView.tableView.reloadData()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func getUsermail() -> String! {
        return usermail.text!.lowercased()
    }
    
    func configCell(isFromTableView tableView: AmigosTVC) {
        self.tableView = tableView
    }
}
