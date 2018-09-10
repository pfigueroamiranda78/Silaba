
//
//  PostComposerNavigationController.swift
//  Photostream
//
//  Created by Mounir Ybanez on 25/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import UIKit
import AVKit

protocol PostComposerDelegate: class {
    
    func postComposerDidFinish(with image: UIImage, content: String, recognize_type: String, machineLearningList: MachineLearningList, talent: Talent)
     func postComposerDidFinish(with video: AVPlayerItem, content: String, recognize_type: String, machineLearningList: MachineLearningList, talent: Talent)
    func postComposerDidCancel()
}

class PostComposerNavigationController: UINavigationController {

    weak var moduleDelegate: PostComposerDelegate?
    
    var photoPicker: PhotoPickerViewController!
    var photoShare: PhotoShareViewController!
    var videoShare: VideoShareViewController!
    
    required convenience init(photoPicker: PhotoPickerViewController, photoShare: PhotoShareViewController, videoShare: VideoShareViewController) {
        
        self.init(rootViewController: photoPicker)
        self.photoPicker = photoPicker
        self.photoShare = photoShare
        self.videoShare = videoShare
    }
    
    override func loadView() {
        super.loadView()
        
        navigationBar.isTranslucent = false
        navigationBar.tintColor = UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1)
        
    }
    
    
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}

extension PostComposerNavigationController: PhotoPickerModuleDelegate {
    
    func videoPickerDidFinish(with playeritem: AVPlayerItem?, with identifier: MachineLearningList?) {
        guard playeritem != nil else {
            return
        }
        videoShare.video = playeritem
        if (identifier != nil) {
            videoShare.machineLearningList = identifier
        } else {
            if (videoShare.machineLearningList == nil) {
                let alertController = UIAlertController(title: "Antes de finalizar", message: "Intenta reconocer el contenido de la foto.", preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("Ok button tapped");
                }
                
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
        }
        
        pushViewController(videoShare, animated: true)
    }
    
    
    
    func photoPickerSetTalent(with talentList: TalentList) {
        photoShare.talentList = talentList
        videoShare.talentList = talentList
    }
    
    func photoPickerSetThing(with thingList:ThingList ) {
        photoShare.thingList = thingList
        videoShare.thingList = thingList
    }
    
    func photoPickerSetFollow(with userList: [User]) {
        photoShare.userList = userList
        videoShare.userList = userList
    }
    
    func photoPickerDidCancel() {
        moduleDelegate?.postComposerDidCancel()
        dismiss()
    }
    
    func photoPickerDidFinish(with image: UIImage?, with identifier: MachineLearningList?) {
        guard image != nil else {
            return
        }
        photoShare.image = image
        if (identifier != nil) {
            photoShare.machineLearningList = identifier
        } else {
             if (photoShare.machineLearningList == nil) {
                let alertController = UIAlertController(title: "Antes de finalizar", message: "Intenta reconocer el contenido de la foto.", preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("Ok button tapped");
                }
                
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
        }
        
        
        pushViewController(photoShare, animated: true)
    }
    
    func photoAsSampleBuffer(with identifier: MachineLearningList?) {
        print ("Identificado: "+(identifier?.mejorIdenficador)!)
        photoShare.machineLearningList = identifier
        videoShare.machineLearningList = identifier
    }
    
    
}

extension PostComposerNavigationController: VideoShareModuleDelegate {
    func videoShareDidCancel() {
        videoShare.video = nil
        let _ = popViewController(animated: true)
    }
    
    func videoShareDidFinish(with video: AVPlayerItem, content: String) {
        if (videoShare.machineLearningList == nil) {
            let alertController = UIAlertController(title: "Antes de finalizar", message: "Intenta reconocer el contenido del video.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                print("Ok button tapped");
            }
            
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        moduleDelegate?.postComposerDidFinish(with: video, content: content, recognize_type: videoShare.recognizeType, machineLearningList: videoShare.machineLearningList, talent: videoShare.selectedTalent)
        dismiss()
    }
}

extension PostComposerNavigationController: PhotoShareModuleDelegate {
    
    func photoShareDidCancel() {
        photoShare.image = nil
        let _ = popViewController(animated: true)
    }
    
    func photoShareDidFinish(with image: UIImage, content: String) {
        if (photoShare.machineLearningList == nil) {
            let alertController = UIAlertController(title: "Antes de finalizar", message: "Intenta reconocer el contenido de la foto.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                print("Ok button tapped");
            }
            
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        moduleDelegate?.postComposerDidFinish(with: image, content: content, recognize_type: photoShare.recognizeType, machineLearningList: photoShare.machineLearningList, talent: photoShare.selectedTalent)
        dismiss()
    }
}
