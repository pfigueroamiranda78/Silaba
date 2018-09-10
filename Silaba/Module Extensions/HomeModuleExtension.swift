//
//  HomeModuleExtension.swift
//  Photostream
//
//  Created by Mounir Ybanez on 29/10/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import UIKit
import AVKit

extension HomePresenterInterface {
    
    func presentPostComposer() {
        guard let presenter = self as? HomePresenter else {
            return
        }
        
        wireframe.showPostComposer(from: view.controller, delegate: presenter)
    }
    
    func presentPostDiscovery() {
        guard let presenter = self as? HomePresenter else {
            return
        }
        
        wireframe.showPostDiscovery(from: view.controller, delegate: presenter)
    }
    
}

extension HomePresenter: PostComposerDelegate, PostDiscoveryDelegate {
    
    
    
    func postDiscoveryFinish(with image: UIImage, content: String, recognize_type: String, machineLearningList: MachineLearningList) {
        print("Post discovery did finish writing...")
    }
    
    func postDiscoveryDidCancel() {
        print("Post discovery did cancel writing...")
    }
    
    func postComposerDidFinish(with video: AVPlayerItem, content: String, recognize_type: String, machineLearningList: MachineLearningList, talent: Talent) {
        guard let presenter: NewsFeedPresenter = wireframe.dependency() else {
            return
        }
        
        wireframe.showPostUpload(in: presenter.view.controller, delegate: self, video: video, content: content, recognize_type: recognize_type, machineLearningList: machineLearningList, talent: talent)
    }
    
    func postComposerDidFinish(with image: UIImage, content: String, recognize_type: String, machineLearningList: MachineLearningList, talent: Talent) {
        guard let presenter: NewsFeedPresenter = wireframe.dependency() else {
            return
        }
        
        wireframe.showPostUpload(in: presenter.view.controller, delegate: self, image: image, content: content, recognize_type: recognize_type, machineLearningList: machineLearningList, talent: talent)
    }
    
    func postComposerDidCancel() {
        print("Post composer did cancel writing...")
    }
}

extension HomePresenter: PostUploadModuleDelegate {
    
    func postUploadDidFail(with message: String) {
        print("Home Presenter: post upload did fail ==>", message)
    }
    
    func postUploadDidRetry() {
        print("Home Presenter: post upload did retry")
    }
    
    func postUploadDidSucceed(with post: UploadedPost) {
        guard let presenter: NewsFeedPresenter = wireframe.dependency() else {
            return
        }
        
        presenter.feed.items.insert(post.covertToNewsFeedPost(), at: 0)
        presenter.view.reloadView()
    }
}

extension HomePresenter: VideoPostUploadModuleDelegate {
    
    func postUploadVideoDidFail(with message: String) {
        print("Home Presenter: post upload did fail ==>", message)
    }
    
    func postUploadVideoDidRetry() {
        print("Home Presenter: post upload did retry")
    }
    
    func postUploadVideoDidSucceed(with post: UploadedPost) {
        guard let presenter: NewsFeedPresenter = wireframe.dependency() else {
            return
        }
        
        presenter.feed.items.insert(post.covertToNewsFeedPost(), at: 0)
        presenter.view.reloadView()
    }
}

extension HomeWireframe {
    
    static var viewController: HomeViewController {
        let sb = UIStoryboard(name: "HomeModuleStoryboard", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "HomeViewController")
        return vc as! HomeViewController
    }
    
