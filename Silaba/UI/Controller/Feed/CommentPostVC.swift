//
//  CommentPost.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class CommentPost: UIViewController, UITextViewDelegate {

    @IBOutlet weak var postText : UITextView!
    var PassedPost : Poste!
    var PassedExperience: Reto!
    var placeholderLabel : UILabel!
    
    @IBOutlet weak var btnCompartirDown: UIButton!
    @IBOutlet weak var btnCompartirTop: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postText.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = " Describe aquí tu comentario"
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (postText.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        postText.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (postText.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !postText.text.isEmpty
        isReadyForSave()
        // Do any additional setup after loading the view.
    }
    @IBAction func Comentar(_ sender: Any) {
        save()
    }
    
    func isReadyForSave() {
        if (!postText.text.isEmpty)  {
            btnCompartirTop.isEnabled = true
            btnCompartirDown.isEnabled = true
        } else {
            btnCompartirTop.isEnabled = false
            btnCompartirDown.isEnabled = false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        isReadyForSave()
    }
    
    func save() {
        btnCompartirTop.isEnabled = false
        btnCompartirDown.isEnabled = false
        let userID = KeychainWrapper.standard.string(forKey: "uid")
        let firebasepost = Posting(withEstrategia: FirebasePostStrategy())
        firebasepost.addCommentPost(withUserId: userID!, withTextPost: postText.text, ofReto: PassedExperience, ofPost: PassedPost) { (success, post) in
            if (success) {
                let i = self.navigationController?.viewControllers.index(of: self)
                if let PCommentVC = self.navigationController?.viewControllers[i!-1] as? CommentsVC {
                    PCommentVC.needRefresh = true
                }
                super.navigationController?.popViewController(animated: true)
                print("comment creado")
            } else {
                print("comment no creado")
                self.btnCompartirTop.isEnabled = true
                self.btnCompartirDown.isEnabled = true
            }
        }
    }
    
    @IBAction func post(_ sender: AnyObject) {
        save()
    }

}
