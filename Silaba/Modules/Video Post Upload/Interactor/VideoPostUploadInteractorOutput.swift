//
//  VideoPostUploadInteractorOutput.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/07/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol VideoPostUploadInteractorOutput: class {
    
    func didSucceedVideo(with post: UploadedPost)
    func didFailVideo(with message: String)
    func didUpdateVideo(with progress: Progress)
}
