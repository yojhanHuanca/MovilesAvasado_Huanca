# Prompt del laboratorio 06

## CONTEXTO

Estoy haciendo el último ejercicio del laboratorio 06 de Programación en Móviles Avanzado. Necesito una calculadora de venta a plazos de electrodomésticos en Swift, usando UIKit y Storyboard. Hasta esta semana hemos trabajado con clases, UINavigationController, IBOutlet/IBAction y paso de datos entre pantallas.

## TAREA

Ayúdame a crear dos pantallas. La primera se llamará “Nueva Venta” y tendrá campos para el nombre del electrodoméstico, precio unitario, cantidad, número de meses y tasa de interés mensual, además de un botón “Calcular”.

La segunda se llamará “Resultado” y mostrará subtotal, IGV, monto base, intereses totales, total a pagar y cuota mensual.

Usa estas fórmulas:

```text
subtotal = precioUnitario * cantidad
igv = subtotal * 0.18
base = subtotal + igv
intereses = base * (tasaInteresMensual / 100) * meses
total = base + intereses
cuota = total / meses
```

Crea una clase VentaModel que herede de NSObject y tenga las propiedades subtotal, igv, base, intereses, total y cuota, todas de tipo Double.

Conecta las pantallas con un segue Show llamado showResultado y pasa el modelo con prepare(for:sender:). En Resultado, muestra los seis importes con String(format: "S/. %.2f", valor).

## RESTRICCIONES

Usa los temas vistos hasta la semana 6. No uses SwiftUI, Combine, Codable ni persistencia. Para validar los campos, usa if y if let. Comprueba que el nombre no esté vacío, que precio, cantidad y meses sean mayores que cero, y que la tasa no sea negativa. Cantidad y meses deben ser enteros.

Explícame por qué usamos class y no struct para VentaModel, y si el paso de datos hacia adelante también funcionaría con struct.

## FORMATO

Dame el código separado por archivo: VentaModel.swift, NuevaVentaViewController.swift y ResultadoViewController.swift. Incluye comentarios breves donde ayuden a entender el cálculo y el paso de datos. Indica cómo conectar los cinco UITextField, las seis UILabel y el segue en el Storyboard.

## EJEMPLO

Si ingreso una refrigeradora con precio unitario de S/. 1000, cantidad 2, plazo de 12 meses y tasa de interés mensual de 2 %, el resultado debe ser:

```text
Subtotal: S/. 2000.00
IGV: S/. 360.00
Monto base: S/. 2360.00
Intereses totales: S/. 566.40
Total a pagar: S/. 2926.40
Cuota mensual: S/. 243.87
```
