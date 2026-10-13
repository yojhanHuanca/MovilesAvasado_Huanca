//
//  File.swift
//  CalculadoraVenta
//
//  Created by Tecsup on 12/10/26.
//

import UIKit

class VentaModel: NSObject {
    var subtotal: Double = 0.0
    var igv: Double = 0.0
    var base: Double = 0.0
    var intereses: Double = 0.0
    var total: Double = 0.0
    var cuota: Double = 0.0

    override init() {
        super.init()
    }

    init(subtotal: Double, igv: Double, base: Double, intereses: Double, total: Double, cuota: Double) {
        self.subtotal = subtotal
        self.igv = igv
        self.base = base
        self.intereses = intereses
        self.total = total
        self.cuota = cuota
    }
}
