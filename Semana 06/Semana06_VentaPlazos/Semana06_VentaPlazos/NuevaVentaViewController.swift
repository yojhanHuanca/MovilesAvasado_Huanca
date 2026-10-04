import UIKit

class NuevaVentaViewController: UIViewController {
    @IBOutlet weak var tfElectrodomestico: UITextField!
    @IBOutlet weak var tfPrecioUnitario: UITextField!
    @IBOutlet weak var tfCantidad: UITextField!
    @IBOutlet weak var tfMeses: UITextField!
    @IBOutlet weak var tfTasaInteresMensual: UITextField!

    var venta: VentaModel = VentaModel()

    // El botón tiene el segue Show. Se valida y calcula antes de navegar.
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showResultado" {
            return calcularVenta()
        }
        return super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
    }

    func calcularVenta() -> Bool {
        let nombre = (tfElectrodomestico.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let textoPrecio = (tfPrecioUnitario.text ?? "").replacingOccurrences(of: ",", with: ".")
        let textoTasa = (tfTasaInteresMensual.text ?? "").replacingOccurrences(of: ",", with: ".")

        if nombre.isEmpty {
            mostrarError("Ingresa el nombre del electrodoméstico.")
            return false
        }

        if let precioUnitario = Double(textoPrecio),
           let cantidad = Int(tfCantidad.text ?? ""),
           let meses = Int(tfMeses.text ?? ""),
           let tasaInteresMensual = Double(textoTasa) {
            if !precioUnitario.isFinite || !tasaInteresMensual.isFinite ||
               precioUnitario <= 0 || cantidad <= 0 || meses <= 0 || tasaInteresMensual < 0 {
                mostrarError("Precio, cantidad y meses deben ser mayores que cero. La tasa debe ser cero o positiva.")
                return false
            }

            let resultado = VentaModel()
            // Interés simple mensual según las fórmulas del laboratorio.
            resultado.subtotal = precioUnitario * Double(cantidad)
            resultado.igv = resultado.subtotal * 0.18
            resultado.base = resultado.subtotal + resultado.igv
            resultado.intereses = resultado.base * (tasaInteresMensual / 100) * Double(meses)
            resultado.total = resultado.base + resultado.intereses
            resultado.cuota = resultado.total / Double(meses)

            if !resultado.total.isFinite || !resultado.cuota.isFinite {
                mostrarError("Los valores ingresados son demasiado grandes.")
                return false
            }
            venta = resultado
            view.endEditing(true)
            return true
        }

        mostrarError("Ingresa números válidos. Cantidad y meses deben ser enteros; no uses separadores de miles.")
        return false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResultado" {
            if let destino = segue.destination as? ResultadoViewController {
                destino.venta = venta
            }
        }
    }

    func mostrarError(_ mensaje: String) {
        let alerta = UIAlertController(title: "Revisa los datos", message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(alerta, animated: true)
    }
}
