//
//  VideoCaptureViewController.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 11/06/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit
import GPUImage

class VideoCaptureViewController: UIViewController {
    
    @IBOutlet weak var btnSwitchWikipedia: UIBarButtonItem!
    @IBOutlet weak var btnSwitchVideo: UIBarButtonItem!
    @IBOutlet weak var preview: GPUImageView!
    @IBOutlet weak var controlContentView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var wikipediaText: UITextView!
    @IBOutlet weak var BannerText: UITextField!
    @IBOutlet weak var recog: UITextField!
    @IBOutlet weak var sampleImage: UIImageView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnPause: UIButton!
    @IBOutlet weak var lblDuration: UILabel!

    var timerRecord = Timer()
    var timerPlayer = Timer()
    var player = AVPlayer()
    var playerLayer = AVPlayerLayer()
    var presenter: VideoCaptureModuleInterface!
    var selectedTalent: Talent!
    var swtchWikipedia: Bool = false
    var swtchVision: Bool = false
    var videoDuration: Float64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preview.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
        presenter.setupBackCamera(with: preview)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(normalTap))
        tapGesture.numberOfTapsRequired = 1
        preview.addGestureRecognizer(tapGesture)
        
        let longGesture = UILongPressGestureRecognizer(target: self, action:#selector(didTapCapture))
        captureButton.addGestureRecognizer(longGesture)
        
        playerLayer.player = self.player
        playerLayer.frame = self.preview.bounds
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.startCamera()
        self.btnPlay.isHidden = true
        self.btnPause.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func didTapCapture(_ sender: UIGestureRecognizer) {
       
        if sender.state == .ended {
        
            presenter.stopCapture()
            captureButton.setImage(nil, for: UIControlState.normal)
            self.timerRecord.invalidate()
            btnPlay.isHidden = false
            btnPause.isHidden = true
           
        }
        else if sender.state == .began {
            
            presenter.startCapture()
            if let image = UIImage(named: "VideoCam.png") {
                captureButton.setImage(image, for: UIControlState.normal)
            }
            self.videoDuration = 0
            recordTimer()
        }

    }
    
    @objc func normalTap(_ sender: UIGestureRecognizer) {
         didTapView()
    }
    
    @IBAction func showVision(_ sender: Any) {
        if (swtchVision) {
            recog.isHidden = false
            swtchVision = false
            btnSwitchVideo.title = "Visión Off"
        } else {
            recog.isHidden = true
            swtchVision = true
            btnSwitchVideo.title = "Visión On"
        }
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
    
    func didTapView() {
        
        if (self.player.isPlaying) {
           
            self.timerPlayer.invalidate()
            self.btnPause.isHidden = true
            self.btnPlay.isHidden = false
            self.player.pause()
        } else {
            preview.layer.addSublayer(playerLayer)
    
            self.btnPause.isHidden = false
            self.btnPlay.isHidden = true
            self.player.play()
            self.playingTimer()
        }
    }
}

extension VideoCaptureViewController: VideoCaptureViewInterface {
    func didRecordedVideo(theUrl url: NSURL) {
        DispatchQueue.main.async {
            let item = AVPlayerItem(url: url as URL)
            self.player.replaceCurrentItem(with: item)
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { _ in
                self.btnPlay.isHidden = false
                self.btnPause.isHidden = true
                self.player.seek(to: kCMTimeZero)
                self.timerPlayer.invalidate()
                self.preview.layer.sublayers?.last?.removeFromSuperlayer()
                self.showDurationVideo(for: self.player.currentItem!)
            }
        }
    }
    
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
        self.BannerText.text = text
    }
    
    var controller: UIViewController? {
        return self
    }
    
    func updateSelectedTalent(with selectedTalent:Talent) {
        self.selectedTalent = selectedTalent
    }
    
    func recordTimer() {
        timerRecord = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateRecordDuration)), userInfo: nil, repeats: true)
    }
    
    func playingTimer() {
        timerPlayer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updatePlayerDuration)), userInfo: nil, repeats: true)
    }
    
    @objc func updateRecordDuration() {
        self.videoDuration = self.videoDuration + 1
        let minutes = self.videoDuration / 60
        let diffMinutes = Float(minutes) - Float(Int(minutes))
        let remainSeconds = 60 * diffMinutes
        self.lblDuration.text = String(Int(minutes)) + ":" +  String(Int(remainSeconds))
       
    }
    
    @objc func updatePlayerDuration() {
        let minutes = self.videoDuration / 60
        let diffMinutes = Float(minutes) - Float(Int(minutes))
        let remainSeconds = 60 * diffMinutes
        self.lblDuration.text = String(Int(minutes)) + ":" +  String(Int(remainSeconds))
        self.videoDuration = self.videoDuration - 1
    }
    
    func showDurationVideo(for playerItem:AVPlayerItem) {
        let duration : CMTime = playerItem .asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        self.videoDuration = seconds
        updatePlayerDuration()
    }
}
