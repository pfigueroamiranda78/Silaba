//
//  SimpleViewController.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 17/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import SDWebImage

class SimpleViewController: UIViewController {

    @IBOutlet weak var silabaImgView: UIImageView!
    
    @objc func signOut (_ sender: AnyObject) {
        let firebase = Autenticacion(withEstrategia: FirebaseAuthStrategy())
        KeychainWrapper.standard.removeObject(forKey: "uid")
        KeychainWrapper.standard.removeObject(forKey: "username")
        KeychainWrapper.standard.removeObject(forKey: "userImgUrl")
        firebase.SignOut()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
            
        let menuPicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Crea una experiencia", style: .default) { [unowned self] _ in
             self.performSegue(withIdentifier: "toCreateExperience", sender: nil)
        }
        let choosePhoto = UIAlertAction(title: "Ver tu muro de experiencias", style: .default) { [unowned self] _ in
             self.performSegue(withIdentifier: "Feed", sender: nil)
        }
        
        menuPicker.addAction(takePhoto)
        menuPicker.addAction(choosePhoto)
        menuPicker.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(menuPicker, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Salir", style: .plain, target: self, action: #selector(signOut))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        self.silabaImgView?.isUserInteractionEnabled = true
        self.silabaImgView?.addGestureRecognizer(tapGestureRecognizer)
        let username = KeychainWrapper.standard.string(forKey: "username")
        self.navigationItem.title = username
         SDImageCache.shared().config.shouldCacheImagesInMemory = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
