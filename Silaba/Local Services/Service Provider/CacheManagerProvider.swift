//
//  CacheManagerProvider.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 7/07/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
public enum Result<T> {
    case success(T)
    case failure(NSError)
}

class CacheManager {
    
    static let shared = CacheManager()
    
    private let fileManager = FileManager.default
    
    private lazy var mainDirectoryUrl: URL = {
        
        let documentsUrl = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return documentsUrl
    }()
    
    func getFileWith(stringUrl: String, completionHandler: @escaping (Result<URL>) -> Void ) {
        
        
        let file = directoryFor(stringUrl: stringUrl)
        
        //return file path if already exists in cache directory
        guard !fileManager.fileExists(atPath: file.path)  else {
            completionHandler(Result.success(file))
            return
        }
        
        DispatchQueue.global().async {
            
            if let videoData = NSData(contentsOf: URL(string: stringUrl)!) {
                videoData.write(to: file, atomically: true)
                
                DispatchQueue.main.async {
                    completionHandler(Result.success(file))
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(Result.failure(NSError(domain: "Can't download video", code: 401, userInfo: nil)))
                }
            }
        }
    }
    
    private func directoryFor(stringUrl: String) -> URL {
        
        let fileURL = URL(string: stringUrl)!.lastPathComponent
        
        let file = self.mainDirectoryUrl.appendingPathComponent(fileURL)
        
        return file
    }
}

