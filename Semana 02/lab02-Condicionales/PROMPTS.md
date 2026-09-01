### Prompt 6 — Carrito mejorado

Quiero que me ayudes a completar este código de Swift. Es el Ejercicio 6 de un carrito de compras y quiero partir del código del Ejercicio 5 que ya tengo.

No quiero que cambies toda la estructura ni que hagas un código completamente diferente. Usa el código que te voy a pasar y agrega las nuevas funciones que pide el ejercicio.

Estas son las cosas que necesito agregar:

1. Descuento por cantidad:
   - Si el cliente compra 3 o más unidades del mismo producto, aplicar un 5% adicional sobre ese producto.
   - Este descuento debe aplicarse antes de calcular el total.

2. Cupón de descuento:
   - Pedir o tener una variable para el código del cupón.
   - Si el cupón es exactamente "DESCUENTO20", aplicar un 20% adicional al total.
   - Si no coincide, no aplicar ese descuento.

3. Envío:
   - Si el total supera S/. 3000, el envío debe ser gratis.
   - Si no supera ese monto, agregar S/. 25 por envío.

4. Puntos de fidelidad:
   - Por cada S/. 100 de compra, el cliente gana 1 punto.
   - Mostrar al final del ticket cuántos puntos ganó.

5. Validaciones:
   - Si algún precio es negativo, mostrar un mensaje de error.
   - Si alguna cantidad es 0, también mostrar un mensaje de error.
   - No quiero que el programa continúe calculando como si los datos fueran válidos.

También quiero mantener el descuento que ya existe en el código según el monto de compra, la categoría del cliente, el IGV y el ticket final.

Mantén los nombres de variables que ya existen siempre que sea posible para que el código siga siendo fácil de entender.

Al final quiero que me entregues:
1. El código completo listo para copiar y pegar.
2. Que compile en Swift.
3. Una explicación corta de qué agregaste.
4. No elimines funcionalidades que ya tenía el Ejercicio 5.


=====================================================
### Prompt Ejercicio 7:

Ayúdame a hacer el Ejercicio 7 en Swift para ejecutarlo en un Playground.

Quiero un mini juego de adivinanza de números siguiendo exactamente estos requisitos:

- Usar un número secreto fijo, por ejemplo 42.
- Tener 5 intentos usando variables separadas, como intento1 = 20, intento2 = 50, etc.
- Usar un while para recorrer y comprobar los 5 intentos.
- En cada intento debe mostrar:
  - "Muy alto" si el número ingresado es mayor que el secreto.
  - "Muy bajo" si el número ingresado es menor que el secreto.
  - "¡Correcto!" si el número es igual al secreto.
- Contar cuántos intentos fueron necesarios.
- Si después de los 5 intentos no se adivinó, mostrar:
  "Perdiste. El número era: X"
- Si se adivina antes de terminar, mostrar que ganó y en qué intento lo consiguió.

Quiero que el código sea sencillo, como para un ejercicio de estudiante de Swift. No uses cosas demasiado avanzadas ni funciones innecesarias.

Entrégame solamente el código completo listo para copiar y pegar en mi Playground.
