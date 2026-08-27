import Foundation
print("=== SISTEMA DE PRÉSTAMO DE LIBROS ===")
print()

print("Ingrese el título del libro:")
let titulo = readLine() ?? "Sin título"

print("Ingrese el tipo de usuario (alumno/docente/admin):")
let tipoUsuario = readLine()?.lowercased() ?? "alumno"

print("Ingrese la fecha de préstamo (yyyy-MM-dd):")
let fechaPrestamoStr = readLine() ?? "2026-08-18"

print("Ingrese la fecha de devolución (yyyy-MM-dd):")
let fechaDevolucionStr = readLine() ?? "2026-08-21"

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd"

let fechaPrestamo = dateFormatter.date(from: fechaPrestamoStr) ?? Date()
let fechaDevolucion = dateFormatter.date(from: fechaDevolucionStr) ?? Date()

var diasPermitidos = 0

switch tipoUsuario {
case "alumno":
    diasPermitidos = 7
case "docente":
    diasPermitidos = 15
case "admin", "administrador":
    diasPermitidos = 10
default:
    diasPermitidos = 7
}

let diasPrestamo = Calendar.current.dateComponents(
    [.day],
    from: fechaPrestamo,
    to: fechaDevolucion
).day ?? 0

let diasAtraso = max(0, diasPrestamo - diasPermitidos)

let multaBase = 1.50
var multaTotal = 0.0

if diasAtraso > 0 {
    for dia in 1...diasAtraso {
        if dia <= 3 {
            multaTotal += multaBase
        } else if dia <= 6 {
            multaTotal += multaBase * 1.50
        } else {
            multaTotal += multaBase * 2.00
        }
    }
}

let usuarioSuspendido = diasAtraso >= 10

print()
print("=== RESULTADOS FINALES ===")
print("Título del libro: \(titulo)")
print("Tipo de usuario: \(tipoUsuario)")
print("Fecha de préstamo: \(fechaPrestamoStr)")
print("Fecha de devolución: \(fechaDevolucionStr)")
print("Días prestados: \(diasPrestamo)")
print("Días permitidos: \(diasPermitidos)")
print("Días de atraso: \(diasAtraso)")
print(String(format: "Multa total: S/ %.2f", multaTotal))

if diasAtraso == 0 {
    print("Estado: Devuelto a tiempo")
} else {
    print("Estado: Devuelto con atraso")
}

if usuarioSuspendido {
    print("Situación del usuario: Suspendido")
} else {
    print("Situación del usuario: Habilitado")
}


print()
print("=== RESULTADOS FINALES ===")
print("Título del libro: \(titulo)")
print("Tipo de usuario: \(tipoUsuario)")
print("Fecha de préstamo: \(fechaPrestamoStr)")
print("Fecha de devolución: \(fechaDevolucionStr)")
print("Días prestados: \(diasPrestamo)")
print("Días permitidos: \(diasPermitidos)")
print("Días de atraso: \(diasAtraso)")
print(String(format: "Multa total: S/ %.2f", multaTotal))

if diasAtraso == 0 {
    print("Estado: Devuelto a tiempo")
} else {
    print("Estado: Devuelto con atraso")
}

if usuarioSuspendido {
    print("Situación del usuario: Suspendido")
} else {
    print("Situación del usuario: Habilitado")
}


