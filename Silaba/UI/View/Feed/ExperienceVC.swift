//
//  TableViewController.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 27/03/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class ExperienceVC: UITableViewController {
    
    // Datos para el tableView y las formas que conocen el reto seleccionado para realizar sus operaciones
    // Tiene todos los retos que son cargados desde la base de datos
    var retos = [Reto]()
    
    // Tiene los datos del reto que se selecciona en el tableView para las acciones posibles.
    var selectedReto : Reto!
    // La imagen que se selecciona en una fila de la tabla para ser mostrada.
    var selectedImage : UIImage!
    // Informacion del usuario
    var userImgUrl: String!
    var userId: String!
    
    // Datos para la paginacion
    var needRefresh: Bool! = true // Esta determina si los datos necesitan ser refrescados o no. Debe actualizarse desde otras formas para que aqui se produzca la re-carga de los datos.
    
    // Este método trae los datos desde firebase completos y es invocado de manera inicial y cuando alguna de las formas que conocen los retos que se cargaron realizan alguna moficacion y obliga a refrescar el conjunto de datos, tales como adicionar una nueva experiencia.
    func addListExperiences(ofUserId userId:String, completion:(Bool) -> ()) {
        let firebasereto = Retando(withEstrategia: FirebaseRetoStrategy())
         firebasereto.getRetos(withUserId: userId, withFollowers: true) { (success, reto) in
            self.retos = reto!
            self.tableView.reloadData()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
    
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Volver", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        retos.removeAll()
        selectedReto = nil
        selectedImage = nil
       
        _ = navigationController?.popViewController(animated: true)
        self.tableView.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.dataSource = self
        tableView.delegate = self
        self.selectedReto = nil
        // Inicia todas las variables de trabajo para mostrar
        userId = KeychainWrapper.standard.string(forKey: "uid")
        userImgUrl = KeychainWrapper.standard.string(forKey: "userImgUrl")
        
        // Sí necesita refrescarse. Es necesario que al inicio se dé para cargar la primera página en el tableView
        if (self.needRefresh) {

            retos.removeAll()
            tableView.reloadData()
            
            // Carga los datos desde la base de datos.
            addListExperiences(ofUserId: userId!) { (success) in
                self.needRefresh = false
                self.tableView.reloadData()
            }
        }
    }
    
     // Llama la forma que permite crear una nueva experiencia
    @objc func toCreateReto(_ sender: AnyObject) {
        performSegue(withIdentifier: "toCreateExperience", sender: self)
    }
    
     // Llama la forma que muestra las publicaciones de la experiencia
    @objc func toPulications(_ sender: AnyObject) {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        let indexPath: IndexPath? = tableView.indexPathForRow(at: buttonPosition)
        var fila = indexPath?.row
        fila = fila! - 1
        selectedReto = retos[fila!]
        performSegue(withIdentifier: "toPublications", sender: nil)
    }
     // Llama la forma que muestra los videos realizados con la clasificacion del interés de la experencia
    @objc func toListVideos(_ sender: AnyObject) {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        let indexPath: IndexPath? = tableView.indexPathForRow(at: buttonPosition)
        var fila = indexPath?.row
        fila = fila! - 1
        selectedReto = retos[fila!]
        performSegue(withIdentifier: "toVideos", sender: nil)
    }
    
    // Llama la forma que muestra las experiencias similares
    @objc func toSimilarExperiences(_ sender: AnyObject) {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        let indexPath: IndexPath? = tableView.indexPathForRow(at: buttonPosition)
        var fila = indexPath?.row
        fila = fila! - 1
        selectedReto = retos[fila!]
        performSegue(withIdentifier: "toSimilarExperiences", sender: nil)
    }
    
    
    // Este metodo es ejecutado antes de cargar las formas que se encargan de las acciones sobre las experiencias, con el propósito de enviarle los datos que requieren para trabajar. Lo mismo el reto seleccionado como un dato puntual del reto.
    
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
        case "toSimilarExperiences"?:
            let destino = segue.destination as! ExperienceSimilarVC
             destino.selectedReto = selectedReto
        default:
            return
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
       }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cantRetos = self.retos.count
        //let cantRetos = self.selectedRetosToUI.count
        return 1 + cantRetos
    }
    
    // Este metodo es el encargado de producir cada celda de la tabla, tener en cuenta que siempre la celda cero es para el encabezado, las restantes son para los datos de las experiencias.
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // El encabezado
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SharePublication", for: indexPath) as? SharePublicationTableViewCell {
                cell.configCell(userUrl: userImgUrl)
                return cell
            }
        }
        // Las experiencias
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExperienceCell") as? ExperienceCell else {
            return UITableViewCell()
        }
        
        // Determina la fila de la tabla (se resta uno por el encabezado)
        let fila = indexPath.row-1

        // Configura los datos de la celda (de la experiencia)
        cell.configCell(reto: retos[fila])
        // Configura las acciones que son realizadas cuando selecciona, lo mismo publicaciones y ver experiencias similares como ver la  lista de videos de la experiencia.
        cell.commentBtn.addTarget(self, action: #selector(toPulications), for: .touchUpInside)
        cell.listVideos.addTarget(self, action: #selector(toListVideos), for: .touchUpInside)
        cell.listExperiencesSimilars.addTarget(self, action: #selector(toSimilarExperiences), for: .touchUpInside)
        return cell
        
    }

    // Este método determina la imagen que se va a mostrar y llama al forma 'showImg' para que sea mostrado.
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
