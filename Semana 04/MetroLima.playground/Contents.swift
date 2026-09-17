import Foundation

// ==========================================
// ESTRUCTURAS DE DATOS (STRUCTS)
// ==========================================

struct Estacion: Hashable {
    let id: Int
    let nombre: String
    var estado: String // Operativa, Fuera de Servicio, En Construccion, En Proyecto
}

struct Linea {
    let numero: Int
    var nombre: String
    var estado: String // Operativa, Parcialmente Operativa, En Proyecto
    var caracteristicas: String
    var estacionesIds: [Int]
}

struct Conexion {
    let estacionId: Int
    let lineasInvolucradas: Set<Int>
    let estadoConexion: String
}

struct EstadoRuta {
    let estacionActual: Int
    let lineaActual: Int
    let camino: [(estacionId: Int, numeroLinea: Int)]
}

struct Tarjeta {
    var id: String
    var saldo: Double
    let tarifaBase: Double = 1.50
}

// ==========================================
// COLECCIONES Y ESTADO GLOBAL
// ==========================================

var listaEstaciones: [Estacion] = []
var mapaIdANombre: [Int: String] = [:]
var mapaNombreAId: [String: Int] = [:]
var mapaIdAEstacion: [Int: Estacion] = [:]
var listaLineas: [Linea] = []
var listaConexiones: [Conexion] = []

// Grafo: [IdEstacionOrigen: [(IdEstacionDestino, NumeroLinea)]]
var grafo: [Int: [(destinoId: Int, linea: Int)]] = [:]

// Tarjeta del usuario
var tarjetaUsuario = Tarjeta(id: "LIMA-987654", saldo: 10.00)

// ==========================================
// COMPONENTES VISUALES Y AUXILIARES
// ==========================================

func badgeEstado(_ estado: String) -> String {
    switch estado {
    case "Operativa":
        return "🟢 [OPERATIVA]       "
    case "Fuera de Servicio":
        return "🔴 [FUERA DE SERVICIO]"
    case "Parcialmente Operativa":
        return "🟡 [PARCIAL OPER]    "
    case "En Construccion":
        return "🟠 [EN OBRAS]        "
    default:
        return "⚪ [EN PROYECTO]     "
    }
}

func cuadroBanner(_ titulo: String) {
    let ancho = 68
    let lineaHorizontal = String(repeating: "═", count: ancho)
    print("\n╔\(lineaHorizontal)╗")
    
    let espaciosIzquierda = max(0, (ancho - titulo.count) / 2)
    let espaciosDerecha = max(0, ancho - titulo.count - espaciosIzquierda)
    let tituloCentrado = String(repeating: " ", count: espaciosIzquierda) + titulo + String(repeating: " ", count: espaciosDerecha)
    
    print("║\(tituloCentrado)║")
    print("╚\(lineaHorizontal)╝")
}

func obtenerOCrearEstacion(nombre: String, estadoInicial: String) -> Int {
    if let idExistente = mapaNombreAId[nombre] {
        return idExistente
    }
    let nuevoId = listaEstaciones.count + 1
    let nuevaEstacion = Estacion(id: nuevoId, nombre: nombre, estado: estadoInicial)
    listaEstaciones.append(nuevaEstacion)
    mapaIdANombre[nuevoId] = nombre
    mapaNombreAId[nombre] = nuevoId
    mapaIdAEstacion[nuevoId] = nuevaEstacion
    return nuevoId
}

func reconstruirGrafoYConexiones() {
    grafo.removeAll()
    listaConexiones.removeAll()

    for lin in listaLineas {
        for i in 0..<lin.estacionesIds.count {
            if i > 0 {
                let idAnt = lin.estacionesIds[i - 1]
                let idActual = lin.estacionesIds[i]
                grafo[idAnt, default: []].append((destinoId: idActual, linea: lin.numero))
                grafo[idActual, default: []].append((destinoId: idAnt, linea: lin.numero))
            }
        }
    }

    for est in listaEstaciones {
        var lineasAsociadas = Set<Int>()
        for lin in listaLineas {
            if lin.estacionesIds.contains(est.id) {
                lineasAsociadas.insert(lin.numero)
            }
        }
        
        if lineasAsociadas.count > 1 {
            var estConexion = "Red Basica de Transbordo"
            if lineasAsociadas.contains(1) && lineasAsociadas.contains(2) {
                estConexion = "Intercambio 28 de Julio"
            } else if lineasAsociadas.contains(2) && lineasAsociadas.contains(4) {
                estConexion = "Ramal Av. Faucett"
            }
            listaConexiones.append(Conexion(estacionId: est.id, lineasInvolucradas: lineasAsociadas, estadoConexion: estConexion))
        }
    }
}

// ==========================================
// CARGA INICIAL DE DATOS
// ==========================================

