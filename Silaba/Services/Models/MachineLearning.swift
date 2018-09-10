//
//  Photo.swift
//  Photostream
//
//  Created by Mounir Ybanez on 17/08/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import Foundation

struct MachineLearning {
    var identificador: String
    var identifier: String
    var confidence: Float
    var videoList: VideoList
    var model: String

    init() {
        identificador = ""
        identifier = ""
        model = ""
        confidence = 0
        videoList = VideoList()
    }
    
    init (withIdentifier identifier: String, withConfidence confidence: Float, withVideoList videoList: VideoList, withIdentificador identificador: String, withMode model: String) {
        self.identifier = identifier
        self.confidence = 0
        self.videoList = videoList
        self.identificador = identificador
        self.model = model
    }
}

struct MachineLearningList {
    
    var machineLearningList: [MachineLearning]
    var count: Int {
        return machineLearningList.count
    }
    
    init() {
        machineLearningList = [MachineLearning]()
    }
    
    var bestIdentifier: String {
        let m0: MachineLearning = machineLearningList[0]
        let m1: MachineLearning = machineLearningList[1]
        if (m0.confidence > m1.confidence) {
            return m0.identifier
        } else {
            return m1.identifier
        }
    }
    
    var bestConfidence: Float {
        let m0: MachineLearning = machineLearningList[0]
        let m1: MachineLearning = machineLearningList[1]
        if (m0.confidence > m1.confidence) {
            return m0.confidence
        } else {
            return m1.confidence
        }
    }
    
    var mejorIdenficador: String {
        let m0: MachineLearning = machineLearningList[0]
        let m1: MachineLearning = machineLearningList[1]
        if (m0.confidence > m1.confidence) {
            if (m0.identificador.count > 0) {
                return m0.identificador
            }
            else {
                return m0.identifier
            }
        } else {
            if (m1.identificador.count > 0) {
                return m1.identificador
            }
            else {
                return m1.identifier
            }
        }
    }
    
    subscript (index: Int) -> (MachineLearning)? {
        if machineLearningList.isValid(index) {
            let machineLearning = machineLearningList[index]
            return (machineLearning)
        }
        return nil
    }
}
