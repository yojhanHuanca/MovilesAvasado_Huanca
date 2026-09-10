# 🚆 Sistema de Gestión y Rutas del Metro de Lima y Callao (Swift)

Este proyecto es una aplicación de consola desarrollada en **Swift** basada en el paradigma de **programación estructurada**, uso de tipos de datos `struct` y un manejo intensivo de **Colecciones (`Array`, `Dictionary`, `Set`)**. 

El sistema gestiona la información de la Red Básica del Metro de Lima y Callao (Líneas 1 a 6), permitiendo a los usuarios consultar trazados, identificar estaciones de trasbordo y calcular rutas óptimas e instrucciones paso a paso para viajes comerciales.

---

## 📋 Requerimientos Funcionales Implementados
| ID | Requerimiento Funcional | Descripción del Módulo |
| :--- | :--- | :--- |
| **RF1** | **Visualización de las 6 Líneas** | Muestra la ficha técnica, características generales y estado operativo (*Operativa*, *Parcialmente Operativa*, *En Proyecto*) de la red completa. |
| **RF2** | **Consulta de Recorrido por Línea** | Despliega el catálogo secuencial de estaciones pertenecientes a una línea seleccionada, indicando su estado y si son puntos de intercambio. |
| **RF3** | **Búsqueda de Estaciones** | Permite ubicar cualquier estación de la red mediante búsqueda incremental por texto o selección desde catálogo por línea. |
| **RF4** | **Identificación de Líneas por Estación** | Muestra las líneas a las que pertenece una estación elegida y determina si es *Regular* o de *Trasbordo Multilínea*. |
| **RF5** | **Visualización de Cruces y Conexiones** | Muestra el listado exclusivo de nodos estratégicos de intercambio (estaciones donde se cruzan 2 o más líneas) y su estado técnico. |
| **RF6** | **Planificación de Ruta e Instrucciones de Trasbordo** | Ejecuta el algoritmo de búsqueda en grafos (BFS) para hallar la ruta más corta e imprime la guía paso a paso con alertas de cambio de línea (`[!!!] TRASBORDO`). |
| **RF7** | **Consulta de Estado y Disponibilidad** | Permite verificar la disponibilidad comercial de líneas/estaciones y conmuta la navegación entre *Modo Comercial* (solo operativas) y *Red Completa*. |

---

## 🏗️ Arquitectura Técnica y Colecciones

El proyecto está diseñado bajo un enfoque modular en **un solo archivo (`main.swift`)** para garantizar su portabilidad y ejecución inmediata.

### Estructuras de Datos (`struct`)
- `Estacion`: Representa la entidad de estación individual (`id`, `nombre`, `estado`).
- `Linea`: Almacena el número, nombre, características y la secuencia ordenada de IDs de estaciones (`[Int]`).
- `Conexion`: Mantiene las estaciones de intercambio y las líneas involucradas (`Set<Int>`).
- `EstadoRuta`: Estructura para el rastreo del camino y cambio de líneas en el algoritmo BFS.

### Uso de Colecciones Primordiales
- **`Array<T>`:** Mantiene el orden físico secuencial de las estaciones en cada línea y la cola de exploración del algoritmo de rutas.
- **`Set<T>`:** Almacena conjuntos de líneas en intersecciones sin duplicados y gestiona el control de nodos visitados en el algoritmo BFS para evitar bucles infinitos.
- **`Dictionary<Key, Value>`:** Estructura del **Grafo en Memoria** (`[Int: [(destinoId: Int, linea: Int)]]`) para búsquedas de conexiones adyacentes y mapeos de acceso rápido por ID.

---

## 🚀 Requisitos del Sistema y Ejecución

### Requisitos
- Compilador de **Swift 5.0** o superior.
- Compatible con macOS (Xcode / Terminal), Linux o Compiladores en línea (OnlineGDB, SwiftFiddle).

### Compilación y Ejecución desde Terminal

1. **Guardar el código:** Copia el código Swift en un archivo llamado `main.swift`.
2. **Ejecutar directamente:**
   ```bash
   swift main.swift
