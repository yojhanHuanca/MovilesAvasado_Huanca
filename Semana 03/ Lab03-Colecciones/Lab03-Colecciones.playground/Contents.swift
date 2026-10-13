// Desarrollado por: Huanca Yojhan
import Foundation
// ===== TODO 1: Registro de 5 alumnos =====
var alumnos: [String] = []
for i in 1...5 {
print("Nombre del alumno \(i):")
let nombre = readLine() ?? ""
alumnos.append(nombre)
}
print("Alumnos: \(alumnos)")
// ===== TODO 2: Buscar un alumno =====
print("Buscar alumno:")
let buscar = readLine() ?? ""
if alumnos.contains(buscar) {
print("\(buscar) está en la lista")
} else {
print("\(buscar) NO está en la lista")
}
// ===== TODO 3: Notas con clasificación =====
var notasClase: [Double] = []
for i in 1...5 {
print("Nota del alumno \(i):")
let n = Double(readLine() ?? "") ?? 0
notasClase.append(n)
}
var aprobados = 0
var desaprobados = 0
var sumaNotas = 0.0
for nota in notasClase {
sumaNotas += nota
if nota >= 13 {
aprobados += 1
} else {
desaprobados += 1
}
}
print("Promedio: \(sumaNotas / Double(notasClase.count))")
print("Aprobados: \(aprobados), Desaprobados: \(desaprobados)")



// ===== FIX: 3 errores =====
var frutas = ["Manzana", "Plátano", "Naranja"]
frutas.append("uva") // FIX 1

var colores = ["Rojo", "Azul", "Verde"]
colores.append("Amarillo") // FIX 2

let numeros = [10, 20, 30, 40, 50]
print(numeros[4]) // FIX 3


var lista = [1, 2, 3, 4, 5]
lista.remove(at: 0)
lista.append(6)
print(lista) // PREDICT 1: [2, 3, 4, 5, 6]
print(lista.count) // PREDICT 2: 5
var nombres = ["Ana", "Carlos", "Beto"]
print(nombres.sorted()) // PREDICT 3: ["Ana", "beto", "Carlos"]
print(nombres) // PREDICT 4: ["Ana", "Carlos", "Beto"]





// Desarrollado por: Huanca Yojhan
import Foundation
// ===== TODO 4: Catálogo de productos =====
var productos: [String: Double] = [:]
for i in 1...4 {
print("Producto \(i) - Nombre:")
let nombre = readLine() ?? ""
print("Precio:")
let precio = Double(readLine() ?? "") ?? 0
productos[nombre] = precio
}

// ===== TODO 5: Mostrar catálogo =====
print("===== CATÁLOGO =====")
for (nombre, precio) in productos {
print("\(nombre): S/. \(precio)")
}
// ===== TODO 6: Valor total =====
var valorTotal = 0.0
for (_, precio) in productos {
valorTotal += precio
}
print("Valor total: S/. \(valorTotal)")
// ===== TODO 7: Buscar producto =====
print("Buscar producto:")
let buscarProd = readLine() ?? ""
if let precioEncontrado = productos[buscarProd] {
print("\(buscarProd) cuesta S/. \(precioEncontrado)")
} else {
print("Producto no encontrado")
}

// ===== ANALYZE =====
var edades: [String: Int] = ["Ana": 20, "Luis": 22, "María": 19]
var mayores: [String] = []
for (nombre, edad) in edades {
if edad >= 21 {
mayores.append(nombre)
}
}
print("Mayores de 21: \(mayores)")

// ANALYZE 1: ¿Qué hace?
// Recorre el diccionario de edades evalúa si la edad de cada persona es mayor o igual a 21 y de ser así, agrega su nombre al arreglo 'mayores'.

// ANALYZE 1: ¿Qué imprime?
// Imprime: Mayores de 21: Luis


// Desarrollado por: [TU NOMBRE]
// ===== TODO 8: Eliminar duplicados =====
var numeros: [Int] = []
for i in 1...8 {
    print("Número \(i):")
    let n = Int(readLine() ?? "") ?? 0
    numeros.append(n)
}
print("Con duplicados: \(numeros)")

let sinDuplicados = Array(Set(numeros)).sorted()
print("Sin duplicados: \(sinDuplicados)")

// ===== TODO 9: Comparar asistencia =====
var asistenciaLunes: Set<String> = []
print("\n==== ASISTENCIA LUNES ====")
for i in 1...4 {
    print("Alumno \(i) Lunes:")
    let nombre = readLine() ?? ""
    asistenciaLunes.insert(nombre)
}

var asistenciaMartes: Set<String> = []
print("\n==== ASISTENCIA MARTES ====")
for i in 1...4 {
    print("Alumno \(i) Martes:")
    let nombre = readLine() ?? ""
    asistenciaMartes.insert(nombre)
}

