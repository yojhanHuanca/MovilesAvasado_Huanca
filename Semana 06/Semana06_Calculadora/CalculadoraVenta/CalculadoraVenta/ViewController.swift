//
//  ViewController.swift
//  CalculadoraVenta
//
//  Created by Tecsup on 12/10/26.
//

import UIKit

class ViewController: UIViewController {

    // Outlets de los 5 campos de entrada
    @IBOutlet weak var txtElectrodomestico: UITextField!
    @IBOutlet weak var txtPrecioUnitario: UITextField!
    @IBOutlet weak var txtCantidad: UITextField!
    @IBOutlet weak var txtMeses: UITextField!
    @IBOutlet weak var txtInteresMensual: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Navegación Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Validar Identifier indicado en la guía
        if segue.identifier == "showResultado" {
            
            // Obtener valores de la interfaz
            let precio = Double(txtPrecioUnitario.text ?? "") ?? 0.0
            let cantidad = Double(txtCantidad.text ?? "") ?? 0.0
            let meses = Double(txtMeses.text ?? "") ?? 1.0 // Evitar división entre 0
            let tasaInteresMensual = Double(txtInteresMensual.text ?? "") ?? 0.0

            // Fórmulas exactas de la guía
            let subtotalCalc = precio * cantidad
            let igvCalc = subtotalCalc * 0.18
            let baseCalc = subtotalCalc + igvCalc
            let interesesCalc = baseCalc * (tasaInteresMensual / 100.0) * meses
            let totalCalc = baseCalc + interesesCalc
            let cuotaCalc = totalCalc / meses

            // Instanciar el VentaModel
            let oVenta = VentaModel(
                subtotal: subtotalCalc,
                igv: igvCalc,
                base: baseCalc,
                intereses: interesesCalc,
                total: totalCalc,
                cuota: cuotaCalc
            )

            // Pasar el objeto a la pantalla de Resultado
            if let pantallaResultado = segue.destination as? ViewControllerResultado {
                pantallaResultado.oVenta = oVenta
            }
        }
    }
}
