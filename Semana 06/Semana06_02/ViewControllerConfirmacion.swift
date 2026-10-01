//
//  ViewControllerConfirmacion.swift
//  Semana06_02
//
//  Created by Tecsup on 1/10/26.
//


import UIKit

class ViewControllerConfirmacion: UIViewController {

    // Instanciar la clase ClienteModel
    var pCliente: ClienteModel = ClienteModel()
    
    
    @IBOutlet weak var tfApellido: UILabel!
    
    @IBOutlet weak var tfNombre: UILabel!
    
    @IBOutlet weak var tfDni: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Asignar datos de la clase a los labels
        self.tfApellido.text = pCliente.Apellido
        self.tfNombre.text = pCliente.Nombre
        self.tfDni.text = pCliente.Dni
    }
}
