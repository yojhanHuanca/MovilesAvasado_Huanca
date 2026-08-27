import Foundation
//  Objetivo: Solicitar y guardar los datos del préstamo
print("=== SISTEMA DE PRÉSTAMO DE LIBROS ===")
print()

// 1. Título del libro
print("Ingrese el título del libro:")
let titulo = readLine() ?? "Sin título"

// 2. Tipo de usuario
print("Ingrese el tipo de usuario (alumno/docente/admin):")
let tipoUsuario = readLine()?.lowercased() ?? "alumno"

// 3. Fecha de préstamo
print("Ingrese la fecha de préstamo (yyyy-MM-dd):")
let fechaPrestamo = readLine() ?? "2026-08-18"

// 4. Fecha de devolución
print("Ingrese la fecha de devolución (yyyy-MM-dd):")
let fechaDevolucion = readLine() ?? "2026-08-21"

//  MOSTRAR DATOS INGRESADOS
print()
print("=== DATOS REGISTRADOS ===")
print("Título: \(titulo)")
print("Usuario: \(tipoUsuario)")
print("Préstamo: \(fechaPrestamo)")
print("Devolución: \(fechaDevolucion)")


