import Foundation

// Modelo de las seis salidas que se envían a la pantalla Resultado.
class VentaModel: NSObject {
    var subtotal: Double = 0.0
    var igv: Double = 0.0
    var base: Double = 0.0
    var intereses: Double = 0.0
    var total: Double = 0.0
    var cuota: Double = 0.0
}
