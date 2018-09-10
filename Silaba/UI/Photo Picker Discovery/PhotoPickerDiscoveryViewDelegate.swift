//
//  PhotoPickerDiscoveryViewDelegate.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 20/05/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation
import UIKit

extension PhotoPickerDiscoveryViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard previousViewControllers.count > 0, completed,
            let previousIndex = pages.index(of: previousViewControllers[0]),
            pages[previousIndex] != pageViewController.topViewController else {
                return
        }
        
        let currentIndex = previousIndex == 0 ? 1 : 0
        switch currentIndex {
        case 0:
            presenter.willShowLibrary()
        case 1:
            presenter.willShowCamera()
        default:
            break
        }
    }
}
