//
//  TableViewController.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 27/03/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class ExperienceSimilarVC: UITableViewController {
    
    var retos = [Reto]()
    var currentUserImageUrl: String!
    var selectedReto : Reto!
    var selectedImage : UIImage!
    var currentUser : Usuario!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userId = KeychainWrapper.standard.string(forKey: "uid")
        let firebase = Autenticacion(withEstrategia: FirebaseAuthStrategy())
        firebase.getUser(withUserId: userId!) { (usuario) in
            self.currentUser = usuario
        }
        retos.removeAll()
        addListExperiences(ofTag: selectedReto.tag)
        currentUserImageUrl = KeychainWrapper.standard.string(forKey: "userImgUrl")
        
    }
    
    func addListExperiences(ofTag tag:String) {
      
        let firebasereto = Retando(withEstrategia: FirebaseRetoStrategy())
        firebasereto.getRetos(withTag: tag, withLimit: 100) { (success, retos) in
            self.retos = retos!
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Volver", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        retos.removeAll()
        selectedReto = nil
        currentUser = nil
        selectedReto = nil
        currentUserImageUrl = nil
        let i = self.navigationController?.viewControllers.index(of: self)
        if let LExperienceVC = self.navigationController?.viewControllers[i!-1] as? ExperienceVC  {
            LExperienceVC.needRefresh = false
        }
        _ = navigationController?.popViewController(animated: true)
        self.tableView.removeFromSuperview()
    }
    
    @objc func toPulications(_ sender: AnyObject) {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        let indexPath: IndexPath? = tableView.indexPathForRow(at: buttonPosition)
        var fila = indexPath?.row
        fila = fila! - 1
        selectedReto = retos[fila!]
        performSegue(withIdentifier: "toPublications", sender: nil)
    }
    
    @objc func toListVideos(_ sender: AnyObject) {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        let indexPath: IndexPath? = tableView.indexPathForRow(at: buttonPosition)
        var fila = indexPath?.row
        fila = fila! - 1
        selectedReto = retos[fila!]
        performSegue(withIdentifier: "toVideos", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toPublications"?:
            let destino = segue.destination as! FeedVC
            destino.reto = self.selectedReto
        case "showImg"?:
            let destino = segue.destination as! showImgExperience
            destino.image = selectedImage
        case "toVideos"?:
            let destino = segue.destination as! ListaVideosTVCT
            destino.selectionImage = selectedReto.tag
        default:
            return
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let cantRetos = retos.count
        return 1 + cantRetos
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SimilarExperiencesHeader", for: indexPath) as? SimilarExperiencesHeaderTableView {
                cell.configCell(withTag: selectedReto.tag, withImgUrl: currentUserImageUrl)
                return cell
            }
        }
       
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExperienceSimilarCell") as? ExperienceSimilarCell else {
            return UITableViewCell()
        }
        let fila = indexPath.row-1
        cell.configCell(reto: retos[fila])
        
        // Determina si ya sigue al usuario
        let strUsuario = retos[fila].userid

       
        for siguiendo in (self.currentUser?.getSiguiendo())! {
            if (strUsuario == siguiendo) {
                cell.commentBtn.isEnabled = true
                cell.btnSeguir.titleLabel?.text = "Siguiendo"
                cell.btnSeguir.isEnabled = false
            }
        }
 
        cell.commentBtn.addTarget(self, action: #selector(toPulications), for: .touchUpInside)
        cell.listVideos.addTarget(self, action: #selector(toListVideos), for: .touchUpInside)
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row > 0) {
            
            guard let cell = tableView.cellForRow(at: indexPath) as? ExperienceCell else {
                return
            }
            selectedImage = cell.imgView.image
            performSegue(withIdentifier: "showImg", sender: nil)
        }
    }
}