func cargarDatosMetro() {
    listaEstaciones.removeAll()
    mapaIdANombre.removeAll()
    mapaNombreAId.removeAll()
    mapaIdAEstacion.removeAll()
    listaLineas.removeAll()

    // LÍNEA 1
    let estL1 = ["Villa El Salvador", "Parque Industrial", "Pumacahua", "Villa Maria", "Maria Auxiliadora", "San Juan", "Atocongo", "Jorge Chavez", "Ayacucho", "Cabitos", "Angamos", "San Borja Sur", "La Cultura", "Arriola", "Gamarra", "28 de Julio", "Miguel Grau", "El Angel", "Presbitero Maestro", "Caja de Agua", "Piramide del Sol", "Los Jardines", "Los Postes", "San Carlos", "San Martin", "Santa Rosa", "Bayovar"]
    var l1 = Linea(numero: 1, nombre: "Linea 1 (Sur - Este)", estado: "Operativa", caracteristicas: "Via elevada de Villa El Salvador a SJL.", estacionesIds: [])
    for nombre in estL1 {
        let id = obtenerOCrearEstacion(nombre: nombre, estadoInicial: "Operativa")
        l1.estacionesIds.append(id)
    }
    listaLineas.append(l1)

    // LÍNEA 2
    let estL2Operativas = Set(["Evitamiento", "Ovalo Santa Anita", "Colectora Industrial", "Hermilio Valdizan", "Mercado Santa Anita"])
    let estL2 = ["Puerto del Callao", "Buenos Aires", "Juan Pablo II", "Insurgentes", "Carmen de la Legua", "Oscar Benavides", "San Jose", "Dique Bellavista", "Tingo Maria", "Parque Murillo", "Plaza Bolognesi", "Estacion Central", "Manco Capac", "Cangallo", "28 de Julio", "Nicolas Ayllon", "Yerbateros", "Circunvalacion", "San Juan de Dios", "Evitamiento", "Ovalo Santa Anita", "Colectora Industrial", "Hermilio Valdizan", "Mercado Santa Anita", "Vista Alegre", "Prolongacion Javier Prado", "Municipalidad de Ate"]
    var l2 = Linea(numero: 2, nombre: "Linea 2 (Oeste - Este)", estado: "Parcialmente Operativa", caracteristicas: "Corredor subterraneo Callao - Ate.", estacionesIds: [])
    for nombre in estL2 {
        let estadoEst = estL2Operativas.contains(nombre) ? "Operativa" : "En Construccion"
        let id = obtenerOCrearEstacion(nombre: nombre, estadoInicial: estadoEst)
        l2.estacionesIds.append(id)
    }
    listaLineas.append(l2)

    // LÍNEA 3
    let estL3 = ["El Alamo", "Huandoy", "Universidad", "Naranjal", "Izaguirre", "Tomas Valle", "Bartholome de las Casas", "Jose Granda", "Caqueta", "Plaza Acho", "Tacna", "Garcilaso de la Vega", "Estacion Central", "Parque Universitario", "Exposicion", "Pardo de Zela", "Mexico", "Canada", "Javier Prado", "Guardia Civil", "Republica de Panama", "Benavides", "Cabitos", "Higuereta", "Tomas Marsano", "Primavera", "Pedro Miotta"]
    var l3 = Linea(numero: 3, nombre: "Linea 3 (Norte - Sur)", estado: "En Proyecto", caracteristicas: "Eje Comas - Miraflores - Surco.", estacionesIds: [])
    for nombre in estL3 {
        let id = obtenerOCrearEstacion(nombre: nombre, estadoInicial: "En Proyecto")
        l3.estacionesIds.append(id)
    }
    listaLineas.append(l3)

    // LÍNEA 4
    let estL4 = ["Gambetta", "Canta Callao", "Bocanegra", "Aeropuerto", "El Olivar", "Quilca", "Morales Duarez", "Carmen de la Legua", "Venezuela", "La Alborada", "Universitaria", "La Marina", "Sucre", "Salaverry", "Ugarteche", "San Felipe", "Las Palmeras", "Javier Prado", "Los Frutales", "Mercado Mayorista"]
    var l4 = Linea(numero: 4, nombre: "Linea 4 (Oeste - Este / Aeropuerto)", estado: "En Proyecto", caracteristicas: "Eje Aeropuerto Jorge Chavez - Javier Prado.", estacionesIds: [])
    for nombre in estL4 {
        let id = obtenerOCrearEstacion(nombre: nombre, estadoInicial: "En Proyecto")
        l4.estacionesIds.append(id)
    }
    listaLineas.append(l4)

    // LÍNEA 5
    let estL5 = ["Huaylas", "Matellini", "Barranco", "Larco", "Benavides", "Angamos", "Pardo", "Miraflores Central"]
    var l5 = Linea(numero: 5, nombre: "Linea 5 (Eje Costero)", estado: "En Proyecto", caracteristicas: "Eje Costero Chorrillos - Miraflores.", estacionesIds: [])
    for nombre in estL5 {
        let id = obtenerOCrearEstacion(nombre: nombre, estadoInicial: "En Proyecto")
        l5.estacionesIds.append(id)
    }
    listaLineas.append(l5)

    // LÍNEA 6
    let estL6 = ["Tupac Amaru", "San German", "Morales Duarez", "Venezuela", "La Marina", "Ejercito", "Angamos", "Primavera", "El Polo", "Encalada"]
    var l6 = Linea(numero: 6, nombre: "Linea 6 (Transversal Universitaria / Angamos)", estado: "En Proyecto", caracteristicas: "Eje Transversal Universitaria - Angamos.", estacionesIds: [])
    for nombre in estL6 {
        let id = obtenerOCrearEstacion(nombre: nombre, estadoInicial: "En Proyecto")
        l6.estacionesIds.append(id)
    }
    listaLineas.append(l6)

    reconstruirGrafoYConexiones()
}

