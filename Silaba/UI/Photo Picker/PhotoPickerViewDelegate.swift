//
//  PhotoPickerViewDelegate.swift
//  Photostream
//
//  Created by Mounir Ybanez on 22/11/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import UIKit

extension PhotoPickerViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard previousViewControllers.count > 0, completed,
            let previousIndex = pages.index(of: previousViewControllers[0]),
            pages[previousIndex] != pageViewController.topViewController else {
                return
        }
        
        let currentIndex = previousIndex == 1 ? 2 : previousIndex == 2 ? 1 : 0
        switch currentIndex {
        case 0:
            presenter.willShowLibrary()
        case 1:
            presenter.willShowCamera()
        case 2:
            presenter.willShowVideoCamera()
        default:
            break
        }
    }
}
