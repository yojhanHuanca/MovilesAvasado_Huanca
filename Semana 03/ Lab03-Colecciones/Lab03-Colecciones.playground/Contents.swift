// ============================================
// EJERCICIO 6: GESTION DE NOTAS (asistido por IA)
// ============================================
// Desarrollado por: Huanca Yojhan

import Foundation

var alumnos: [String: [Double]] = [:]                      // diccionario: nombre -> array de 3 notas

print("¿Cuántos alumnos?")
let totalAlumnos = Int(readLine() ?? "") ?? 0                // convierte la respuesta a Int, 0 si falla

for i in 1...totalAlumnos {                                  // repite una vez por cada alumno
    print("\nAlumno \(i) - Nombre:")
    let nombre = readLine() ?? ""                             // lee el nombre del alumno
    var notas: [Double] = []                                  // array temporal para las 3 notas de este alumno
    for j in 1...3 {                                          // pide exactamente 3 notas
        print("Nota \(j):")
        let nota = Double(readLine() ?? "") ?? 0               // convierte a Double, 0 si falla
        notas.append(nota)                                     // agrega la nota al array temporal
    }
    alumnos[nombre] = notas                                    // guarda el array de notas en el diccionario, con el nombre como clave
}

print("\n===== PROMEDIOS Y CLASIFICACIÓN =====")
var promedios: [String: Double] = [:]                         // diccionario nombre -> promedio, para reusar en las estadísticas
var aprobadosCount = 0                                         // contador de alumnos aprobados (promedio >= 13)

for (nombre, notas) in alumnos {                                // recorre cada alumno registrado
    let suma = notas.reduce(0, +)                                // suma las 3 notas (reduce las va acumulando desde 0)
    let promedio = suma / Double(notas.count)                    // promedio = suma entre cantidad de notas
    promedios[nombre] = promedio                                 // guarda el promedio para las estadísticas de después

    var clasificacion = ""
    switch promedio {                                            // switch sobre el promedio (funciona con rangos de Double)
    case 18...20: clasificacion = "Excelente"
    case 15..<18: clasificacion = "Bueno"
    case 13..<15: clasificacion = "Aprobado"
    default: clasificacion = "Desaprobado"
    }

    if promedio >= 13 { aprobadosCount += 1 }                     // si aprobó, suma al contador de aprobados

    print("\(nombre): notas \(notas) -> promedio \(promedio) -> \(clasificacion)")
}

// Estadísticas generales
let sumaPromedios = promedios.values.reduce(0, +)                // suma todos los promedios de la clase
let promedioGeneral = sumaPromedios / Double(promedios.count)     // promedio general = suma / cantidad de alumnos
let notaMasAlta = promedios.values.max() ?? 0                     // el promedio más alto entre todos
let notaMasBaja = promedios.values.min() ?? 0                     // el promedio más bajo entre todos
let porcentajeAprobados = Double(aprobadosCount) / Double(promedios.count) * 100   // % de aprobados

print("\n===== ESTADÍSTICAS GENERALES =====")
print("Promedio general: \(promedioGeneral)")
print("Nota más alta: \(notaMasAlta)")
print("Nota más baja: \(notaMasBaja)")
print("Porcentaje de aprobados: \(porcentajeAprobados)%")

// Ordenar por promedio (de mayor a menor)
let ordenados = promedios.sorted { $0.value > $1.value }          // sorted() sobre un diccionario da un array de tuplas (nombre, promedio) ordenado

print("\n===== RANKING POR PROMEDIO =====")
for (nombre, promedio) in ordenados {
    print("\(nombre): \(promedio)")
}


// ============================================
// EJERCICIO 7: INVENTARIO CON MENU (asistido por IA)
// ============================================

var preciosInv: [String: Double] = [:]                      // diccionario nombre -> precio
var stocksInv: [String: Int] = [:]                            // diccionario nombre -> stock

print("¿Cuántos productos va a registrar?")                   // pregunta cuántos productos entran al inventario
let totalProd = Int(readLine() ?? "") ?? 0                     // convierte a Int, 0 si falla

for i in 1...totalProd {                                       // repite una vez por producto
    print("\nProducto \(i) - Nombre:")
    let nombre = readLine() ?? ""                                // lee el nombre del producto
    print("Precio:")
    let precio = Double(readLine() ?? "") ?? 0                   // lee y convierte el precio
    print("Stock:")
    let stock = Int(readLine() ?? "") ?? 0                        // lee y convierte el stock
    preciosInv[nombre] = precio                                   // guarda el precio en el diccionario
    stocksInv[nombre] = stock                                     // guarda el stock en el diccionario
}

var salir = false                                               // bandera que controla cuándo terminar el menú

while !salir {                                                   // se repite mientras la bandera siga en false
    print("""

    ===== MENU INVENTARIO =====
    1) Ver inventario
    2) Buscar producto
    3) Ver stock bajo (< 5)
    4) Ver valor total
    5) Salir
    """)                                                           // muestra las opciones del menú (string multilínea)
    print("Elige una opción:")
    let opcion = Int(readLine() ?? "") ?? 0                         // lee la opción elegida como número

    switch opcion {                                                 // decide qué hacer según la opción
    case 1:                                                         // opción 1: ver todo el inventario
        print("\n===== INVENTARIO =====")
        for (nombre, precio) in preciosInv {                         // recorre cada producto
            let stock = stocksInv[nombre] ?? 0                        // obtiene su stock (0 si no existiera)
            print("\(nombre): S/. \(precio) - Stock: \(stock)")
        }

    case 2:                                                         // opción 2: buscar un producto puntual
        print("Nombre del producto a buscar:")
        let buscar = readLine() ?? ""                                 // lee el nombre a buscar
        if let precio = preciosInv[buscar], let stock = stocksInv[buscar] {   // busca en ambos diccionarios de forma segura
            print("\(buscar): S/. \(precio) - Stock: \(stock)")
        } else {
            print("Producto no encontrado")
        }

    case 3:                                                         // opción 3: productos con poco stock
        print("\n===== STOCK BAJO (< 5) =====")
        for (nombre, stock) in stocksInv {                            // recorre los stocks
            if stock < 5 {                                             // filtra solo los bajos
                print("\(nombre): \(stock) unidades")
            }
        }

    case 4:                                                         // opción 4: valor total del inventario
        var valorTotal = 0.0                                          // acumulador del valor total
        for (nombre, precio) in preciosInv {                           // recorre cada producto
            let stock = stocksInv[nombre] ?? 0                          // obtiene su stock
            valorTotal += precio * Double(stock)                        // suma precio x stock al total
        }
        print("Valor total del inventario: S/. \(valorTotal)")

    case 5:                                                         // opción 5: terminar el programa
        print("Saliendo del sistema de inventario...")
        salir = true                                                  // apaga la bandera para que el while termine

    default:                                                        // cualquier número que no sea 1-5
        print("Opción no válida")
    }
}