// ==========================================
// CAPTURA DE ENTRADAS Y PAUSAS
// ==========================================

func solicitarOpcionNum(minVal: Int, maxVal: Int) -> Int {
    while true {
        print("\n  ► Seleccione opcion [\(minVal)-\(maxVal)]: ", terminator: "")
        if let entrada = readLine(), let numero = Int(entrada), numero >= minVal && numero <= maxVal {
            return numero
        }
        print("  ❌ Entrada invalida. Por favor digite un numero valido.")
    }
}

func solicitarDouble(prompt: String, minVal: Double) -> Double {
    while true {
        print(prompt, terminator: "")
        if let entrada = readLine(), let numero = Double(entrada), numero >= minVal {
            return numero
        }
        print("  ❌ Monto invalido. Intente nuevamente.")
    }
}

func pausarPantalla() {
    print("\n  ► Presione ENTER para continuar...", terminator: "")
    _ = readLine()
}

func seleccionarEstacionPorCatalogo(titulo: String) -> Int {
    cuadroBanner(titulo.uppercased())
    print("  ┌─────┬──────────────────────────────────────────┬──────────────────────┐")
    print("  │ NUM │ LINEA DEL METRO                          │ ESTADO DE LINEA      │")
    print("  ├─────┼──────────────────────────────────────────┼──────────────────────┤")
    for (index, lin) in listaLineas.enumerated() {
        let idStr = String(format: "%2d", index + 1)
        let nombrePad = lin.nombre.padding(toLength: 40, withPad: " ", startingAt: 0)
        let estadoPad = badgeEstado(lin.estado).padding(toLength: 20, withPad: " ", startingAt: 0)
        print("  │ [\(idStr)]│ \(nombrePad) │ \(estadoPad) │")
    }
    print("  └─────┴──────────────────────────────────────────┴──────────────────────┘")

    let lineaOpcion = solicitarOpcionNum(minVal: 1, maxVal: listaLineas.count)
    let lineaSeleccionada = listaLineas[lineaOpcion - 1]

    cuadroBanner("ESTACIONES DE LA LINEA \(lineaSeleccionada.numero)")
    print("  ┌─────┬──────────────────────────────────┬──────────────────────────┐")
    print("  │ N°  │ NOMBRE DE LA ESTACION            │ ESTADO DISPONIBLE        │")
    print("  ├─────┼──────────────────────────────────┼──────────────────────────┤")
    for (index, estId) in lineaSeleccionada.estacionesIds.enumerated() {
        let est = mapaIdAEstacion[estId]
        let numStr = String(format: "%2d", index + 1)
        let nombrePad = (est?.nombre ?? "Desconocido").padding(toLength: 32, withPad: " ", startingAt: 0)
        let estadoPad = badgeEstado(est?.estado ?? "").padding(toLength: 24, withPad: " ", startingAt: 0)
        print("  │ [\(numStr)]│ \(nombrePad) │ \(estadoPad) │")
    }
    print("  └─────┴──────────────────────────────────┴──────────────────────────┘")

    let estacionOpcion = solicitarOpcionNum(minVal: 1, maxVal: lineaSeleccionada.estacionesIds.count)
    return lineaSeleccionada.estacionesIds[estacionOpcion - 1]
}

// ==========================================
// FUNCIONES DEL MENÚ
// ==========================================

// [1] Visualizar las 6 Lineas del Metro (RF1)
func rf1_visualizarLineas() {
    cuadroBanner("RF1: RED BASICA DEL METRO DE LIMA (\(listaLineas.count) LINEAS)")
    for lin in listaLineas {
        print("\n  ╔══════════════════════════════════════════════════════════════════╗")
        print("  ║ LINEA \(String(format: "%2d", lin.numero)) ➔ \(lin.nombre.padding(toLength: 51, withPad: " ", startingAt: 0))║")
        print("  ╠══════════════════════════════════════════════════════════════════╣")
        print("  ║ Estado Actual  : \(badgeEstado(lin.estado).padding(toLength: 47, withPad: " ", startingAt: 0))║")
        print("  ║ Estaciones     : \(String(format: "%-47d", lin.estacionesIds.count))║")
        print("  ║ Descripcion    : \(lin.caracteristicas.padding(toLength: 47, withPad: " ", startingAt: 0))║")
        print("  ╚══════════════════════════════════════════════════════════════════╝")
    }
}

