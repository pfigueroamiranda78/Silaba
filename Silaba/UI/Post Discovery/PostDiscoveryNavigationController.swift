//
//  PostDiscoveryNavigationController.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 20/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit
import AVKit

protocol PostDiscoveryDelegate: class {
    
    func postDiscoveryFinish(with image: UIImage, content: String, recognize_type: String, machineLearningList: MachineLearningList)
    func postDiscoveryDidCancel()
}

class PostDiscoveryNavigationController: UINavigationController {
    
    weak var moduleDelegate: PostDiscoveryDelegate?
    
    var photoPicker: PhotoPickerDiscoveryViewController!
    var postDiscovery: PostDiscoveryViewController!
    
    required convenience init(photoPicker: PhotoPickerDiscoveryViewController, postDiscover: PostDiscoveryViewController) {
        self.init(rootViewController: photoPicker)
        self.photoPicker = photoPicker
        self.postDiscovery = postDiscover
        self.photoPicker.nextControlller = postDiscovery
        
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

extension PostDiscoveryNavigationController: PhotoPickerDiscoveryModuleDelegate {
    func photoPickerDiscoveryDidFinish(with video: AVPlayerItem?, with identifier: MachineLearningList?) {
        guard video != nil else {
            return
        }
        postDiscovery.video = video
        
        if (identifier != nil) {
            postDiscovery.machineLearningList = identifier
            
        } else {
            
            if (postDiscovery.machineLearningList == nil) {
                let alertController = UIAlertController(title: "Antes de finalizar", message: "Intenta reconocer el contenido de la foto.", preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("Ok button tapped");
                }
                
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
        }
        
        pushViewController(postDiscovery, animated: true)
        postDiscovery.triggerRefresh()
    }
    

    func photoPickerSetTalent(with talentList: TalentList) {
        photoPicker.talentList = talentList
    }
        
    
    func photoPickerDiscoveryDidCancel() {
        moduleDelegate?.postDiscoveryDidCancel()
        dismiss()
    }
    
    func photoPickerDiscoveryDidFinish(with image: UIImage?, with identifier: MachineLearningList?) {
        guard image != nil else {
            return
        }
        postDiscovery.image = image
        
        if (identifier != nil) {
            postDiscovery.machineLearningList = identifier
           
        } else {
            
            if (postDiscovery.machineLearningList == nil) {
                let alertController = UIAlertController(title: "Antes de finalizar", message: "Intenta reconocer el contenido de la foto.", preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("Ok button tapped");
                }
                
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
        }

        pushViewController(postDiscovery, animated: true)
        postDiscovery.triggerRefresh()
    }
    
    func photoDiscoveryAsSampleBuffer(with identifier: MachineLearningList?) {
        print ("Identificado: "+(identifier?.mejorIdenficador)!)
        postDiscovery.machineLearningList = identifier
    }
    
}


extension PostDiscoveryNavigationController: PostDiscoveryModuleDelegate {
    
    func postDiscoverDidBack() {
        postDiscovery.image = nil
        postDiscovery.machineLearningList = nil
        postDiscovery.video = nil
        let _ = popViewController(animated: true)
    }
}
