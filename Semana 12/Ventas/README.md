# Ventas

Aplicación iOS de ventas para el Laboratorio 11. Está hecha con UIKit y Core Data.

## Abrir el proyecto

1. Abre el proyecto Ventas.xcodeproj en Xcode.
2. Selecciona un simulador de iPhone y ejecuta el esquema Ventas.
3. La primera ejecución carga catálogo y clientes de demostración.
4. Entra con demo / demo123, o crea una cuenta desde Crear cuenta.

La cuenta demo es solo para practicar. El laboratorio guarda la clave como texto para simplificar el ejercicio; no es un diseño apropiado para una app real.

## Roles y pantallas

- **Vendedor:** Productos, Clientes, Venta, Mis ventas y Cuenta.
- **Supervisor:** Resumen, Ventas, Productos, Clientes y Cuenta.
- El Supervisor abre la pantalla **Anular venta** desde el historial. El motivo es obligatorio y se devuelve el stock al confirmar.

La interfaz se construye en código. No se necesita storyboard.

## Modelo persistente

Core Data almacena Usuario, Producto, Cliente y Venta. Cada venta apunta al vendedor, al producto y al cliente. Las relaciones inversas impiden borrar un usuario, producto o cliente que tenga ventas.

La categoría del cliente se calcula desde sus ventas vigentes: Regular por debajo de S/ 1.000, Frecuente desde S/ 1.000 y VIP desde S/ 5.000.

## Reglas de cálculo

- Subtotal = cantidad × precio unitario.
- VIP recibe 10 % de descuento; otras categorías no reciben descuento.
- IGV = 18 % de (subtotal − descuento).
- Total = subtotal − descuento + IGV.
- Registrar una venta reduce el stock. No se registra si la cantidad supera el stock.
- Anular requiere rol Supervisor y motivo; al anular se devuelve el stock.
- Los reportes y la categoría del cliente excluyen ventas anuladas.

## Datos de demostración

La carga inicial crea Laptop (S/ 200, stock final 40), Mouse (S/ 35, stock 40), un cliente VIP y uno Regular. La venta histórica que clasifica al VIP tiene fecha de dos meses atrás y no aparece en el resumen del mes actual. Estos datos permiten reproducir los casos 4, 5, 6 y 8 del enunciado.

## Casos para comprobar manualmente

1. Registrar mtorres como Supervisor y repetir el usuario con mayúsculas distintas: el segundo registro se rechaza.
2. Intentar registro con clave de menos de seis caracteres o confirmación distinta: no se crea la cuenta.
3. Iniciar sesión con una clave incorrecta: aparece el mensaje genérico Usuario o clave incorrectos.
4. Como Vendedor, vender 2 Laptop a S/ 200 al cliente VIP: subtotal S/ 400, descuento S/ 40, IGV S/ 64,80, total S/ 424,80 y stock de 40 a 38.
5. Vender 3 Mouse a S/ 35 al cliente Regular: subtotal S/ 105, IGV S/ 18,90 y total S/ 123,90.
6. Intentar vender 50 unidades con stock 40: se muestra un aviso y el stock no cambia.
7. Como Vendedor, abrir Mis ventas: solo aparecen ventas propias y no se ofrece anular.
8. Como Supervisor, intentar anular sin motivo y luego con motivo: la primera acción se bloquea; la segunda devuelve el stock y excluye la venta de los reportes.
9. Intentar borrar el cliente VIP con ventas: el borrado se bloquea y se informa al usuario.

## Nota de entrega

El trabajo generado con apoyo de IA está registrado en PROMPTS.md y en la rama ia-asistida. La rama main contiene la entrega final. El equipo debe ejecutar los casos en Xcode, capturar la aplicación en el simulador y explicar el código durante la defensa.
