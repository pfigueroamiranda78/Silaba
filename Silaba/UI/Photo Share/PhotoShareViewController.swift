//
//  PhotoShareViewController.swift
//  Photostream
//
//  Created by Mounir Ybanez on 18/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import UIKit
import AVKit

class PhotoShareViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var talentPicker: UIPickerView!
    @IBOutlet weak var userRecognized: UITextField!
   
    var viewOuter : HashTagTableViewCell!
    var arrValuesHashTag = ["Hi", "Hello", "Honest", "Ok", "Now", "today", "yesterday", "currently", "sunday", "monday", "tuesday", "wednesday", "thrusaday", "Friday", "saturday"]
    var arrValuesHMention = ["Hi", "Hello", "Honest", "Ok", "Now", "today", "yesterday", "currently", "sunday", "monday", "tuesday", "wednesday", "thrusaday", "Friday", "saturday"]
    
    var arrSearchedHashTag = [String]()
    var arrSearchedMention = [String]()
    var actualTag = ""
    var presenter: PhotoShareModuleInterface!
    var image: UIImage!
    var recognizeType: String!
    var machineLearningList: MachineLearningList!
    var talents: [Talent]!
    var selectedTalent: Talent!
   
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageView.image = image
        contentTextView.placeholder="Escribe tu publicación aquí sobre "+machineLearningList.mejorIdenficador
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func didTapCancel(_ sender: AnyObject) {
        presenter.cancel()
        presenter.pop()
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
        presenter.finish(with: image, content:message)
        presenter.dismiss()
    }
}

extension PhotoShareViewController: PhotoShareViewInterface {
    
    var controller: UIViewController? {
        return self
    }
}


extension PhotoShareViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
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

extension PhotoShareViewController: UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
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

