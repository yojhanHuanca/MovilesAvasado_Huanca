// ===== EJERCICIO 3: FOR-IN =====

// --- Ejemplo (ya resuelto) ---
for i in 1...5 {
    print("Número: \(i)")
}

// --- TODO 7: Tabla de multiplicar del 7 ---
for i in 1...12 {
    print("7 x \(i) = \(7 * i)")
}

// --- TODO 8: Sumatoria del 1 al 100 ---
var suma = 0
for i in 1...100 {
    suma = suma + i
}
print("La suma del 1 al 100 es: \(suma)")   // Debe dar 5050

// --- TODO 9: Calcular el factorial de 8 ---
var factorial = 1
for i in 1...8 {
    factorial = factorial * i
}
print("8! = \(factorial)")

// --- TODO 10: Patrón de asteriscos ---
for i in 1...5 {
    print(String(repeating: "*", count: i))
}

// FIX 4: era i % 2 == 1 (imprimía impares); para pares es i % 2 == 0
for i in 1...20 {
    if i % 2 == 0 {
        print(i)
    }
}

// FIX 5: cuenta regresiva con stride
for i in stride(from: 10, through: 1, by: -1) {
    print(i)
}

// PREDICT
var total = 0
for i in 1...5 {
    total += i
}
print(total)
// PREDICT 6: Valor 15, 5 iteraciones

var texto = ""
for _ in 1...3 {
    texto += "Hola "
}
print(texto)
// PREDICT 7: "Hola Hola Hola " -> "_" se usa cuando no se necesita el índice

