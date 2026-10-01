//
//  ClienteModel.swift
//  Semana06_02
//
//  Created by Tecsup on 1/10/26.
//

import UIKit

class ClienteModel: NSObject {
    var Codigo: Int32 = 0
    var Apellido: String = ""
    var Nombre: String = ""
    var Dni: String = ""
    
    // Inicializador sin parámetros
    override init() {
        self.Codigo = 0
        self.Apellido = ""
        self.Nombre = ""
        self.Dni = ""
    }
    
    // Inicializador con parámetros
    init(pCodigo: Int32, pApellido: String, pNombre: String, pDni: String) {
        self.Codigo = pCodigo
        self.Apellido = pApellido
        self.Nombre = pNombre
        self.Dni = pDni
    }
}
