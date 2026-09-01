// ============================================
// EJERCICIO 6: CARRITO MEJORADO (asistido por IA)
// ============================================

let prod1 = "Laptop"; let precio1 = 3500.0; let cant1 = 1
let prod2 = "Mouse"; let precio2 = 45.50; let cant2 = 2
let prod3 = "Teclado"; let precio3 = 120.00; let cant3 = 1
let prod4 = "Monitor"; let precio4 = 890.00; let cant4 = 1
let prod5 = "USB Cable"; let precio5 = 15.00; let cant5 = 3

// junto todos los precios y cantidades en arrays para no repetir el mismo if 5 veces
let precios = [precio1, precio2, precio3, precio4, precio5]
let cantidades = [cant1, cant2, cant3, cant4, cant5]

var datosValidos = true
for precio in precios {
    if precio < 0 {                          // no tiene sentido un precio negativo
        print("Error: hay un precio negativo en el carrito")
        datosValidos = false
    }
}
for cantidad in cantidades {
    if cantidad == 0 {                       // si la cantidad es 0 ese producto no debería estar
        print("Error: hay una cantidad en 0 en el carrito")
        datosValidos = false
    }
}

if datosValidos {

    // función para no repetir la misma regla del 5% en cada producto
    func subtotalConDescuentoPorCantidad(precio: Double, cantidad: Int) -> Double {
        let subtotal = precio * Double(cantidad)
        if cantidad >= 3 {                   // 3 o más del mismo producto = 5% extra
            return subtotal * 0.95
        }
        return subtotal
    }

    let sub1 = subtotalConDescuentoPorCantidad(precio: precio1, cantidad: cant1)
    let sub2 = subtotalConDescuentoPorCantidad(precio: precio2, cantidad: cant2)
    let sub3 = subtotalConDescuentoPorCantidad(precio: precio3, cantidad: cant3)
    let sub4 = subtotalConDescuentoPorCantidad(precio: precio4, cantidad: cant4)
    let sub5 = subtotalConDescuentoPorCantidad(precio: precio5, cantidad: cant5) // cant5 es 3, aquí sí aplica

    let subtotalGeneral = sub1 + sub2 + sub3 + sub4 + sub5

    // mismo descuento por monto del ejercicio 5
    var porcentajeDescuento = 0.0
    if subtotalGeneral >= 5000 {
        porcentajeDescuento = 0.15
    } else if subtotalGeneral >= 2000 {
        porcentajeDescuento = 0.10
    } else if subtotalGeneral >= 500 {
        porcentajeDescuento = 0.05
    }
    let descuentoGeneral = subtotalGeneral * porcentajeDescuento
    var totalConDescuentos = subtotalGeneral - descuentoGeneral   // var porque el cupón lo baja más todavía

    // cupón fijo "DESCUENTO20" = 20% extra sobre lo que ya quedó
    let cuponIngresado = "DESCUENTO20"
    if cuponIngresado == "DESCUENTO20" {
        totalConDescuentos = totalConDescuentos * 0.80
    }

    // si pasa de 3000 el envío sale gratis, si no son 25 soles
    let costoEnvio = totalConDescuentos > 3000 ? 0.0 : 25.0

    let igv = totalConDescuentos * 0.18
    let totalFinal = totalConDescuentos + igv + costoEnvio

    // 1 punto por cada 100 soles de compra (sobre el subtotal original)
    let puntosGanados = Int(subtotalGeneral / 100)

    print("Subtotal con descuento por cantidad: S/. \(subtotalGeneral)")
    print("Descuento general (\(porcentajeDescuento * 100)%) + cupón aplicados")
    print("Costo de envío: S/. \(costoEnvio)")
    print("IGV (18%): S/. \(igv)")
    print("TOTAL FINAL: S/. \(totalFinal)")
    print("Puntos de fidelidad ganados: \(puntosGanados)")
}
