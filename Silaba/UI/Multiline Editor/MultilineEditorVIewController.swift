//
//  MultilineEditorViewController.swift
//  Photostream
//
//  Created by Mounir Ybanez on 16/01/2017.
//  Copyright © 2017 Mounir Ybanez. All rights reserved.
//

import UIKit

@objc protocol MultilineEditorViewControllerAction: class {
    
    func didTapCancel()
    func didTapSave()
}

class MultilineEditorViewController: UIViewController, MultilineEditorViewControllerAction {

    var multilineEditorView: MultilineEditorView!
    var presenter: MultilineEditorModuleInterface!
    
    override func loadView() {
        let bounds = UIScreen.main.bounds
        multilineEditorView = MultilineEditorView(frame: bounds)
        multilineEditorView.textView.becomeFirstResponder()
        view = multilineEditorView
        
        setupNavigationItem()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewDidLoad()
    }
    
    func setupNavigationItem() {
        navigationItem.title = "Editar"
        
        var barItem = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(self.didTapCancel))
        navigationItem.leftBarButtonItem = barItem
        
        barItem = UIBarButtonItem(title: "Finalizar", style: .plain, target: self, action: #selector(self.didTapSave))
        navigationItem.rightBarButtonItem = barItem
    }
    
    func didTapCancel() {
        presenter.cancel()
    }
    
    func didTapSave() {
        let text = multilineEditorView.textView.text ?? ""
        presenter.save(text: text)
    }
}

extension MultilineEditorViewController: MultilineEditorScene {
    
    var controller: UIViewController? {
        return self
    }
    
    func setupDefaultText(text: String) {
        multilineEditorView.textView.text = text
    }
}