// [2] Consultar Recorrido de una Linea (RF2)
func rf2_consultarRecorridoLinea() {
    cuadroBanner("RF2: RECORRIDO COMPLETO DE UNA LINEA")
    for (index, lin) in listaLineas.enumerated() {
        print("    [\(index + 1)] Linea \(lin.numero) - \(lin.nombre)")
    }
    let opc = solicitarOpcionNum(minVal: 1, maxVal: listaLineas.count)
    let lin = listaLineas[opc - 1]

    cuadroBanner("RECORRIDO: LINEA \(lin.numero)")
    print("  Estado General: \(badgeEstado(lin.estado))\n")
    print("  ┌────┬──────────────────────────────┬──────────────────────────┬─────────────┐")
    print("  │ N° │ ESTACION                     │ ESTADO OPERATIVO         │ TRASBORDO   │")
    print("  ├────┼──────────────────────────────┼──────────────────────────┼─────────────┤")

    for (index, estId) in lin.estacionesIds.enumerated() {
        let est = mapaIdAEstacion[estId]
        let numStr = String(format: "%2d", index + 1)
        let nombrePad = (est?.nombre ?? "").padding(toLength: 28, withPad: " ", startingAt: 0)
        let estadoPad = badgeEstado(est?.estado ?? "").padding(toLength: 24, withPad: " ", startingAt: 0)
        let esCruce = listaConexiones.contains(where: { $0.estacionId == estId }) ? " 🔀 [SI] " : "   --    "
        print("  │ \(numStr) │ \(nombrePad) │ \(estadoPad) │ \(esCruce) │")
    }
    print("  └────┴──────────────────────────────┴──────────────────────────┴─────────────┘")
}

// [3] Buscar Estaciones por Nombre o Catalogo (RF3)
func rf3_buscarEstaciones() {
    cuadroBanner("RF3: BUSCAR ESTACIONES POR NOMBRE O CATALOGO")
    print("  [1] Buscar por Coincidencia de Nombre")
    print("  [2] Explorar por Catalogo de Lineas")
    let modo = solicitarOpcionNum(minVal: 1, maxVal: 2)

    var estIdSeleccionado = -1

    if modo == 1 {
        print("\n  ► Ingrese el nombre o texto a buscar: ", terminator: "")
        guard let texto = readLine(), !texto.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("\n  ❌ Texto no valido.")
            return
        }

        let textoMin = texto.lowercased()
        let coincidencias = listaEstaciones.filter { $0.nombre.lowercased().contains(textoMin) }

        if coincidencias.isEmpty {
            print("\n  ❌ No se encontraron estaciones con el texto '\(texto)'.")
            return
        } else if coincidencias.count == 1 {
            estIdSeleccionado = coincidencias[0].id
        } else {
            print("\n  Se encontraron las siguientes coincidencias:")
            for (index, est) in coincidencias.enumerated() {
                print("    [\(index + 1)] \(est.nombre) (\(badgeEstado(est.estado)))")
            }
            let subOpc = solicitarOpcionNum(minVal: 1, maxVal: coincidencias.count)
            estIdSeleccionado = coincidencias[subOpc - 1].id
        }
    } else {
        estIdSeleccionado = seleccionarEstacionPorCatalogo(titulo: "CATALOGO GENERAL DE ESTACIONES")
    }

    if let est = mapaIdAEstacion[estIdSeleccionado] {
        print("\n  ✅ Estacion encontrada: \(est.nombre) | Estado: \(badgeEstado(est.estado))")
    }
}

// [4] Identificar Lineas de una Estacion (RF4)
func rf4_identificarLineasEstacion() {
    cuadroBanner("RF4: IDENTIFICAR LINEAS DE UNA ESTACION")
    let estId = seleccionarEstacionPorCatalogo(titulo: "SELECCIONAR ESTACION")

    guard let estObj = mapaIdAEstacion[estId] else { return }

    cuadroBanner("FICHA TECNICA: \(estObj.nombre.uppercased())")
    print("  • Estado Operativo Individual : \(badgeEstado(estObj.estado))")
    print("  • Lineas asociadas a esta estacion:")

    var totalLineas = 0
    for lin in listaLineas {
        if lin.estacionesIds.contains(estId) {
            totalLineas += 1
            print("     ✦ Linea \(lin.numero) (\(lin.nombre)) | Estado Linea: \(badgeEstado(lin.estado))")
        }
    }

    if totalLineas > 1 {
        print("\n  ★ CLASIFICACION: ESTACION DE TRASBORDO / CONEXION MULTILINEA")
    } else {
        print("\n  • CLASIFICACION: ESTACION REGULAR (LINEA UNICA)")
    }
}

// [5] Ver Cruces y Conexiones entre Lineas (RF5)
func rf5_visualizarCruces() {
    cuadroBanner("RF5: CRUCES Y PUNTOS DE TRASBORDO")
    print("  Se identificaron \(listaConexiones.count) nodos estrategicos de intercambio:\n")

    print("  ┌────┬──────────────────────┬─────────────────────────────┬───────────────────────────┐")
    print("  │ N° │ ESTACION DE CRUCE    │ LINEAS QUE INTERCONECTA     │ ESTADO DE CONEXION        │")
    print("  ├────┼──────────────────────┼─────────────────────────────┼───────────────────────────┤")

    for (index, con) in listaConexiones.enumerated() {
        let nombreEst = (mapaIdANombre[con.estacionId] ?? "Desconocido").padding(toLength: 20, withPad: " ", startingAt: 0)
        let numFormat = String(format: "%2d", index + 1)
        let lineasStr = con.lineasInvolucradas.sorted().map { "L\($0)" }.joined(separator: " 🔀 ").padding(toLength: 27, withPad: " ", startingAt: 0)
        let estadoStr = con.estadoConexion.padding(toLength: 25, withPad: " ", startingAt: 0)
        
        print("  │ \(numFormat) │ \(nombreEst) │ \(lineasStr) │ \(estadoStr) │")
    }
    print("  └────┴──────────────────────┴─────────────────────────────┴───────────────────────────┘")
}

