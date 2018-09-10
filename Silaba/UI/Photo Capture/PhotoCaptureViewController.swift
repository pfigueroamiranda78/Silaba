//
//  PhotoCaptureViewController.swift
//  Photostream
//
//  Created by Mounir Ybanez on 10/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import UIKit
import GPUImage

class PhotoCaptureViewController: UIViewController {

    @IBOutlet weak var btnSwitchVision: UIBarButtonItem!
    @IBOutlet weak var btnSwitchWikipedia: UIBarButtonItem!
    @IBOutlet weak var preview: GPUImageView!
    @IBOutlet weak var controlContentView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var wikipediaText: UITextView!
    @IBOutlet weak var BannerText: UITextField!
    @IBOutlet weak var recog: UITextField!
    @IBOutlet weak var sampleImage: UIImageView!
    
    var presenter: PhotoCaptureModuleInterface!
    var selectedTalent: Talent!
    var swtchWikipedia: Bool = false
    var swtchVision: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        preview.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
        presenter.setupBackCamera(with: preview)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.startCamera()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func didTapCapture() {
        presenter.capture()
    }
    
    @IBAction func showWikipedia(_ sender: Any) {
        
        if (swtchWikipedia) {
            wikipediaText.isHidden = false
            swtchWikipedia = false
            btnSwitchWikipedia.title = "Wikipedia Off"
        } else {
            wikipediaText.isHidden = true
            swtchWikipedia = true
            btnSwitchWikipedia.title = "Wikipedia On"
        }
        
    }
    
 
    @IBAction func showVision(_ sender: Any) {
        if (swtchVision) {
            recog.isHidden = false
            swtchVision = false
            btnSwitchVision.title = "Visión Off"
        } else {
            recog.isHidden = true
            swtchVision = true
            btnSwitchVision.title = "Visión On"
        }
    }
    
}

extension PhotoCaptureViewController: PhotoCaptureViewInterface {
    func updateVisual(with text: String) {
        self.recog.text = text
        
    }
    
    func updateSampleImage(with sample: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sample) else {
            return
        }
        self.sampleImage.image = UIImage(pixelBuffer: pixelBuffer)
    }
    
    func updateWikipedia(with text:String) {
        self.wikipediaText.text = text
    }
    
    
    
    func updateBannerText(with text:String) {
    
        if ((text.count) > 1) {
            self.BannerText.text = text
            BannerText.isHidden = false
        } else {
            BannerText.isHidden = true
        }
    }
    
    var controller: UIViewController? {
        return self
    }
    
    func updateSelectedTalent(with selectedTalent:Talent) {
        self.selectedTalent = selectedTalent
    }
}
