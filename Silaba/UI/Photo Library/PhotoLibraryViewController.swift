//
//  PhotoLibraryViewController.swift
//  Photostream
//
//  Created by Mounir Ybanez on 11/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import UIKit
import Photos
import AVKit

enum PhotoLibraryViewControllerStyle {
    
    case style1, style2
}

@objc protocol PhotoLibraryViewControllerAction: class {
    
    func didTapDimView()
    func didTapView()
    func didFinishPlayVideo()
}

class PhotoLibraryViewController: UIViewController, PhotoLibraryViewControllerAction {
    
    
    @IBOutlet weak var BtnReconocimiento: UIBarButtonItem!
    @IBOutlet weak var BtnSwitchVideos: UIBarButtonItem!
    @IBOutlet weak var btnswitchWikipeda: UIBarButtonItem!
    @IBOutlet weak var BtnPlay: UIButton!
    @IBOutlet weak var BtnPause: UIButton!
    @IBOutlet weak var contentModeToggleButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var cropView: CropView!
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var cropContentViewConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var recognizedText: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var wikipediatext: UITextView!
    @IBOutlet weak var bannerText: UITextField!
    
    lazy var scrollHandler = ScrollHandler()
    var presenter: PhotoLibraryModuleInterface!
    var style: PhotoLibraryViewControllerStyle = .style1
    var player = AVPlayer()
    var selectedAsset: PHAsset!
    var selectedItemPlayer: AVPlayerItem?
    var playerLayer = AVPlayerLayer()
    var timer = Timer()
    var selectedIndex: Int = -1
    var videoDuration: Float64 = 0
    var swtchWikipedia: Bool = false
    var swtchReconocimiento: Bool = false
    var swtchVideos: Bool = false
    
