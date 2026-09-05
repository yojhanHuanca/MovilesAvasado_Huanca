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
