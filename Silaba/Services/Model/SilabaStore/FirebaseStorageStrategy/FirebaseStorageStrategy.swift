//
//  FirebaseStorageStrategy.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 7/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import FirebaseStorage
import Reachability
import FirebaseDatabase

class FirebaseStorageStrategy: SilabaStorage {
    
    let reachability = Reachability()!
    
    func Upload(theData data: Data, theTag tag: String, completion: ((Bool, String?)-> (Void))?) {
        var metaData = StorageMetadata()
       
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        }
        
        reachability.whenUnreachable = { _ in
            print("Not reachable")
            completion!(false, "NoConnectionError")
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        let imgUid = NSUUID().uuidString
        //let ref = Storage.storage().reference().child(imgUid)
        let ref = Storage.storage().reference().child("Retos").child(imgUid)

        let uploadTask = ref.putData(data, metadata: metaData) { (metadata, error) in
            if error == nil {
                metaData = metadata!
            } else {
                completion!(false, nil)
            }
            
        }
    
        uploadTask.observe(.resume) { snapshot in
            print ("resume...")
        }
        
        uploadTask.observe(.pause) { snapshot in
            print ("pause...")
            completion! (false, nil)
        }
        
        uploadTask.observe(.progress) { snapshot in
            print ("observe...")

            // Upload reported progress
            //let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
        }
        
        uploadTask.observe(.success) { snapshot in
            
            let customMetadata = ["clasificacion": tag]
            metaData.customMetadata = customMetadata
            ref.updateMetadata(metaData, completion: { (updatedMetada, error) in
                if (error == nil) {
                    uploadTask.removeAllObservers()
                    completion! (true, (metaData.downloadURL()?.absoluteString)!)
                }
                else {
                    completion! (false, nil)
                }
            })

        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as NSError? {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    completion!(false, nil)
                    uploadTask.removeAllObservers()
                    break
                case .unauthorized:
                    completion!(false, nil)
                    uploadTask.removeAllObservers()
                    self.reachability.stopNotifier()
                    break
                case .cancelled:
                    // User canceled the upload
                    break
                    
                    /* ... */
                    
                case .unknown:
                    completion!(false, nil)
                     uploadTask.removeAllObservers()
                    break
                default:
                    // A separate error occurred. This is a good place to retry the upload.
                    break
                }
            }
        }
    }
    func Download(withUrl Url: String, completion: ((Bool, Data?, String?)-> (Void))?) {
        let ref = Storage.storage().reference(forURL: Url)
        ref.getData(maxSize: 100000000, completion: { (data, error) in
            if error != nil {
                completion!(false, data, nil)
            } else {
                if let Data = data {
                    ref.getMetadata(completion: { (metaData, error) in
                        if error != nil {
                            completion!(true, Data, nil)
                            return
                        }
                        completion!(true, Data, metaData?.customMetadata?.first?.value)
                    })
                }
            }
            
        })
    }
}
