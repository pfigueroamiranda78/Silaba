//
//  PostViC.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 4/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import CoreML
import Vision
import ImageIO

class ExperienceViC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource  {

    
    var placeholderLabel : UILabel!
    var imagePicker: UIImagePickerController!
    var lm_model: Any!
    var resultVideos = NSMutableArray()
    var firstDetected : String!
    
    @IBOutlet weak var PostText: UITextView!
    @IBOutlet weak var ImgView: UIImageView!
    @IBOutlet weak var classificationLabel: UILabel!
    @IBOutlet weak var btnCompartirDown: UIButton!
    @IBOutlet weak var btnCompatirTop: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        PostText.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Escribe aquí la experiencia que deseas proponerle a tus seguidores"
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (PostText.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        PostText.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (PostText.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !PostText.text.isEmpty
        self.tableView.delegate = self
        self.tableView.dataSource = self
        isReadyForSave()
        // Do any additional setup after loading the view.
    }
    
    func isReadyForSave() {
        
        if (ImgView.image != nil && !PostText.text.isEmpty)  {
            btnCompatirTop.isEnabled = true
            btnCompartirDown.isEnabled = true
        } else {
            btnCompatirTop.isEnabled = false
            btnCompartirDown.isEnabled = false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        isReadyForSave()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Publicar(_ sender: Any) {
        save()
    }
    
    func save() {
        btnCompatirTop.isEnabled = false
        btnCompartirDown.isEnabled = false
       
        let userID = KeychainWrapper.standard.string(forKey: "uid")
        let firebasereto = Retando(withEstrategia: FirebaseRetoStrategy())
        //Subo la imagen la nube
        let imageData = UIImageToDataJPEG2(image: ImgView.image!, compressionRatio: 0.1)
        let firebaseStorage = SilabaStoring(withEstrategia: FirebaseStorageStrategy())
        self.firstDetected = "running shoes"
        firebaseStorage.Upload(theData: imageData!, theTag: self.firstDetected) { (success, url) in
            if (success) {
                 print("experiencia creado")
                firebasereto.addReto(withUserId: userID!, withLat: 0 , withLon: 0, withDescription: self.PostText.text, withAddres: "Direccion estándar", withImageUrl: url!, withTag: self.firstDetected ) { (success, post) in
                    if (success) {
                        let i = self.navigationController?.viewControllers.index(of: self)
                        if let LExperienceVC = self.navigationController?.viewControllers[i!-1] as? ExperienceVC  {
                            LExperienceVC.needRefresh = true
                        }
                        super.navigationController?.popViewController(animated: true)
                        print("experiencia creado")
                    } else {
                        print("experiencia no creado")
                        self.btnCompatirTop.isEnabled = true
                        self.btnCompartirDown.isEnabled = true
                    }
                }
            } else {
                if (url == "NoConnectionError") {
                    let alertController = UIAlertController(title: "Sin conexión", message: "En este momento no tienes conexión a internet, tus datos serán registrados automáticamente cuando estes conectado", preferredStyle: .alert)
                    self.present(alertController, animated: true, completion: nil)
                    let actionOK = UIAlertAction(title: "Aceptar", style: .default) { (action:UIAlertAction) in
                        super.navigationController?.popViewController(animated: true)
                    }
                    alertController.addAction(actionOK)
                }
            }
        }
        
    }
    
    @IBAction func compartir(_ sender: Any) {
        save()
    }
    
    func doPhoto() {
        
        // Show options for the source picker only if the camera is available.
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Tomar una foto", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Escoger una foto", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(photoSourcePicker, animated: true)
    }
    
    
    // Este método evalua planta
    @IBAction func seleccionImagen(_ sender: Any) {
       
        // Initialize Vision Core ML model from base Watson Visual Recognition model

        do{
            self.lm_model = try VNCoreMLModel(for: watson_plants().model)
        }catch {
            fatalError("Error al cargar el modelo de reconocimiento: \(error)")
        }
        doPhoto()
    }
    // Este método evalua herramienta
    @IBAction func findTool(_ sender: Any) {
        
        // Initialize Vision Core ML model from base Watson Visual Recognition model

        do{
            self.lm_model = try VNCoreMLModel(for: watson_tools().model)
        }catch {
            fatalError("Error al cargar el modelo de reconocimiento: \(error)")
        }
        doPhoto()
    }
    
    // Este método evalua algo
    @IBAction func findThing(_ sender: Any) {
        
        // Initialize Vision Core ML model from base Watson Visual Recognition model

        do{
            self.lm_model = try VNCoreMLModel(for: MobileNet().model)
        }catch {
            fatalError("Error al cargar el modelo de reconocimiento: \(error)")
        }
        doPhoto()
    }
    
    @IBAction func findPlace(_ sender: Any) {
        // Initialize Vision Core ML model from Places205-GoogLeNet
        
        do{
            self.lm_model = try VNCoreMLModel(for: GoogLeNetPlaces().model)
        }catch {
            fatalError("Error al cargar el modelo de reconocimiento: \(error)")
        }
        doPhoto()
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerControllerSourceType) {
        self.imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    // IBM Watson para la clasificacion de las imágenes (Simple)
    
    lazy var classificationRequest: VNCoreMLRequest = {
                
        // Create visual recognition request using Core ML model
        let request = VNCoreMLRequest(model: self.lm_model as! VNCoreMLModel) { [weak self] request, error in
            self?.processClassifications(for: request, error: error)
        }
        request.imageCropAndScaleOption = .scaleFit
        return request
        
    }()
    
    func updateClassifications(for image: UIImage) {
        classificationLabel.text = "Reconociendo..."
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else { fatalError("No pude crear una imagen \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                print("Ups! error al clasificarla.\n\(error.localizedDescription)")
            }
        }
    }
    
    /// Updates the UI with the results of the classification.
    func processClassifications(for request: VNRequest, error: Error?) {
       
        DispatchQueue.main.async {
            
            guard let results = request.results else {
                self.classificationLabel.text = "Imposible de clasificar.\n\(error!.localizedDescription)"
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
            let downloadGroup = DispatchGroup()
            
            if classifications.isEmpty {
                self.classificationLabel.text = "No se reconoce"
            } else {
                var processed:Bool = false
                // Display top classification ranked by confidence in the UI.
                let topClassifications = classifications.prefix(2)
                if (!processed) {
                    //Busca los videos de youtube
                    self.resultVideos.removeAllObjects()
                    
                    let str = (classifications[0].identifier as String).split(separator: ",")
                    self.firstDetected = str.first?.lowercased()
                    downloadGroup.enter()
                    YouTubeServicesProvider().getVideoWithTextSearch(searchText:  self.firstDetected!, nextPageToken: "") { (videosArray, succses, nextpageToken) in
                        if(succses == true){
                            self.resultVideos.addObjects(from: videosArray)
                            processed = true
                        }
                        downloadGroup.leave()
                    }
                    
                }
                let descriptions = topClassifications.map {
                   
                    classification -> String in
                    // Formateando la cadena de salida para la clasificacion
                    return String(format: " (%.2f) %@", classification.confidence, classification.identifier)
                }
                self.classificationLabel.text = "Clasificado como: " + descriptions.joined(separator: "\n")
               
            }
            
            downloadGroup.notify(queue: DispatchQueue.main) { // 2
                self.tableView.reloadData()
            }
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)
        
        // We always expect `imagePickerController(:didFinishPickingMediaWithInfo:)` to supply the original image.
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.ImgView.image = image
        updateClassifications(for: image)
        isReadyForSave()
        self.tableView.reloadData()
    }
    
    func UIImageToDataJPEG2(image: UIImage, compressionRatio: CGFloat) -> Data? {
        return autoreleasepool(invoking: { () -> Data? in
            return UIImageJPEGRepresentation(image, compressionRatio)
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultVideos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "youTubeVideoList", for: indexPath) as! youTubeTableViewCell
       
        let videoDetails = resultVideos[indexPath.row] as! Dictionary<String, AnyObject>
        let name:String = videoDetails["videoTitle"] as! String
        let subTitle:String = videoDetails["videoSubTitle"] as! String
        let videoThumb:String = videoDetails["imageUrl"] as! String
        let videoId:String = videoDetails["videoId"] as! String
        cell.configCell(withVideoName: name, withSubTitle: subTitle, withVideoThumb: videoThumb, withVideoUrl: videoId )
        
        return cell
    }
}

extension CGImagePropertyOrientation {
    /**
     Converts a `UIImageOrientation` to a corresponding
     `CGImagePropertyOrientation`. The cases for each
     orientation are represented by different raw values.
     
     - Tag: ConvertOrientation
     */
    init(_ orientation: UIImageOrientation) {
        switch orientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}

extension UIImage {
    
    /// Returns a image that fills in newSize
    func resizedImage(newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width,height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// Returns a resized image that fits in rectSize, keeping it's aspect ratio
    /// Note that the new image size is not rectSize, but within it.
    func resizedImageWithinRect(rectSize: CGSize) -> UIImage {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height
        
        var resizeFactor = widthFactor
        if size.height > size.width {
            resizeFactor = heightFactor
        }
        
        let newSize = CGSize(width: size.width/resizeFactor, height: size.height/resizeFactor)
        let resized = resizedImage(newSize: newSize)
        return resized
    }
    
}

