//
//  VideoCapturePresenter.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 11/06/18.
//  Copyright © 2018 Silaba. All rights reserved.

//

import Foundation
import GPUImage
import Vision


class VideoCapturePresenter: NSObject, VideoCapturePresenterInterface  {
    
    // preview view - we'll add the previewLayer to this later
    @IBOutlet weak var previewView: UIView!
    var backgroundMovie: GPUImageMovie!
    
    weak var moduleDelegate: VideoCaptureModuleDelegate?
    weak var view: VideoCaptureViewInterface!
    var wireframe: VideoCaptureWireframeInterface!
    var interactor: VideoCaptureInteractorInput!
    var videoCamera: GPUImageVideoCamera?
    var filter: GPUImageFilter?
    var movieWriter: GPUImageMovieWriter!
    var exportUrl: NSURL!
    
    // queue for processing video frames
    
    var recognized_type: String = "objeto"
    var isCapturing: Bool = true
    var machineLearningService: MachineLearningService?
    var selectedTalent: Talent?
    
}


extension VideoCapturePresenter :  GPUImageVideoCameraDelegate {
    
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        
        if (!self.isCapturing) {
            return
        }
        self.interactor.processMachineLearning(withImage: nil, withSampleBuffer: sampleBuffer, withType: self.recognized_type)
    }
}

extension VideoCapturePresenter: VideoCaptureModuleInterface {
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
    
    func stopCapture() {
        guard isCameraAvailable else {
            return
        }
       
        movieWriter.finishRecording {
            
            self.filter?.removeTarget(self.movieWriter)
            self.isCapturing = false
            self.videoCamera?.pauseCapture()
            self.view.didRecordedVideo(theUrl: self.exportUrl)
            DispatchQueue.main.async {
                self.moduleDelegate?.videoDidCapture(with: self.exportUrl!)
            }
    
            
            //self.moduleDelegate?.videoCaptureDidFinish(with: self.exportUrl)
        }
    }
    
    func startCapture() {
        guard isCameraAvailable else {
            return
        }
        
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(atPath: exportUrl.relativePath! as String)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        self.movieWriter = GPUImageMovieWriter.init(movieURL: self.exportUrl as URL?, size: CGSize(width: 1280, height: 720))
        self.movieWriter.shouldPassthroughAudio = true
        self.movieWriter.setHasAudioTrack(true, audioSettings: nil)
        self.videoCamera?.audioEncodingTarget = self.movieWriter
        self.movieWriter?.startRecording()
        
        if (!self.isCapturing) {
            videoCamera?.resumeCameraCapture()
        }

        self.isCapturing = true
        self.filter?.addTarget(self.movieWriter)
        backgroundMovie.addTarget(filter)
        backgroundMovie.startProcessing()
    }
    
    
    func cancel() {
        videoCamera?.stopCapture()
        moduleDelegate?.videoCaptureDidCancel()
        self.isCapturing = false
    }
    
    func setupCamera(with preview: UIView, cameraPosition: AVCaptureDevice.Position = .back, preset: AVCaptureSession.Preset = .hd1280x720, outputOrientation: UIInterfaceOrientation = .portrait) {
        guard isCameraAvailable else {
            return
        }
        
        videoCamera = GPUImageVideoCamera.init(sessionPreset: AVCaptureSession.Preset.hd1280x720.rawValue, cameraPosition: .back)
        videoCamera?.outputImageOrientation = .portrait
        
        let documentsPath: NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as NSString
        let importPath: NSString = documentsPath.appending("/xlargevideo.m4v") as NSString
        let importUrl: NSURL = NSURL.fileURL(withPath: importPath as String) as NSURL
        
        backgroundMovie = GPUImageMovie.init(url: importUrl as URL)
        backgroundMovie.shouldRepeat = true
        
        let exportPath: NSString = documentsPath.appending("/xlargevideofiltered.m4v") as NSString
        exportUrl  = NSURL.fileURL(withPath: exportPath as String) as NSURL
       
        videoCamera?.delegate = self
    }
    
