//
//  PhotoShareViewController.swift
//  Photostream
//
//  Created by Mounir Ybanez on 18/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import UIKit
import AVKit

class VideoShareViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var talentPicker: UIPickerView!
    @IBOutlet weak var userRecognized: UITextField!
    @IBOutlet weak var BtnPlay: UIButton!
    @IBOutlet weak var BtnPause: UIButton!
    @IBOutlet weak var lblDuration: UILabel!
    
    var viewOuter : HashTagTableViewCell!
    var arrValuesHashTag = ["Hi", "Hello", "Honest", "Ok", "Now", "today", "yesterday", "currently", "sunday", "monday", "tuesday", "wednesday", "thrusaday", "Friday", "saturday"]
    var arrValuesHMention = ["Hi", "Hello", "Honest", "Ok", "Now", "today", "yesterday", "currently", "sunday", "monday", "tuesday", "wednesday", "thrusaday", "Friday", "saturday"]
    
    var arrSearchedHashTag = [String]()
    var arrSearchedMention = [String]()
    var actualTag = ""
    var presenter: VideoShareModuleInterface!
    var recognizeType: String!
    var machineLearningList: MachineLearningList!
    var talents: [Talent]!
    var selectedTalent: Talent!
   
    var video: AVPlayerItem!
    var talentList: TalentList? {
        didSet {
            self.talents = talentList?.talents
            self.selectedTalent = self.talents[0]
            if talentPicker != nil {
                talentPicker.reloadAllComponents()
            }
        }
    }
    
    var thingList: ThingList? {
        didSet {
            self.arrValuesHashTag.removeAll()
            for thing in (thingList?.things)! {
                self.arrValuesHashTag.append(thing.id)
            }
        }
    }
    
    var userList: [User]? {
        didSet {
            self.arrValuesHMention.removeAll()
            for user in userList! {
                self.arrValuesHMention.append(user.username)
            }
        }
    }
    
    var player : AVPlayer!
    var playerLayer = AVPlayerLayer()
    var timer = Timer()
    var videoDuration: Float64 = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if video.asset.isPlayable {
            player = AVPlayer(playerItem: video)
        }
      
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { _ in
            self.BtnPlay.isHidden = false
            self.BtnPause.isHidden = true
            self.player.seek(to: kCMTimeZero)
            self.timer.invalidate()
            self.showDurationVideo()
        }
        
        let tapView = UITapGestureRecognizer(target: self, action: #selector(self.didTapView))
        imageView.addGestureRecognizer(tapView)
        playerLayer.player = self.player
        playerLayer.frame = self.imageView.bounds
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        imageView.layer.addSublayer(playerLayer)
        //player.replaceCurrentItem(with: video)
        BtnPause.isHidden = true
        showDurationVideo()
        
        contentTextView.placeholder="Escribe aquí sobre "+machineLearningList.mejorIdenficador
        self.talentPicker.delegate = self
        self.talentPicker.dataSource = self
        viewOuter = HashTagTableViewCell.fromNib()
        viewOuter.isHidden = true
        viewOuter.tableView.delegate = self
        viewOuter.tableView.dataSource = self
        viewOuter.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        contentTextView.inputAccessoryView = viewOuter
        contentTextView.delegate = self

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func didTapCancel(_ sender: AnyObject) {
        presenter.cancel()
        presenter.pop()
        self.player.pause()
    }
    
    @IBAction func didTapDone(_ sender: AnyObject) {
        guard let message = contentTextView.text, !message.isEmpty else {
            return
        }
        let text = userRecognized.text
        if ((text?.count)! > 0) {
            let model = machineLearningList.machineLearningList[0].model
            machineLearningList.machineLearningList.removeAll()
            var ml = MachineLearning()
            ml.confidence = 1
            ml.identificador = userRecognized.text!
            ml.identifier = userRecognized.text!
            ml.model = model
            var ml2 = MachineLearning()
            ml2.confidence = 1
            ml2.identificador = userRecognized.text!
            ml2.identifier = userRecognized.text!
            ml2.model = model
            machineLearningList.machineLearningList.append(ml)
            machineLearningList.machineLearningList.append(ml2)
        }
        self.player.pause()
        presenter.finish(with: video, content:message)
        presenter.dismiss()
    }
    
    @objc func didTapView() {
      
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

extension VideoShareViewController: VideoShareViewInterface {
    
    var controller: UIViewController? {
        return self
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
    
    func showDurationVideo() {
        let duration : CMTime = video.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        self.videoDuration = seconds
        updateDuration()
    }
}


extension VideoShareViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.talents == nil {
            return 0
        }
        return self.talents.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.talents[row].id
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedTalent = self.talents[row]
    }
}

extension VideoShareViewController: UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.actualTag == "#" ) {
            return arrSearchedHashTag.count
        } else if (self.actualTag == "@") {
            return arrSearchedMention.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        if (self.actualTag == "#") {
            cell.textLabel?.text = self.actualTag + arrSearchedHashTag[indexPath.row]
        } else if(self.actualTag == "@") {
            cell.textLabel?.text = self.actualTag + arrSearchedMention[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        viewOuter.isHidden = true
        let textViewTmp = contentTextView.text
        
        var strNewText = textViewTmp?.components(separatedBy: self.actualTag)
        if (strNewText?.count)! > 1 {
            if (self.actualTag == "#") {
                strNewText![(strNewText?.count)! - 1] = arrSearchedHashTag[indexPath.row]
            } else if(self.actualTag == "@") {
                strNewText![(strNewText?.count)! - 1] = arrSearchedMention[indexPath.row]
            }
        }
        let strFinalText = strNewText?.joined(separator: self.actualTag)
        contentTextView.text = strFinalText! + (" ")
        self.actualTag = ""
    }
    
    //MARK: UITextView Delegate
    func textViewDidChangeSelection(_ textView: UITextView) {
        let str = textView.text
        if let placeholderLabel = textView.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = textView.text.count > 0
        }
        
        if str != "" {
            let endIndex = str?.endIndex
            let lastChar = str![(str?.index(before: endIndex!))!]
            if lastChar == "#" {
                viewOuter.isHidden = false
                self.actualTag = "#"
            } else if lastChar == "@" {
                viewOuter.isHidden = false
                self.actualTag = "@"
            }
        }
        else {
            viewOuter.isHidden = true
        }
        let textviewtext = contentTextView.text
        
        let new = textviewtext?.components(separatedBy: self.actualTag)
        if (self.actualTag == "#") {
            arrSearchedHashTag = arrValuesHashTag.filter({$0.lowercased().contains(s: (new?.last!.replaceFirstOccurrence(of: self.actualTag, to: "").lowercased())!)})
        }
        else if (self.actualTag == "@") {
            arrSearchedMention = arrValuesHMention.filter({$0.lowercased().contains(s: (new?.last!.replaceFirstOccurrence(of: self.actualTag, to: "").lowercased())!)})
        }
        viewOuter.tableView.reloadData()
    }
}

