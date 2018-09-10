//
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 15/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//
//  Created by Hitesh on 11/7/16.
//  Copyright © 2016 myCompany. All rights reserved.
//
import SwiftKeychainWrapper
import CoreML
import Vision
import ImageIO
import AVFoundation


class MachineLearningServicesProvider: NSObject, MachineLearningService {
    
    private var model:String
    var result = MachineLearningServiceResult()
    let classificateGroup = DispatchGroup()
    
    public func theModel(tModel: String) {
        self.model = tModel
    }
    
    required init(with useModel: String) {
        self.model = useModel
    }
    
    func getMLModel(forModel model:String)-> VNCoreMLModel {
        do {
            switch model {
                case "objeto":
                    return try VNCoreMLModel(for: MobileNet().model)
                case "plantas":
                    return try VNCoreMLModel(for: watson_plants().model)
                case "herramientas":
                    return try VNCoreMLModel(for: watson_tools().model)
                case "lugares":
                    return try VNCoreMLModel(for: GoogLeNetPlaces().model)
                case "bogota":
                    return try VNCoreMLModel(for: SitiosBogota_1600241622().model)
                default:
                    return try VNCoreMLModel(for: MobileNet().model)
            }
        } catch {
            fatalError("Error al cargar el modelo de reconocimiento: \(error)")
        }
    }
    
    lazy var classificationRequest2: VNCoreMLRequest = {
       
        if self.model == "" {
            self.model = "objeto"
        }
        
        let model = self.getMLModel(forModel: self.model)
    
        let request = VNCoreMLRequest(model: self.getMLModel(forModel: self.model)) { [weak self] request, error in
    
            guard let classifications = request.results as? [VNClassificationObservation] else {
                    fatalError("unexpected result type from VNCoreMLRequest")
            }
            
            var machineLearningList = MachineLearningList()
            var machineLearnings = [MachineLearning]()
            var machineLearning1 = MachineLearning()
            var machineLearning2 = MachineLearning()
            
            machineLearning1.confidence = (classifications.first?.confidence)!
            machineLearning1.identifier = (classifications.first?.identifier)!
            machineLearning1.identificador = machineLearning1.identifier
            machineLearning1.model = (self?.model)!
            machineLearnings.append(machineLearning1)
            machineLearning2.confidence = classifications[1].confidence
            machineLearning2.identifier =  classifications[1].identifier
            machineLearning2.identificador = machineLearning2.identifier
            machineLearning2.model = (self?.model)!
            machineLearnings.append(machineLearning2)
            machineLearningList.machineLearningList = machineLearnings
            self?.result.machineLearningList = machineLearningList
            self?.classificateGroup.leave()
            
        }
        return request
    }()
    
    
    func Clasificate(data: MachineLearningServicePhotoSearchData, callback: ((MachineLearningServiceResult) -> Void)?) {
       
        classificateGroup.enter()
        
        
        DispatchQueue.global(qos: .userInitiated).sync {
            var handler:VNImageRequestHandler
            
            if (data.sampleBuffer != nil) {
                guard let pixelBuffer = CMSampleBufferGetImageBuffer(data.sampleBuffer!) else {
                    return
                }
                var requestOptions:[VNImageOption: Any] = [:]
                
                if let cameraIntrinsicData = CMGetAttachment(pixelBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
                    requestOptions = [.cameraIntrinsics: cameraIntrinsicData]
                }
    
                handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation.leftMirrored, options: requestOptions)
            } else {
                let image: UIImage = UIImage(data: data.searchPhoto!)!
                let orientation = CGImagePropertyOrientation(image.imageOrientation)
                guard let ciImage = CIImage(image: image) else {
                    result.error = .notLoadImage(message: "No pude crear una imagen \(CIImage.self) from \(image).")
                    callback?(result)
                    return
                }
                handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            }
            do {
                
                try handler.perform(
                
                    [self.classificationRequest2]
                )
            } catch {
                result.error = .notReconized(message: "Ups! error al clasificarla.\n\(error.localizedDescription)")
                callback?(result)
            }
        }
        result.success = true
        
        classificateGroup.notify(queue: DispatchQueue.main) { // 2
            callback?(self.result)
            
        }
    }
    
    // IBM Watson para la clasificacion de las imágenes (Simple)
 
}

