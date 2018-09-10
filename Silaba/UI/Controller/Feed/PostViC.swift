//
//  PostViC.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 4/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class PostViC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    @IBOutlet weak var PostText: UITextView!
    @IBOutlet weak var ImgView: UIImageView!
    @IBOutlet weak var btnCompartirTop: UIBarButtonItem!
    @IBOutlet weak var btnCompartirDown: UIButton!
    var PassedExperience : Reto!
    var imagePicker: UIImagePickerController!
    var placeholderLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
        PostText.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = " Describe aquí tu publicación"
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (PostText.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        PostText.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (PostText.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !PostText.text.isEmpty
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Publicar(_ sender: Any) {
        save()
    }
    func isReadyForSave() {
        if (ImgView.image != nil && !PostText.text.isEmpty)  {
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
        let imageData = UIImageJPEGRepresentation(ImgView.image!, 0.2)
        let firebaseStorage = SilabaStoring(withEstrategia: FirebaseStorageStrategy())
        firebaseStorage.Upload(theData: imageData!, theTag: "Publication") { (success, url) in
            if (success) {
                firebasepost.addPost(withUserId: userID!, withTextPost: self.PostText.text, ofReto: self.PassedExperience, withImageUrl: url!) { (success, post) in
                    if (success) {
                        let i = self.navigationController?.viewControllers.index(of: self)
                        if let Feed = self.navigationController?.viewControllers[i!-1] as? FeedVC {
                            Feed.needRefresh = true
                        }
                        super.navigationController?.popViewController(animated: true)
                        print("post creado")
                    } else {
                        print("post no creado")
                        self.btnCompartirTop.isEnabled = true
                        self.btnCompartirDown.isEnabled = true
                    }
                }
            } else {
                if (url == "NoConnectionError") {
                    let alertController = UIAlertController(title: "Sin conexión", message: "En este momento no tienes conexión a internet, tus datos serán registrados automáticamente cuando estes conectado", preferredStyle: .alert)
                    self.present(alertController, animated: true, completion: nil)
                    let actionOK = UIAlertAction(title: "Aceptar", style: .default) { (action:UIAlertAction) in
                        super.navigationController?.popViewController(animated: true)
                    }
                    alertController.addAction(actionOK)
                }
            }
        }
    }
    
    @IBAction func compartir(_ sender: Any) {
        save()
    }
    
    @IBAction func seleccionImagen(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Tomar una foto", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Escoger una foto", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(photoSourcePicker, animated: true)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerControllerSourceType) {
        self.imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        
        // We always expect `imagePickerController(:didFinishPickingMediaWithInfo:)` to supply the original image.
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.ImgView.contentMode = UIViewContentMode.scaleAspectFit
        self.ImgView.image = image
    
        isReadyForSave()
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
