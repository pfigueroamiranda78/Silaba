//
//  ListaAmigos.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 5/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class ListaAmigosCell: UITableViewCell {
    
    var Usuario: Usuario!

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var conectBtn: UIButton!
    @IBOutlet weak var userImgView: CircleView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func connect(_ sender: Any) {
        
        let firebase = Autenticacion(withEstrategia: FirebaseAuthStrategy())
        let userID = KeychainWrapper.standard.string(forKey: "uid")
        firebase.addUser(fromUserId: userID!, toUser: Usuario) { (success) in
            if (success) {
                self.username.isOpaque = true
                self.conectBtn.isEnabled = false
                self.conectBtn.titleLabel?.text = "Siguiendo"
            }
        }
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(withUserId userId: String, usuario :Usuario) {
        self.username.text = usuario.username
        self.Usuario = usuario
        let firebase = Autenticacion(withEstrategia: FirebaseAuthStrategy())
        firebase.getUserImage(withUserId: usuario.userIden) { (success, data) in
            let image = UIImage(data: data!)
            self.userImgView.image = image
            
            for seguido in usuario.getSeguido() {
                if (userId == seguido) {
                    self.conectBtn.isEnabled = false
                    self.conectBtn.titleLabel?.text = "Siguiendo"
                }
            }
            
        }
    }

}
