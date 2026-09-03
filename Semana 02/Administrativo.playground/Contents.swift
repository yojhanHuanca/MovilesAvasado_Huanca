import Foundation

print("=== SISTEMA DE PRÉSTAMO DE LIBROS ===")

print()

print("Ingrese el título del libro:")

let titulo = readLine() ?? "Sin título"

print("Ingrese el tipo de usuario:")

print("1. Alumno")
print("2. Docente")
print("3. Administrador")
print("4. Coordinador")

print("Seleccione una opción:")

let opcionUsuario = Int(readLine() ?? "1") ?? 1

var tipoUsuario = ""

switch opcionUsuario {

case 1:
    tipoUsuario = "alumno"

case 2:
    tipoUsuario = "docente"

case 3:
    tipoUsuario = "administrador"

case 4:
    tipoUsuario = "coordinador"

default:
    tipoUsuario = "alumno"
}

let dateFormatter = DateFormatter()

dateFormatter.dateFormat = "yyyy-MM-dd"

print("Ingrese la fecha de préstamo (yyyy-MM-dd):")

var fechaPrestamoStr = ""

while fechaPrestamoStr.isEmpty || dateFormatter.date(from: fechaPrestamoStr) == nil {

    fechaPrestamoStr = readLine() ?? ""

    if dateFormatter.date(from: fechaPrestamoStr) == nil {
        print("Fecha inválida. Ingrese una fecha válida (yyyy-MM-dd):")
    }
}

print("Ingrese la fecha de devolución (yyyy-MM-dd):")

var fechaDevolucionStr = ""

while fechaDevolucionStr.isEmpty || dateFormatter.date(from: fechaDevolucionStr) == nil {

    fechaDevolucionStr = readLine() ?? ""

    if dateFormatter.date(from: fechaDevolucionStr) == nil {
        print("Fecha inválida. Ingrese una fecha válida (yyyy-MM-dd):")
    }
}

let fechaPrestamo = dateFormatter.date(from: fechaPrestamoStr) ?? Date()

let fechaDevolucion = dateFormatter.date(from: fechaDevolucionStr) ?? Date()

var diasPermitidos = 0

var costoDiario = 1.50

switch tipoUsuario {

case "alumno":
    diasPermitidos = 7
    costoDiario = 1.50

case "docente":
    diasPermitidos = 15
    costoDiario = 1.50

case "admin", "administrador":
    diasPermitidos = 10
    costoDiario = 1.50

case "coordinador":
    diasPermitidos = 15
    costoDiario = 4.00

default:
    diasPermitidos = 7
    costoDiario = 1.50
}

let diasPrestamo = Calendar.current.dateComponents(
    [.day],
    from: fechaPrestamo,
    to: fechaDevolucion
).day ?? 0

let diasAtraso = max(0, diasPrestamo - diasPermitidos)

var multaTotal = 0.0

if diasAtraso > 0 {

    for dia in 1...diasAtraso {

        if dia <= 3 {

            multaTotal += 0

        } else if dia <= 6 {

            multaTotal += costoDiario * 1.25

        } else if dia <= 10 {

            multaTotal += costoDiario * 1.50

        } else if dia <= 20 {

            multaTotal += costoDiario * 2.00
        }
    }
}

let usuarioSuspendido = diasAtraso >= 20

print()

print("=== RESULTADOS FINALES ===")

print("Título del libro: \(titulo)")

print("Tipo de usuario: \(tipoUsuario)")

print("Fecha de préstamo: \(fechaPrestamoStr)")

print("Fecha de devolución: \(fechaDevolucionStr)")

print("Días prestados: \(diasPrestamo)")

print("Días permitidos: \(diasPermitidos)")

print("Días de atraso: \(diasAtraso)")

print(String(format: "Costo diario: S/ %.2f", costoDiario))

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
