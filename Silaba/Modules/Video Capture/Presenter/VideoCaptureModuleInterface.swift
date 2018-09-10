//
//  VideoCaptureModuleInterface.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 11/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import GPUImage

protocol VideoCaptureModuleInterface: class {
    
    var isCameraAvailable: Bool { get }
    
    func startCapture()
    func stopCapture()
    func cancel()
    func setupCamera(with preview: GPUImageView, cameraPosition: AVCaptureDevice.Position, preset:  AVCaptureSession.Preset, outputOrientation: UIInterfaceOrientation)
    func setupCamera(with preview: UIView, cameraPosition: AVCaptureDevice.Position, preset:  AVCaptureSession.Preset, outputOrientation: UIInterfaceOrientation)
    func startCamera()
    func stopCamera()
    func setReconigzedType(with recognized_type:String)
    func setSelectedTalent(with selectedTalent:Talent)
}

extension VideoCaptureModuleInterface {
    
    func setupBackCamera(with preview: UIView, preset: AVCaptureSession.Preset = AVCaptureSession.Preset.hd1280x720, outputOrientation: UIInterfaceOrientation = .portrait) {
        setupCamera(with: preview, cameraPosition: .back, preset: preset, outputOrientation: outputOrientation)
    }
    
    func setupBackCamera(with preview: GPUImageView, preset: AVCaptureSession.Preset = AVCaptureSession.Preset.hd1280x720, outputOrientation: UIInterfaceOrientation = .portrait) {
        setupCamera(with: preview, cameraPosition: .back, preset: preset, outputOrientation: outputOrientation)
    }
    
    func setupFrontCamera(with preview: GPUImageView, preset: AVCaptureSession.Preset = AVCaptureSession.Preset.hd1280x720, outputOrientation: UIInterfaceOrientation = .portrait) {
        setupCamera(with: preview, cameraPosition: .front, preset: preset, outputOrientation: outputOrientation)
    }
}