// [6] Planificar Ruta e Instrucciones de Trasbordo (RF6 & RF7)
func rf6_rf7_planificarRuta() {
    cuadroBanner("RF6 & RF7: PLANIFICACION DE RUTA Y TRASBORDOS")

    let idOrigen = seleccionarEstacionPorCatalogo(titulo: "SELECCIONAR ORIGEN")
    let idDestino = seleccionarEstacionPorCatalogo(titulo: "SELECCIONAR DESTINO")

    if idOrigen == idDestino {
        print("\n  ❌ El origen y el destino son la misma estacion.")
        return
    }

    // Algoritmo BFS para encontrar la ruta
    var cola: [EstadoRuta] = []
    var visitados = Set<String>()

    if let vecinos = grafo[idOrigen] {
        for vecino in vecinos {
            let caminoInicial = [
                (estacionId: idOrigen, numeroLinea: vecino.linea),
                (estacionId: vecino.destinoId, numeroLinea: vecino.linea)
            ]
            cola.append(EstadoRuta(estacionActual: vecino.destinoId, lineaActual: vecino.linea, camino: caminoInicial))
            visitados.insert("\(vecino.destinoId)-\(vecino.linea)")
        }
    }

    var rutaFinal: EstadoRuta? = nil
    while !cola.isEmpty {
        let actual = cola.removeFirst()

        if actual.estacionActual == idDestino {
            rutaFinal = actual
            break
        }

        if let vecinos = grafo[actual.estacionActual] {
            for vecino in vecinos {
                let claveVisitado = "\(vecino.destinoId)-\(vecino.linea)"
                if !visitados.contains(claveVisitado) {
                    visitados.insert(claveVisitado)
                    var nuevoCamino = actual.camino
                    nuevoCamino.append((estacionId: vecino.destinoId, numeroLinea: vecino.linea))
                    cola.append(EstadoRuta(estacionActual: vecino.destinoId, lineaActual: vecino.linea, camino: nuevoCamino))
                }
            }
        }
    }

    guard let ruta = rutaFinal else {
        print("\n  ❌ No se encontro una ruta disponible entre las estaciones seleccionadas.")
        return
    }

    cuadroBanner("INSTRUCCIONES DE HOJA DE RUTA")
    var lineaActual = ruta.camino[0].numeroLinea
    print("  1. Aborde en la Estacion: \(mapaIdANombre[idOrigen] ?? "") (Linea \(lineaActual))")

    for i in 1..<ruta.camino.count {
        let paso = ruta.camino[i]
        let nombreEst = mapaIdANombre[paso.estacionId] ?? ""

        if paso.numeroLinea != lineaActual {
            print("\n  🔀 TRASBORDO: En la Estacion '\(mapaIdANombre[ruta.camino[i-1].estacionId] ?? "")', cambie a la LINEA \(paso.numeroLinea)")
            lineaActual = paso.numeroLinea
        }

        print("     ➔ Avanzar a: \(nombreEst) (Linea \(paso.numeroLinea))")
    }

    print("\n  🏁 Llegada al destino final: \(mapaIdANombre[idDestino] ?? "")")
    print("  Total de estaciones en el trayecto: \(ruta.camino.count - 1) paradas.")
}

// [7] Consultar Estado del Servicio y Disponibilidad (RF8)
func rf8_consultarEstadoServicio() {
    cuadroBanner("RF8: ESTADO DEL SERVICIO Y DISPONIBILIDAD")
    print("  [1] Consultar estado por LINEA")
    print("  [2] Consultar estado por ESTACION")
    let opc = solicitarOpcionNum(minVal: 1, maxVal: 2)

    if opc == 1 {
        print("\n  ESTADO GENERAL DE LAS LINEAS DEL METRO:")
        for lin in listaLineas {
            print("     ✦ Linea \(lin.numero) (\(lin.nombre)): \(badgeEstado(lin.estado))")
        }
    } else {
        let idEst = seleccionarEstacionPorCatalogo(titulo: "SELECCIONAR ESTACION")
        if let est = mapaIdAEstacion[idEst] {
            cuadroBanner("DISPONIBILIDAD: \(est.nombre.uppercased())")
            print("  • Estado Comercial : \(badgeEstado(est.estado))")
            if est.estado == "Operativa" {
                print("  • Acceso           : HABILITADO para uso del publico.")
            } else {
                print("  • Acceso           : NO DISPONIBLE actualmente para abordaje comercial.")
            }
        }
    }
}

// ==========================================
// NUEVO [8]: GESTIÓN DE TARJETA (SUBMENÚ)
// ==========================================