let asistieronAmbos = asistenciaLunes.intersection(asistenciaMartes)
let soloLunes = asistenciaLunes.subtracting(asistenciaMartes)
let soloMartes = asistenciaMartes.subtracting(asistenciaLunes)

print("\n==== REPORTE DE ASISTENCIA ====")
print("Asistieron ambos días: \(asistieronAmbos)")
print("Solo asistieron el lunes: \(soloLunes)")
print("Solo asistieron el martes: \(soloMartes)")

// ===== PREDICT =====
let a: Set = [1, 2, 3, 4, 5]
let b: Set = [4, 5, 6, 7, 8]

print(a.intersection(b)) // PREDICT 5: [4, 5] (o [5, 4] sin orden fijo)
print(a.union(b).count)  // PREDICT 6: 8
print(a.subtracting(b)) // PREDICT 7: [1, 2, 3] (sin orden fijo)

var repetidos: Set = ["A", "B", "A", "C", "B"]
print(repetidos.count)   // PREDICT 8: 3




// Desarrollado por: Huanca Yojhan

import Foundation

// Pide N productos con nombre, precio y stock
// Calcula valor total y muestra stock bajo
var precios: [String: Double] = [:]
var stocks: [String: Int] = [:]

print("¿Cuántos productos?")
let n = Int(readLine() ?? "") ?? 0
for i in 1...n {
    print("Producto \(i) - Nombre:")
    let nombre = readLine() ?? ""
    print("Precio:")
    let precio = Double(readLine() ?? "") ?? 0
    print("Stock:")
    let stock = Int(readLine() ?? "") ?? 0
    precios[nombre] = precio
    stocks[nombre] = stock
}

// Calcular valor total (precio × stock)
var valorTotalInventario = 0.0
for (nombre, precio) in precios {
    if let stock = stocks[nombre] {
        valorTotalInventario += precio * Double(stock)
    }
}
print("\nValor total del inventario: S/. \(valorTotalInventario)")

// Mostrar productos con stock < 5
print("\n===== PRODUCTOS CON STOCK BAJO (< 5) =====")
for (nombre, stock) in stocks {
    if stock < 5 {
        print("\(nombre): \(stock) unidades")
    }
}



// ===== CARRITO DE COMPRAS 2.0 =====
// Desarrollado por: Huanca Yojhan

import Foundation

var nombres: [String] = []
var precios: [Double] = []
var cantidades: [Int] = []

// TODO 11: Pedir productos
print("¿Cuántos productos va a comprar?")
let totalProductos = Int(readLine() ?? "") ?? 0
for i in 1...totalProductos {
    print("\nProducto \(i) - Nombre:")
    nombres.append(readLine() ?? "")
    print("Precio unitario:")
    precios.append(Double(readLine() ?? "") ?? 0)
    print("Cantidad:")
    cantidades.append(Int(readLine() ?? "") ?? 0)
}

// TODO 12: Calcular subtotales
var subtotales: [Double] = []
for i in 0..<nombres.count {
    let sub = precios[i] * Double(cantidades[i])
    subtotales.append(sub)
}

// TODO 13: Total del carrito
var totalCarrito = 0.0
for sub in subtotales {
    totalCarrito += sub
}

// TODO 14: Nombre del cliente
print("\nNombre del cliente:")
let cliente = readLine() ?? ""

// TODO 15: Descuento
var descPct = 0.0
if totalCarrito >= 5000 { descPct = 0.15 }
else if totalCarrito >= 2000 { descPct = 0.10 }
else if totalCarrito >= 500 { descPct = 0.05 }
let descuento = totalCarrito * descPct
let totalConDesc = totalCarrito - descuento

// TODO 16: IGV y total
let igv = totalConDesc * 0.18
let totalFinal = totalConDesc + igv

// TODO 17: Categoría
var categoria = ""
switch Int(totalCarrito) {
case 0..<500: categoria = "Regular"
case 500..<2000: categoria = "Frecuente"
case 2000..<5000: categoria = "VIP"
default: categoria = "Premium"
}

// TODO 18: Ticket
let sep = String(repeating: "=", count: 45)
print(sep)
print("      TICKET DE COMPRA 2.0")
print("  Cliente: \(cliente) (\(categoria))")
print(sep)
for i in 0..<nombres.count {
    print("\(nombres[i]) x\(cantidades[i])   S/. \(subtotales[i])")
}
print(sep)
print("Subtotal:            S/. \(totalCarrito)")
if descPct > 0 {
    print("Descuento (\(descPct*100)%): -S/. \(descuento)")
}
print("IGV (18%):            S/. \(igv)")
print(sep)
print("TOTAL:                S/. \(totalFinal)")
print(sep)
print("¡Gracias por su compra, \(cliente)!")