    override func loadView() {
        super.loadView()
        
        if (!swtchVideos) {
            BtnPlay.isHidden = true
            BtnPause.isHidden = true
            contentModeToggleButton.isHidden = true
        }
        
        presenter.set(photoCropper: cropView)
        scrollHandler.scrollView = collectionView
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapDimView))
        dimView.addGestureRecognizer(tap)
        
        let tapView = UITapGestureRecognizer(target: self, action: #selector(self.didTapView))
        cropView.addGestureRecognizer(tapView)
        
        
        switch style {
        
        case .style2:
            cropView.cornerRadius = view.frame.width / 2
            contentModeToggleButton.isHidden = true
            
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard selectedIndex < 0 else {
            return
        }
        
        collectionView.contentInset.top = view.width + 2
        collectionView.scrollIndicatorInsets.top = view.width + 2
        flowLayout.configure(with: view.width, columnCount: 4, columnSpacing: 0.5, rowSpacing: 2)
        bannerText.isHidden = true
        playerLayer.player = self.player
        playerLayer.frame = self.cropView.bounds
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        

        presenter.fetchPhotos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addObserver(self, forKeyPath: "cropContentViewConstraintTop.constant", options: .new, context: nil)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { _ in
            self.BtnPlay.isHidden = false
            self.BtnPause.isHidden = true
            self.player.seek(to: kCMTimeZero)
            self.timer.invalidate()
            self.showDurationVideo(for: self.player.currentItem!)
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeObserver(self, forKeyPath: "cropContentViewConstraintTop.constant")
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let newValue = change?[.newKey] as? CGFloat else {
            return
        }
        
        dimView.isHidden = newValue == 0
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func didTapDone(_ sender: AnyObject) {
        self.player.pause()
        presenter.done()
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
        presenter.dismiss()
   
    }
    
    @IBAction func didTapCancel(_ sender: AnyObject) {
        self.player.pause()
        presenter.cancel()
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
        presenter.dismiss()
    }
    
    @IBAction func toggleContentMode() {
        presenter.toggleContentMode(animated: true)
    }
    
    func didTapDimView() {
        scrollHandler.killScroll()
        UIView.animate(withDuration: 0.25) { 
            self.cropContentViewConstraintTop.constant = 0
            self.dimView.alpha = 0
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }

    
    @IBAction func showWikipedia(_ sender: Any) {
        
        if (swtchWikipedia) {
            wikipediatext.isHidden = false
            swtchWikipedia = false
            btnswitchWikipeda.title = "Wikipedia Off"
        } else {
            wikipediatext.isHidden = true
            swtchWikipedia = true
            btnswitchWikipeda.title = "Wikipedia On"
        }
    
    }
    
    @IBAction func showRecongnize(_ sender: Any) {
    
        if (swtchReconocimiento) {
            recognizedText.isHidden = false
            swtchReconocimiento = false
            BtnReconocimiento.title = "Visión Off"
        } else {
            recognizedText.isHidden = true
            swtchReconocimiento = true
            BtnReconocimiento.title = "Visión On"
        }
    }
    
    
    @IBAction func showVideos(_ sender: Any) {
        if (swtchVideos) {
            BtnSwitchVideos.title = "Ver videos"
            swtchVideos = false
            BtnPlay.isHidden = true
            BtnPause.isHidden = true
            contentModeToggleButton.isHidden = false
            self.cropView.layer.sublayers?.last?.removeFromSuperlayer()
            presenter.fetchPhotos()
        } else {
            BtnSwitchVideos.title = "Ver fotos"
            swtchVideos = true
            BtnPlay.isHidden = false
            BtnPause.isHidden = true
            contentModeToggleButton.isHidden = true
            
            self.cropView.layer.addSublayer(playerLayer)
            presenter.fetchVideos()
        }
        
    }
    @IBAction func didTapPlay(_ sender: Any) {
        didTapView()
    }
    
    func didFinishPlayVideo() {

    }
    
    func didTapView() {
        if !swtchVideos {
            return
        }
        if (self.player.isPlaying) {
             self.player.pause()
             self.timer.invalidate()
             self.BtnPause.isHidden = true
             self.BtnPlay.isHidden = false
        } else {
            
            self.player.play()
            self.runTimer()
            self.BtnPause.isHidden = false
            self.BtnPlay.isHidden = true
        }

    }
}

extension PhotoLibraryViewController: PhotoLibraryViewInterface {
  
    func showBannerText(with text:String?) {
        if ((text?.count)! > 1) {
        self.bannerText.text = text
             bannerText.isHidden = false
        } else {
             bannerText.isHidden = true
        }
    }
    func showrecognizedText(with recognizedText: String?) {
         self.recognizedText.text = recognizedText
    }
    
    func showwikipediaText(with text: String?) {
        self.wikipediatext.text = text
    }
    
    var controller: UIViewController? {
        return self
    }
    
    func reloadView() {
        collectionView.reloadData()
    }
    
    func didFetchPhotos() {
        reloadView()
        
        if presenter.photoCount > 0 {
            let indexPath = IndexPath(row: 0, section: 0)
            collectionView(collectionView, didSelectItemAt: indexPath)
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
        }
    }
    
    func showSelectedPhoto(with image: UIImage?) {
        
        if swtchVideos {
            style = .style2
        }
        
        switch style {
            
        case .style1:
            cropView.setCropTarget(with: image, content: .fit)
            presenter.fillSelectedPhoto(animated: false)
            
        case .style2:
            cropView.setCropTarget(with: image, content: .fill)
        }
        
        cropView.setNeedsLayout()
        cropView.layoutIfNeeded()
    }
    
    func showSelectedPhotoInFitMode(animated: Bool) {
        cropView.zoomToFit(animated)
    }
    
    func showSelectedPhotoInFillMode(animated: Bool) {
        cropView.zoomToFill(animated)
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateDuration)), userInfo: nil, repeats: true)
    }
    
    @objc func updateDuration() {
        let minutes = self.videoDuration / 60
        let diffMinutes = Float(minutes) - Float(Int(minutes))
        let remainSeconds = 60 * diffMinutes
        self.lblDuration.text = String(Int(minutes)) + ":" +  String(Int(remainSeconds))
        self.videoDuration = self.videoDuration - 1
    }
    
    func showDurationVideo(for playerItem:AVPlayerItem) {
        let duration : CMTime = playerItem.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        self.videoDuration = seconds
        updateDuration()
    }
    func getSelectedAsset()->PHAsset {
        return self.selectedAsset
    }
    
    func getSelectedItemPlayer()->AVPlayerItem? {
        return self.selectedItemPlayer
    }

    
    func setSelectedAsset(with asset: PHAsset) {
        self.selectedAsset = asset
        if !swtchVideos {
            return
        }
        presenter.fetchVideo(with: asset) { (playerItem) in
            DispatchQueue.main.async {
                self.player.replaceCurrentItem(with: playerItem)
                self.showDurationVideo(for: playerItem!)
            }
        }
    }
    
    func setSelectedAsset(with playerItem: AVPlayerItem) {
        DispatchQueue.main.async {
            self.selectedItemPlayer = playerItem
            let newPlayeItem = playerItem.copy() as! AVPlayerItem
            self.player.replaceCurrentItem(with: newPlayeItem)
            self.showDurationVideo(for: playerItem)
        }
        
    }
}