    func setupCamera(with preview: GPUImageView, cameraPosition: AVCaptureDevice.Position = .back, preset: AVCaptureSession.Preset = .hd1280x720, outputOrientation: UIInterfaceOrientation = .portrait) {
        guard isCameraAvailable else {
            return
        }
        
        videoCamera = GPUImageVideoCamera.init(sessionPreset: AVCaptureSession.Preset.hd1280x720.rawValue, cameraPosition: .back)
        videoCamera?.outputImageOrientation = .portrait
       
        let documentsPath: NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as NSString
        let importPath: NSString = documentsPath.appending("/xlargevideo.m4v") as NSString
        let importUrl: NSURL = NSURL.fileURL(withPath: importPath as String) as NSURL
       
        backgroundMovie = GPUImageMovie.init(url: importUrl as URL)
        backgroundMovie.shouldRepeat = true
    
        let exportPath: NSString = documentsPath.appending("/xlargevideofiltered.m4v") as NSString
        exportUrl  = NSURL.fileURL(withPath: exportPath as String) as NSURL
        filter = GPUImageCropFilter(cropRegion: squareCropRegion(for: preset))
        
        videoCamera?.addTarget(filter)
        videoCamera?.delegate = self
        filter?.addTarget(preview)
        
    }
    
    func startCamera() {
        guard isCameraAvailable  else {
            return
        }
        
        videoCamera?.startCapture()
    }
    
    func stopCamera() {
        guard isCameraAvailable else {
            return
        }
       
        self.isCapturing = false
        videoCamera?.stopCapture()
    }
}

extension VideoCapturePresenter {
    
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

extension VideoCapturePresenter: VideoCaptureInteractorOutput {
    
    func videoCaptureDidProcessMachineLearning(with mlresult: MachineLearningList?, with sample: CMSampleBuffer?) {
        guard mlresult?.count != 0 else {
            view.updateVisual(with: "")
            return
        }
        let recognized = mlresult?.mejorIdenficador
        let confidence = mlresult?.bestConfidence
        self.interactor.fetchPlaceInfo(id: recognized!)
        self.interactor.fetchWikipedia(with: recognized!, with: confidence!, withSampleBuffer: sample!)
        self.moduleDelegate?.videoAsSampleBuffer(with: (mlresult!))
        
    }
    
    func videoCaptureDidReconigzed(with reconigzed: String, with confidence: Float, withSampleBuffer sampleBuffer: CMSampleBuffer) {
        let recognized_text: String = self.recognized_type+": "+reconigzed+" en un \(confidence.round(digit: 2)  )%"
        self.view.updateVisual(with: recognized_text)
        //   self.view.updateSampleImage(with: sampleBuffer)
    }
    
    func videoCaptureDidFetchWikipedia(with reconigzed: String, with confidence: Float, with sample: CMSampleBuffer?, with searchResults: WikipediaSearchResults?, with error: WikipediaError?) {
        var wikiresult: String = "wikipedia: "
        
        guard error == nil else {
            self.view.updateWikipedia(with: "No tienes conexión a internet o el sitio de Wikipedia no se encuentra disponible")
            videoCaptureDidReconigzed(with: reconigzed, with: confidence, withSampleBuffer:  sample!)
            return
        }
        
        for articlePreview in (searchResults?.results)! {
            print(articlePreview.displayTitle)
            wikiresult.append(articlePreview.displayTitle)
            wikiresult.append(": ")
            wikiresult.append(articlePreview.displayText)
        }
        videoCaptureDidReconigzed(with: reconigzed, with: confidence, withSampleBuffer: sample!)
        self.view.updateWikipedia(with: wikiresult)
    }
    
    func videoCaptureDidFetchPlace(with result: PlaceServiceResult) {
        guard result.error == nil else {
            view.updateBannerText(with: "")
            return
        }
        view.updateBannerText(with: (result.place?.banner)!)
    }
}


