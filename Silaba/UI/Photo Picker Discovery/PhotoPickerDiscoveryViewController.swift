//
//  PhotoPickerDiscoveryViewController.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 20/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit

class PhotoPickerDiscoveryViewController: UIViewController {

    
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var talent: UIPickerView!
    var talents: [Talent]!
    var selectedTalent: Talent!
    var talentList: TalentList? {
        didSet {
            self.talents = talentList?.talents
            self.selectedTalent = self.talents[0]
            self.nextControlller.talentId = self.selectedTalent.id
            if talent != nil {
                talent.reloadAllComponents()
            }
        }
    }
    
    lazy var pages = [UIViewController]()
    
    var presenter: PhotoPickerDiscoveryModuleInterface!
    var nextControlller: PostDiscoveryViewController!
    var pageViewController: UIPageViewController? {
        guard !childViewControllers.isEmpty else {
            return nil
        }
        
        let vc = childViewControllers[0] as? UIPageViewController
        return vc
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

        self.talent.delegate = self
        self.talent.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController?.dataSource = self
        pageViewController?.delegate = self
        
        presenter.willShowLibrary()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func didTapCancel(_ sender: AnyObject) {
        presenter.cancel()
        presenter.dismiss()
    }
    
    @IBAction func didTapNext(_ sender: AnyObject) {
        presenter.didPickPhotoFromLibrary(withTalent: self.selectedTalent)
    }
    
    @IBAction func didTapLibrary() {
        presenter.willShowLibrary()
    }
    
    @IBAction func didTapCamera() {
        presenter.willShowCamera()
    }

}


extension PhotoPickerDiscoveryViewController: PhotoPickerDiscoveryViewInterface {
    
    var controller: UIViewController? {
        return self
    }
    
    func setupDependency(with controllers: [UIViewController]) {
        pages.removeAll()
        pages.append(contentsOf: controllers)
    }
    
    func showLibrary() {
        libraryButton.isSelected = true
        cameraButton.isSelected = false
        title = "Tus fotos"
        
        let rightBarItem = UIBarButtonItem(title: "Buscar", style: .plain, target: self, action: #selector(self.didTapNext(_:)))
        navigationItem.rightBarButtonItem = rightBarItem
        
        pageViewController?.setViewControllers([pages[0]], direction: .reverse, animated: true, completion: nil)
    }
    
    func showCamera() {
        libraryButton.isSelected = false
        cameraButton.isSelected = true
        title = "Toma una foto"
        
        navigationItem.rightBarButtonItem = nil
        
        pageViewController?.setViewControllers([pages[1]], direction: .forward, animated: true, completion: nil)
    }
}



