//
//  PhotoPickerViewController.swift
//  Photostream
//
//  Created by Mounir Ybanez on 09/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import UIKit

class PhotoPickerViewController: UIViewController {
    
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var videoCameraButton: UIButton!
    lazy var pages = [UIViewController]()
    
    var presenter: PhotoPickerModuleInterface!
    var pageViewController: UIPageViewController? {
        guard !childViewControllers.isEmpty else {
            return nil
        }
        
        let vc = childViewControllers[0] as? UIPageViewController
        return vc
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

    
    @IBAction func didTapVideoCamera(_ sender: Any) {
        presenter.willShowVideoCamera()
    }
    
    @IBAction func didTapCancel(_ sender: AnyObject) {
        presenter.cancel()
        presenter.dismiss()
    }
    
    @IBAction func didTapNext(_ sender: AnyObject) {
        presenter.didPickPhotoFromLibrary()
    }
    
    @IBAction func didTapLibrary() {
        presenter.willShowLibrary()
    }
    
    @IBAction func didTapCamera() {
        presenter.willShowCamera()
    }
}

extension PhotoPickerViewController: PhotoPickerViewInterface {
    
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
        videoCameraButton.isSelected = false
        title = "Tus fotos"
        
        let rightBarItem = UIBarButtonItem(title: "Siguiente", style: .plain, target: self, action: #selector(self.didTapNext(_:)))
        navigationItem.rightBarButtonItem = rightBarItem
                    
        pageViewController?.setViewControllers([pages[0]], direction: .reverse, animated: true, completion: nil)
    }
    
    func showCamera() {
        libraryButton.isSelected = false
        cameraButton.isSelected = true
        videoCameraButton.isSelected = false
        title = "Toma una foto"
        
        navigationItem.rightBarButtonItem = nil
        
        pageViewController?.setViewControllers([pages[1]], direction: .forward, animated: true, completion: nil)
    }
    
    func showVideoCamera() {
        libraryButton.isSelected = false
        cameraButton.isSelected = false
        videoCameraButton.isSelected = true
        title = "Haz un video"
        
        let rightBarItem = UIBarButtonItem(title: "Siguiente", style: .plain, target: self, action: #selector(self.didTapNext(_:)))
        navigationItem.rightBarButtonItem = rightBarItem
        
        
        pageViewController?.setViewControllers([pages[2]], direction: .forward, animated: true, completion: nil)
    }
}
