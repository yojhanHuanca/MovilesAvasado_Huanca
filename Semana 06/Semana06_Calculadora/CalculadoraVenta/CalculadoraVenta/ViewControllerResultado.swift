//
//  ViewControllerResultado.swift
//  CalculadoraVenta
//
//  Created by Tecsup on 12/10/26.
//
import UIKit

class ViewControllerResultado: UIViewController {

    // Variable para recibir el modelo
    var oVenta: VentaModel?

    // Outlets de los 6 Labels
    @IBOutlet weak var lblSubtotal: UILabel!
    @IBOutlet weak var lblIgv: UILabel!
    @IBOutlet weak var lblBase: UILabel!
    @IBOutlet weak var lblIntereses: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblCuotaMensual: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let v = oVenta {
            lblSubtotal.text = String(format: "S/. %.2f", v.subtotal)
            lblIgv.text = String(format: "S/. %.2f", v.igv)
            lblBase.text = String(format: "S/. %.2f", v.base)
            lblIntereses.text = String(format: "S/. %.2f", v.intereses)
            lblTotal.text = String(format: "S/. %.2f", v.total)
            lblCuotaMensual.text = String(format: "S/. %.2f", v.cuota)
        }
    }
}