    func loadModuleDependency(with controller: UITabBarController) {
        // Load news feed module
        let feedVC = (controller.viewControllers?[0] as? UINavigationController)?.topViewController as! NewsFeedViewController
        let module = NewsFeedModule(view: feedVC)
        module.build(root: root as? RootWireframe)
        dependencies?.append(module.presenter)
        
        // Load user timeline supermodule
        let auth = AuthSession()
        let userTimeline = UserTimelineViewController()
        userTimeline.userId = auth.user.id
        userTimeline.root = root as? RootWireframe
        
        var nav = UINavigationController(rootViewController: userTimeline)
        nav.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "user_line_icon"), selectedImage: #imageLiteral(resourceName: "user_black_icon"))
        nav.tabBarItem.imageInsets.top = 8
        nav.tabBarItem.imageInsets.bottom = -8
        nav.navigationBar.isTranslucent = false
        nav.navigationBar.tintColor = UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1)
        controller.viewControllers?.append(nav)
        
        userTimeline.preloadView()
        
        // Load post discovery module
        /*let postDiscovery = PostDiscoveryModule()
        postDiscovery.build(root: root as? RootWireframe)
        
        nav = UINavigationController(rootViewController: postDiscovery.view.controller!)
        nav.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "discovery_line_icon"), selectedImage: #imageLiteral(resourceName: "discovery_black_icon"))
        nav.tabBarItem.imageInsets.top = 8
        nav.tabBarItem.imageInsets.bottom = -8
        nav.navigationBar.isTranslucent = false
        nav.navigationBar.tintColor = UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1)
        controller.viewControllers?.insert(nav, at: 1)
        
        postDiscovery.view.controller?.preloadView()*/
        
        // Load user activity module
        let userActivity = UserActivityModule()
        userActivity.build(root: root as? RootWireframe, userId: auth.user.id)
        
        nav = UINavigationController(rootViewController: userActivity.view.controller!)
        nav.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "heart_home_icon"), selectedImage: #imageLiteral(resourceName: "heart_home_icon_black"))
        nav.tabBarItem.imageInsets.top = 8
        nav.tabBarItem.imageInsets.bottom = -8
        nav.navigationBar.isTranslucent = false
        nav.navigationBar.tintColor = UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1)
        controller.viewControllers?.insert(nav, at: 3)
        
        userActivity.view.controller?.preloadView()
    }
}

extension HomeWireframeInterface {
    
    func showPostUpload(in controller: UIViewController?, delegate: PostUploadModuleDelegate?, image: UIImage, content: String, recognize_type: String, machineLearningList: MachineLearningList, talent: Talent) {
        guard controller != nil else {
            return
        }
        
        let vc = PostUploadViewController()
        let item = PostUploadItem(image: image, content: content, recognize_type: recognize_type, machineLearningList: machineLearningList, talent: talent)
        let wireframe = PostUploadWireframe(root: root, delegate: delegate, view: vc, item: item)
        wireframe.attach(with: vc, in: controller!)
    }
    
    func showPostUpload(in controller: UIViewController?, delegate: VideoPostUploadModuleDelegate?, video: AVPlayerItem, content: String, recognize_type: String, machineLearningList: MachineLearningList, talent: Talent) {
        guard controller != nil else {
            return
        }
        
        let vc = VideoPostUploadViewController()
        let item = VideoPostUploadItem(content: content, recognize_type: recognize_type, machineLearningList: machineLearningList, talent: talent, video: video)
        let wireframe = VideoPostUploadWireframe(root: root, delegate: delegate, view: vc, item: item)
        wireframe.attach(with: vc, in: controller!)
    }
    
