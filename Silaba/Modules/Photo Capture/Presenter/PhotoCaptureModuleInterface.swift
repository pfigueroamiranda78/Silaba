//
//  PhotoCaptureModuleInterface.swift
//  Photostream
//
//  Created by Mounir Ybanez on 10/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import GPUImage

protocol PhotoCaptureModuleInterface: class {

    var isCameraAvailable: Bool { get }
    
    func capture()
    func cancel()
    func setupCamera(with preview: GPUImageView, cameraPosition: AVCaptureDevice.Position, preset:  AVCaptureSession.Preset, outputOrientation: UIInterfaceOrientation)
    func startCamera()
    func stopCamera()
    func setReconigzedType(with recognized_type:String)
    func setSelectedTalent(with selectedTalent:Talent)
}

extension PhotoCaptureModuleInterface {
    
    func setupBackCamera(with preview: GPUImageView, preset: AVCaptureSession.Preset = AVCaptureSession.Preset.hd1280x720, outputOrientation: UIInterfaceOrientation = .portrait) {
        setupCamera(with: preview, cameraPosition: .back, preset: preset, outputOrientation: outputOrientation)
    }

    func setupFrontCamera(with preview: GPUImageView, preset: AVCaptureSession.Preset = AVCaptureSession.Preset.hd1280x720, outputOrientation: UIInterfaceOrientation = .portrait) {
        setupCamera(with: preview, cameraPosition: .front, preset: preset, outputOrientation: outputOrientation)
    }
}