func moduloGestionTarjeta() {
    var opc = -1
    repeat {
        cuadroBanner("MODULO DE TARJETA Y PAGOS")
        print("  • Tarjeta Asociada : \(tarjetaUsuario.id)")
        print("  • Saldo Actual     : S/ \(String(format: "%.2f", tarjetaUsuario.saldo))")
        print("  • Tarifa Base      : S/ \(String(format: "%.2f", tarjetaUsuario.tarifaBase))")
        print("  ────────────────────────────────────────────────────────────────")
        print("  [1] Consultar Saldo de Tarjeta")
        print("  [2] Recargar Saldo de Tarjeta")
        print("  [0] Volver al Menu Principal")

        opc = solicitarOpcionNum(minVal: 0, maxVal: 2)

        switch opc {
        case 1:
            cuadroBanner("CONSULTA DE SALDO")
            print("  💳 Tarjeta N° : \(tarjetaUsuario.id)")
            print("  💰 Saldo     : S/ \(String(format: "%.2f", tarjetaUsuario.saldo)) PEN")
            pausarPantalla()
        case 2:
            cuadroBanner("RECARGA DE SALDO")
            print("  Monto minimo de recarga: S/ 1.00")
            let monto = solicitarDouble(prompt: "  ► Ingrese monto a recargar (S/): ", minVal: 1.00)
            tarjetaUsuario.saldo += monto
            print("\n  ✅ ¡Recarga exitosa! Nuevo saldo disponible: S/ \(String(format: "%.2f", tarjetaUsuario.saldo)) PEN")
            pausarPantalla()
        default:
            break
        }
    } while opc != 0
}

// ==========================================
// NUEVO [9]: MÓDULO DE ADMINISTRACIÓN (INCLUYE DESHABILITAR ESTACIÓN)
// ==========================================

func moduloAdministracionRed() {
    var opc = -1
    repeat {
        cuadroBanner("MODULO DE ADMINISTRACION Y MANTENIMIENTO DE RED")
        print("  [1] Registrar Nueva Estacion Independiente")
        print("  [2] Insertar Estacion Intermedia entre dos Existentes")
        print("  [3] Crear Nueva Linea de Transporte")
        print("  [4] Deshabilitar / Cambiar Estado de una Estacion")
        print("  [0] Volver al Menu Principal")

        opc = solicitarOpcionNum(minVal: 0, maxVal: 4)

        switch opc {
        case 1:
            cuadroBanner("ADMIN: REGISTRAR NUEVA ESTACION")
            print("  ► Ingrese nombre de la nueva estacion: ", terminator: "")
            if let nombre = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines), !nombre.isEmpty {
                let id = obtenerOCrearEstacion(nombre: nombre, estadoInicial: "Operativa")
                print("  ✅ Estacion '\(nombre)' registrada correctamente con ID: \(id)")
            } else {
                print("  ❌ Nombre invalido.")
            }
            pausarPantalla()

        case 2:
            cuadroBanner("ADMIN: INSERTAR ESTACION INTERMEDIA")
            print("  Seleccione la Linea sobre la cual insertar la estacion:")
            for (i, lin) in listaLineas.enumerated() {
                print("    [\(i + 1)] Linea \(lin.numero) - \(lin.nombre)")
            }
            let idxLinea = solicitarOpcionNum(minVal: 1, maxVal: listaLineas.count) - 1
            var lineaSel = listaLineas[idxLinea]

            if lineaSel.estacionesIds.count < 2 {
                print("  ❌ La linea necesita al menos 2 estaciones para insertar una intermedia.")
                pausarPantalla()
                break
            }

            print("\n  Seleccione la estacion ANTERIOR a la posicion de insercion:")
            for (i, id) in lineaSel.estacionesIds.enumerated() {
                print("    [\(i + 1)] \(mapaIdANombre[id] ?? "")")
            }
            let idxEstBase = solicitarOpcionNum(minVal: 1, maxVal: lineaSel.estacionesIds.count - 1) - 1

            print("\n  ► Ingrese el nombre de la NUEVA estacion intermedia: ", terminator: "")
            guard let nombreNvo = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines), !nombreNvo.isEmpty else {
                print("  ❌ Nombre invalido.")
                pausarPantalla()
                break
            }

            let idNueva = obtenerOCrearEstacion(nombre: nombreNvo, estadoInicial: "Operativa")
            lineaSel.estacionesIds.insert(idNueva, at: idxEstBase + 1)
            listaLineas[idxLinea] = lineaSel

            reconstruirGrafoYConexiones()
            print("  ✅ Estacion '\(nombreNvo)' insertada con exito entre '\(mapaIdANombre[lineaSel.estacionesIds[idxEstBase]]!)' y '\(mapaIdANombre[lineaSel.estacionesIds[idxEstBase + 2]]!)'.")
            pausarPantalla()

        case 3:
            cuadroBanner("ADMIN: CREAR NUEVA LINEA DE TRANSPORTE")
            let numNuevaLinea = (listaLineas.map { $0.numero }.max() ?? 0) + 1
            print("  ► Nombre para la Linea \(numNuevaLinea): ", terminator: "")
            let nombreL = readLine() ?? "Linea \(numNuevaLinea)"
            print("  ► Descripcion/Caracteristicas: ", terminator: "")
            let descL = readLine() ?? "Eje de transporte."

            let nuevaL = Linea(numero: numNuevaLinea, nombre: nombreL, estado: "En Proyecto", caracteristicas: descL, estacionesIds: [])
            listaLineas.append(nuevaL)
            reconstruirGrafoYConexiones()

            print("  ✅ Linea \(numNuevaLinea) (\(nombreL)) creada exitosamente.")
            pausarPantalla()

        case 4:
            cuadroBanner("ADMIN: DESHABILITAR / CAMBIAR ESTADO DE ESTACION")
            let idEst = seleccionarEstacionPorCatalogo(titulo: "SELECCIONAR ESTACION A MODIFICAR")
            guard let estActual = mapaIdAEstacion[idEst] else { break }

            print("\n  Estacion Seleccionada : \(estActual.nombre)")
            print("  Estado Actual         : \(badgeEstado(estActual.estado))")
            print("  ────────────────────────────────────────────────────────────────")
            print("  Seleccione el NUEVO estado para la estacion:")
            print("  [1] Operativa (Habilitar)")
            print("  [2] Fuera de Servicio (Deshabilitar / Mantenimiento)")
            print("  [3] En Construccion")
            print("  [4] En Proyecto")

            let subOpc = solicitarOpcionNum(minVal: 1, maxVal: 4)
            var nuevoEstado = "Operativa"

            switch subOpc {
            case 1: nuevoEstado = "Operativa"
            case 2: nuevoEstado = "Fuera de Servicio"
            case 3: nuevoEstado = "En Construccion"
            default: nuevoEstado = "En Proyecto"
            }

            // Actualización persistente en lista y diccionario
            if let index = listaEstaciones.firstIndex(where: { $0.id == idEst }) {
                listaEstaciones[index].estado = nuevoEstado
                mapaIdAEstacion[idEst] = listaEstaciones[index]
            }

            reconstruirGrafoYConexiones()
            print("\n  ✅ ¡Estado actualizado! La estacion '\(estActual.nombre)' ahora esta: \(badgeEstado(nuevoEstado))")
            pausarPantalla()

        default:
            break
        }
    } while opc != 0
}