    func showPostDiscovery(from controller: UIViewController?, delegate: PostDiscoveryDelegate?) {
        guard controller != nil else {
            return
        }
        
        let photoCaptureView = PhotoCaptureWireframe.createViewController()
        let photoLibraryView = PhotoLibraryWireframe.createViewController()
        let photoVideoCaptureView = VideoCaptureWireframe.createViewController()
        
        let photoPickerDiscoveryView = PhotoPickerDiscoveryWireframe.createViewController()
        
        let postDiscoveryModule = PostDiscoveryModule()
        postDiscoveryModule.build(root: root as? RootWireframe)
        postDiscoveryModule.view.controller?.preloadView()
        
        let postDiscoveryView = postDiscoveryModule.view
        
        let postDiscovery = PostDiscoveryNavigationController(photoPicker: photoPickerDiscoveryView, postDiscover: postDiscoveryView as! PostDiscoveryViewController)
    
     
        let photoPickerDiscoveryWireframe = PhotoPickerDiscoveryWireframe(root: root, delegate: postDiscovery, view: photoPickerDiscoveryView)
        let photoPickerDiscoveryPresenter = photoPickerDiscoveryView.presenter as! PhotoPickerDiscoveryPresenter
        
        let _ = PhotoCaptureWireframe(root: root, delegate: photoPickerDiscoveryPresenter, view: photoCaptureView)
        let _ = PhotoLibraryWireframe(root: root, delegate: photoPickerDiscoveryPresenter, view: photoLibraryView)
        let _ = VideoCaptureWireframe(root: root, delegate: photoPickerDiscoveryPresenter, view: photoVideoCaptureView)

        let photoLibraryPresenter = photoLibraryView.presenter as! PhotoPickerDiscoveryModuleDependency
        photoPickerDiscoveryWireframe.dependencies?.append(photoLibraryPresenter)
        photoPickerDiscoveryView.setupDependency(with: [photoLibraryView, photoCaptureView, photoVideoCaptureView])
        postDiscovery.moduleDelegate = delegate
        
        photoClassifer(at: controller!, composerPost: nil, discoverPost: postDiscovery, capturePresenter: photoCaptureView.presenter, libraryPresenter: photoLibraryView.presenter, videoCapturePresenter: photoVideoCaptureView.presenter)
        
    }
    
    func showPostComposer(from controller: UIViewController?, delegate: PostComposerDelegate?) {
        guard controller != nil else {
            return
        }
        
        // Create necessary views
        let photoShareView = PhotoShareWireframe.createViewController()
        let videoShareView = VideoShareWireframe.createViewController()
        let photoCaptureView = PhotoCaptureWireframe.createViewController()
        let videoCaptureView = VideoCaptureWireframe.createViewController()
        let photoLibraryView = PhotoLibraryWireframe.createViewController()
        let photoPickerView = PhotoPickerWireframe.createViewController()
        
        let postComposer = PostComposerNavigationController(photoPicker: photoPickerView, photoShare: photoShareView, videoShare: videoShareView)
       
        
        // Create necessary wireframes
        let photoPickerWireframe = PhotoPickerWireframe(root: root, delegate: postComposer, view: photoPickerView)
        let _ = PhotoShareWireframe(root: root, delegate: postComposer, view: photoShareView)
        let _ = VideoShareWireframe(root: root, delegate: postComposer, view: videoShareView)
        let photoPickerPresenter = photoPickerView.presenter as! PhotoPickerPresenter
        let _ = PhotoCaptureWireframe(root: root, delegate: photoPickerPresenter, view: photoCaptureView)
        let _ = PhotoLibraryWireframe(root: root, delegate: photoPickerPresenter, view: photoLibraryView)
        let _ = VideoCaptureWireframe(root: root, delegate: photoPickerPresenter, view: videoCaptureView)
        
        
        // Configure dependencies
        let photoLibraryPresenter = photoLibraryView.presenter as! PhotoPickerModuleDependency
        photoPickerWireframe.dependencies?.append(photoLibraryPresenter)
        photoPickerView.setupDependency(with: [photoLibraryView, photoCaptureView, videoCaptureView])
        postComposer.moduleDelegate = delegate
        photoClassifer(at: controller!, composerPost: postComposer, discoverPost: nil, capturePresenter: photoCaptureView.presenter, libraryPresenter: photoLibraryView.presenter, videoCapturePresenter: videoCaptureView.presenter)
    }
    
    
    func setRecognize_type(at controller: UIViewController, composerPost postComposer: PostComposerNavigationController?, discoverPost postDiscovery: PostDiscoveryNavigationController?, capturePresenter photoCapture: PhotoCaptureModuleInterface, libraryPresenter libraryCapture: PhotoLibraryModuleInterface, videoCapturePresenter videoCapture: VideoCaptureModuleInterface, recognize_type: String) {
       
        photoCapture.setReconigzedType(with: recognize_type)
        libraryCapture.setReconigzedType(with: recognize_type)
        videoCapture.setReconigzedType(with: recognize_type)
        
        if (postComposer != nil) {
            postComposer?.photoShare.recognizeType = recognize_type
            postComposer?.videoShare.recognizeType = recognize_type
            // Preset post composer
            controller.present(postComposer!, animated: true, completion: nil)
        }
        
        if (postDiscovery != nil) {
            postDiscovery?.postDiscovery.recognizeType = recognize_type
            
            // Preset post discovery
            controller.present(postDiscovery!, animated: true, completion: nil)
        }
        
    }
    
