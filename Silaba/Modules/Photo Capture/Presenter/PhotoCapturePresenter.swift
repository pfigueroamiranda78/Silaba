//
//  PhotoCapturePresenter.swift
//  Photostream
//
//  Created by Mounir Ybanez on 10/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import GPUImage
import Vision


class PhotoCapturePresenter: NSObject, PhotoCapturePresenterInterface  {

    // preview view - we'll add the previewLayer to this later
    @IBOutlet weak var previewView: UIView!

    weak var moduleDelegate: PhotoCaptureModuleDelegate?
    weak var view: PhotoCaptureViewInterface!
    var wireframe: PhotoCaptureWireframeInterface!
    var interactor: PhotoCaptureInteractorInput!
    var camera: GPUImageStillCamera?
    var filter: GPUImageFilter?
    // queue for processing video frames
    
    var recognized_type: String = "objeto"
    var isCapturing: Bool = true
    var machineLearningService: MachineLearningService?
    var selectedTalent: Talent?
   
}


extension PhotoCapturePresenter :  GPUImageVideoCameraDelegate {

    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        
        if (!self.isCapturing) {
            return
        }
        self.interactor.processMachineLearning(withImage: nil, withSampleBuffer: sampleBuffer, withType: self.recognized_type)
    }
}

extension PhotoCapturePresenter: PhotoCaptureModuleInterface {
    func setSelectedTalent(with selectedTalent: Talent) {
        self.selectedTalent = selectedTalent
    }
    
    func setReconigzedType(with recognized_type: String) {
        self.recognized_type = recognized_type
        self.machineLearningService = MachineLearningServicesProvider(with: recognized_type)
    }
    
    var isCameraAvailable: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    func capture() {
        guard isCameraAvailable else {
            return
        }
        
        camera?.capturePhotoAsImageProcessedUp(toFilter: filter, withCompletionHandler: { (image, error) in
            self.moduleDelegate?.photoCaptureDidFinish(with: image)
            self.isCapturing = false
        })
        
    }
    
    func cancel() {
        moduleDelegate?.photoCaptureDidCanel()
        self.isCapturing = false
    }
    
    func setupCamera(with preview: GPUImageView, cameraPosition: AVCaptureDevice.Position = .back, preset: AVCaptureSession.Preset = .hd1280x720, outputOrientation: UIInterfaceOrientation = .portrait) {
        guard isCameraAvailable else {
            return
        }
        
        camera = GPUImageStillCamera(sessionPreset: preset.rawValue, cameraPosition: cameraPosition)
        camera?.outputImageOrientation = outputOrientation
        
        filter = GPUImageCropFilter(cropRegion: squareCropRegion(for: preset))
        filter?.addTarget(preview)
        camera?.addTarget(filter)
        camera?.delegate = self
    }
    
    func startCamera() {
        guard isCameraAvailable  else {
            return
        }
        
        camera?.startCapture()
    }
    
    func stopCamera() {
        guard isCameraAvailable else {
            return
        }
        
        camera?.stopCapture()
    }
}

extension PhotoCapturePresenter {
    
    func squareCropRegion(for preset: AVCaptureSession.Preset) -> CGRect {
        switch preset {
        case .vga640x480:
            return squareCropRegion(for: CGSize(width: 640, height: 480))
        case .cif352x288:
            return squareCropRegion(for: CGSize(width: 352, height: 288))
        case .hd1280x720:
            return squareCropRegion(for: CGSize(width: 1280, height: 720))
        case .hd1920x1080:
            return squareCropRegion(for: CGSize(width: 1920, height: 1080))
        case .hd4K3840x2160:
            return squareCropRegion(for: CGSize(width: 3480, height: 2160))
        default:
            return CGRect(x: 0, y: 0, width: 1, height: 1)
        }
    }
    
    func squareCropRegion(for size: CGSize) -> CGRect {
        var region = CGRect(x: 0, y: 0, width: 1, height: 1)
        region.origin.y = (size.width - size.height) / size.width / 2
        region.size.height = size.height / size.width
        return region
    }
}

extension PhotoCapturePresenter: PhotoCaptureInteractorOutput {
    
    func photoCaptureDidProcessMachineLearning(with mlresult: MachineLearningList?, with sample: CMSampleBuffer?) {
        guard mlresult?.count != 0 else {
            view.updateVisual(with: "")
            return
        }
        let recognized = mlresult?.mejorIdenficador
        let confidence = mlresult?.bestConfidence
        self.interactor.fetchPlaceInfo(id: recognized!)
        self.interactor.fetchWikipedia(with: recognized!, with: confidence!, withSampleBuffer: sample!)
        self.moduleDelegate?.photoAsSampleBuffer(with: (mlresult!))

    }

    func photoCaptureDidReconigzed(with reconigzed: String, with confidence: Float, withSampleBuffer sampleBuffer: CMSampleBuffer) {
        let recognized_text: String = self.recognized_type+": "+reconigzed+" en un \(confidence.round(digit: 2)  )%"
        self.view.updateVisual(with: recognized_text)
     //   self.view.updateSampleImage(with: sampleBuffer)
    }
    
    func photoCaptureDidFetchWikipedia(with reconigzed: String, with confidence: Float, with sample: CMSampleBuffer?, with searchResults: WikipediaSearchResults?, with error: WikipediaError?) {
        var wikiresult: String = "wikipedia: "
        
        guard error == nil else {
            self.view.updateWikipedia(with: "No tienes conexión a internet o el sitio de Wikipedia no se encuentra disponible")
            photoCaptureDidReconigzed(with: reconigzed, with: confidence, withSampleBuffer:  sample!)
            return
        }
        
        for articlePreview in (searchResults?.results)! {
            print(articlePreview.displayTitle)
            wikiresult.append(articlePreview.displayTitle)
            wikiresult.append(": ")
            wikiresult.append(articlePreview.displayText)
        }
        photoCaptureDidReconigzed(with: reconigzed, with: confidence, withSampleBuffer: sample!)
        self.view.updateWikipedia(with: wikiresult)
    }
    
    func photoCaptureDidFetchPlace(with result: PlaceServiceResult) {
        guard result.error == nil else {
            view.updateBannerText(with: "")
            return
        }
        view.updateBannerText(with: (result.place?.banner)!)
    }
}