// ==========================================
// NUEVO [10]: SIMULACIÓN EN TIEMPO REAL
// ==========================================

func moduloSimulacionNavegacion() {
    cuadroBanner("SIMULACION Y NAVEGACION DE VIAJE EN TIEMPO REAL")

    print("\n  --- PASO 1: ORIGEN ---")
    let idOrigen = seleccionarEstacionPorCatalogo(titulo: "SELECCIONAR ORIGEN DE VIAJE")

    print("\n  --- PASO 2: DESTINO ---")
    let idDestino = seleccionarEstacionPorCatalogo(titulo: "SELECCIONAR DESTINO DE VIAJE")

    if idOrigen == idDestino {
        print("\n  ❌ El origen y el destino coinciden. No se requiere viaje.")
        return
    }

    let estOrigen = mapaIdAEstacion[idOrigen]
    let estDestino = mapaIdAEstacion[idDestino]

    if estOrigen?.estado != "Operativa" {
        print("\n  ❌ ERROR: La estacion de origen [\(estOrigen?.nombre ?? "")] no esta Operativa (\(estOrigen?.estado ?? "")).")
        return
    }

    if estDestino?.estado != "Operativa" {
        print("\n  ❌ ERROR: La estacion de destino [\(estDestino?.nombre ?? "")] no esta Operativa (\(estDestino?.estado ?? "")).")
        return
    }

    // Búsqueda de ruta BFS considerando sólo estaciones operativas
    var cola: [EstadoRuta] = []
    var visitados = Set<String>()

    if let vecinos = grafo[idOrigen] {
        for vecino in vecinos {
            let estDestinoVecino = mapaIdAEstacion[vecino.destinoId]
            if estDestinoVecino?.estado != "Operativa" { continue }

            let caminoInicial = [
                (estacionId: idOrigen, numeroLinea: vecino.linea),
                (estacionId: vecino.destinoId, numeroLinea: vecino.linea)
            ]
            cola.append(EstadoRuta(estacionActual: vecino.destinoId, lineaActual: vecino.linea, camino: caminoInicial))
            visitados.insert("\(vecino.destinoId)-\(vecino.linea)")
        }
    }

    var rutaFinal: EstadoRuta? = nil
    while !cola.isEmpty {
        let actual = cola.removeFirst()

        if actual.estacionActual == idDestino {
            rutaFinal = actual
            break
        }

        if let vecinos = grafo[actual.estacionActual] {
            for vecino in vecinos {
                let estDestinoVecino = mapaIdAEstacion[vecino.destinoId]
                if estDestinoVecino?.estado != "Operativa" { continue }

                let claveVisitado = "\(vecino.destinoId)-\(vecino.linea)"
                if !visitados.contains(claveVisitado) {
                    visitados.insert(claveVisitado)
                    var nuevoCamino = actual.camino
                    nuevoCamino.append((estacionId: vecino.destinoId, numeroLinea: vecino.linea))
                    cola.append(EstadoRuta(estacionActual: vecino.destinoId, lineaActual: vecino.linea, camino: nuevoCamino))
                }
            }
        }
    }

    guard let ruta = rutaFinal else {
        print("\n  ❌ No existe una ruta comercial activa conectada entre las estaciones elegidas.")
        return
    }

    // Validación de pago
    cuadroBanner("VALIDACION DE PASAJE Y MOLINETE")
    print("  • Saldo Actual : S/ \(String(format: "%.2f", tarjetaUsuario.saldo)) PEN")
    print("  • Tarifa Viaje : S/ \(String(format: "%.2f", tarjetaUsuario.tarifaBase)) PEN")

    if tarjetaUsuario.saldo < tarjetaUsuario.tarifaBase {
        print("\n  ❌ SALDO INSUFFICIENT. Por favor recargue su tarjeta en la opción [8].")
        return
    }

    tarjetaUsuario.saldo -= tarjetaUsuario.tarifaBase
    print("  ✅ TARIFA DESCONTADA. Saldo restante: S/ \(String(format: "%.2f", tarjetaUsuario.saldo)) PEN")
    print("  🟢 MOLINETE ABIERTO. ¡Buen viaje!")

    // Simulación
    let totalParadas = ruta.camino.count - 1
    var lineaActual = ruta.camino[0].numeroLinea

    for i in 0..<ruta.camino.count {
        let paso = ruta.camino[i]
        let nombreEstacion = mapaIdANombre[paso.estacionId] ?? ""
        let paradasRestantes = totalParadas - i

        cuadroBanner("AVANCE DE VIAJE: ESTACION \(i + 1) DE \(totalParadas + 1)")
        print("  📍 Estacion Actual    : \(nombreEstacion)")
        print("  🚇 Linea              : Linea \(paso.numeroLinea)")
        print("  ⏳ Estaciones Faltantes : \(paradasRestantes) paradas para el destino")

        if i > 0 && paso.numeroLinea != lineaActual {
            print("\n  🔀 [ALERT] TRASBORDO REQUERIDO: Cambie de la Linea \(lineaActual) a la Linea \(paso.numeroLinea).")
            lineaActual = paso.numeroLinea
        }

        let lineasConectadas = listaLineas.filter { $0.estacionesIds.contains(paso.estacionId) }.map { "L\($0.numero)" }
        if lineasConectadas.count > 1 {
            print("  🌐 INTERCONEXIONES DISPONIBLES : Conexión con lineas [ \(lineasConectadas.joined(separator: ", ")) ]")
        }

        if i < ruta.camino.count - 1 {
            print("\n  ► Presione ENTER para avanzar a la siguiente estacion...", terminator: "")
            _ = readLine()
        } else {
            print("\n  🏁 ¡HAS LLEGADO A TU DESTINO!: \(nombreEstacion)")
            print("  ================================================================")
        }
    }
}

