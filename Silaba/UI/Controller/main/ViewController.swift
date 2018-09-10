//
//  ViewController.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 27/03/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper


class ViewController: UIViewController
 {


    @IBOutlet weak var userImgView: UIImageView!
    
    @IBOutlet weak var ImgView: UIImageView!
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var imagePicker: UIImagePickerController!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: "uid") {
            self.performSegue(withIdentifier: "Feed", sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        
        if let email = emailField.text, let password = passwordField.text {
            let firebase = Autenticacion(withEstrategia: FirebaseAuthStrategy())
            firebase.ByEmail(withEmail: email, withPassword: password) {(result, user) in
                if (result) {
                    // Se autenticó
                    if let userId = user?.getUserId() {
                        KeychainWrapper.standard.set(userId, forKey: "uid")
                        KeychainWrapper.standard.set((user?.username)!, forKey: "username")
                        KeychainWrapper.standard.set((user?.userImg)!, forKey: "userImgUrl")
                        self.performSegue(withIdentifier: "Feed", sender: nil)
                    }
                } else {
                    // Se puede crear
                    if (!(self.usernameField.text?.isEmpty)! && self.ImgView.image != nil) {
                        firebase.createUser(withEmail: email, withPassword: password) {(result, user) in
                            if (result) {
                                let imageData = UIImageJPEGRepresentation(self.ImgView.image!, 0.2)
                                firebase.storeUser(withUserId: (user?.getUserId())!, withUsername: self.usernameField.text!, withUserImg: imageData, withEmail: self.emailField.text!) { (result, user2) in
                                        if (result) {
                                            KeychainWrapper.standard.set((user?.getUserId())!, forKey: "uid")
                                            KeychainWrapper.standard.set(self.usernameField.text!, forKey: "username")
                                            KeychainWrapper.standard.set((user2?.userImg)!, forKey: "userImgUrl")
                                            self.performSegue(withIdentifier: "Feed", sender: nil)
                                        }
                                    }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func getPhoto(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.ImgView.image = image
        } else {
            print("No se selección una imagen")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