    func photoClassifer(at controller: UIViewController, composerPost postComposer: PostComposerNavigationController?, discoverPost postDiscovery: PostDiscoveryNavigationController?,  capturePresenter photoCapture: PhotoCaptureModuleInterface, libraryPresenter libraryCapture: PhotoLibraryModuleInterface, videoCapturePresenter videoCapture: VideoCaptureModuleInterface ) {
        let photoSourcePicker = UIAlertController()
        photoSourcePicker.title = "¿Qué deseas reconocer?"
        photoSourcePicker.message = "Sílaba intentará reconocer el contenido de la foto, acércala lo más posible."
    
        photoSourcePicker.addAction(UIAlertAction(title: "Planta",
                                                  style: UIAlertActionStyle.default,
                                                  handler: {(alert: UIAlertAction!) in self.setRecognize_type(at: controller, composerPost: postComposer, discoverPost: postDiscovery, capturePresenter: photoCapture, libraryPresenter: libraryCapture, videoCapturePresenter: videoCapture, recognize_type: "plantas" )}))
        photoSourcePicker.addAction(UIAlertAction(title: "Herramienta",
                                                  style: UIAlertActionStyle.default,
                                                  handler: {(alert: UIAlertAction!) in self.setRecognize_type(at: controller, composerPost: postComposer, discoverPost: postDiscovery, capturePresenter: photoCapture, libraryPresenter: libraryCapture, videoCapturePresenter: videoCapture, recognize_type: "herramientas")}))
        photoSourcePicker.addAction(UIAlertAction(title: "Lugar",
                                                  style: UIAlertActionStyle.default,
                                                  handler: {(alert: UIAlertAction!) in self.setRecognize_type(at: controller, composerPost: postComposer, discoverPost: postDiscovery, capturePresenter: photoCapture, libraryPresenter: libraryCapture, videoCapturePresenter: videoCapture, recognize_type: "lugares")}))
        photoSourcePicker.addAction(UIAlertAction(title: "Un objeto",
                                                  style: UIAlertActionStyle.default,
                                                  handler: {(alert: UIAlertAction!) in self.setRecognize_type(at: controller, composerPost: postComposer, discoverPost: postDiscovery, capturePresenter: photoCapture, libraryPresenter: libraryCapture, videoCapturePresenter: videoCapture, recognize_type: "objeto")}))
        photoSourcePicker.addAction(UIAlertAction(title: "Sitios de la ciudad",
                                                  style: UIAlertActionStyle.default,
                                                  handler: {(alert: UIAlertAction!) in self.setRecognize_type(at: controller, composerPost: postComposer, discoverPost: postDiscovery, capturePresenter: photoCapture, libraryPresenter: libraryCapture, videoCapturePresenter: videoCapture, recognize_type: "bogota")}))
        photoSourcePicker.addAction(UIAlertAction(title: "Cancelar",
                                                  style: UIAlertActionStyle.cancel,
                                                  handler: {(alert: UIAlertAction!) in photoSourcePicker.dismiss(animated: true, completion: {
                                                    
                                                  })}))
        controller.present(photoSourcePicker, animated: true)
      
    }
}