// ==========================================
// PROGRAMA PRINCIPAL (MENÚ INTERACTIVO)
// ==========================================

func menuPrincipal() {
    cargarDatosMetro()
    var opcion = -1

    repeat {
        cuadroBanner("METRO DE LIMA Y CALLAO - SISTEMA DE RUTAS (SWIFT)")
        print("  [1] Visualizar las 6 Lineas del Metro (RF1)")
        print("  [2] Consultar Recorrido de una Linea (RF2)")
        print("  [3] Buscar Estaciones por Nombre o Catalogo (RF3)")
        print("  [4] Identificar Lineas de una Estacion (RF4)")
        print("  [5] Ver Cruces y Conexiones entre Lineas (RF5)")
        print("  [6] Planificar Ruta e Instrucciones de Trasbordo (RF6 & RF7)")
        print("  [7] Consultar Estado del Servicio y Disponibilidad (RF8)")
        print("  ────────────────────────────────────────────────────────────────")
        print("  [8] Modulo de Tarjeta (Saldo y Recargas)")
        print("  [9] Modulo de Administracion y Mantenimiento de Red")
        print(" [10] Simulacion y Navegacion de Viaje en Tiempo Real")
        print("  ────────────────────────────────────────────────────────────────")
        print("  [0] Salir del Sistema")
        print("  ────────────────────────────────────────────────────────────────")

        opcion = solicitarOpcionNum(minVal: 0, maxVal: 10)

        switch opcion {
        case 1:
            rf1_visualizarLineas()
        case 2:
            rf2_consultarRecorridoLinea()
        case 3:
            rf3_buscarEstaciones()
        case 4:
            rf4_identificarLineasEstacion()
        case 5:
            rf5_visualizarCruces()
        case 6:
            rf6_rf7_planificarRuta()
        case 7:
            rf8_consultarEstadoServicio()
        case 8:
            moduloGestionTarjeta()
        case 9:
            moduloAdministracionRed()
        case 10:
            moduloSimulacionNavegacion()
        case 0:
            print("\n  ¡Gracias por usar el Sistema del Metro de Lima y Callao! Hasta pronto.\n")
        default:
            print("\n  ❌ Opcion invalida.")
        }

        if opcion != 0 && opcion != 8 && opcion != 9 {
            pausarPantalla()
        }

    } while opcion != 0
}

// Ejecución del programa
menuPrincipal()
