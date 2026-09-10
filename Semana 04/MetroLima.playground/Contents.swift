import Foundation

// ==========================================
// ESTRUCTURAS DE DATOS (STRUCTS)
// ==========================================

struct Estacion: Hashable {
    let id: Int
    let nombre: String
    var estado: String // Operativa, En Construccion, En Proyecto
}

struct Linea {
    let numero: Int
    let nombre: String
    let estado: String // Operativa, Parcialmente Operativa, En Proyecto
    let caracteristicas: String
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

// ==========================================
// COLECCIONES Y GRAFO PRINCIPAL
// ==========================================

var listaEstaciones: [Estacion] = []
var mapaIdANombre: [Int: String] = [:]
var mapaNombreAId: [String: Int] = [:]
var mapaIdAEstacion: [Int: Estacion] = [:]
var listaLineas: [Linea] = []
var listaConexiones: [Conexion] = []

// Grafo: [IdEstacionOrigen: [(IdEstacionDestino, NumeroLinea)]]
var grafo: [Int: [(destinoId: Int, linea: Int)]] = [:]

// ==========================================
// DISEÑO VISUAL Y TABLAS CON BORDES UNICODE
// ==========================================

func badgeEstado(_ estado: String) -> String {
    switch estado {
    case "Operativa":
        return "🟢 [OPERATIVA]   "
    case "Parcialmente Operativa":
        return "🟡 [PARCIAL OPER]"
    case "En Construccion":
        return "🟠 [EN OBRAS]    "
    default:
        return "🔴 [PROYECTO]    "
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

// ==========================================
// CARGA DE DATOS DEL METRO DE LIMA
// ==========================================

func cargarDatosMetro() {
    listaEstaciones.removeAll()
    mapaIdANombre.removeAll()
    mapaNombreAId.removeAll()
    mapaIdAEstacion.removeAll()
    listaLineas.removeAll()
    listaConexiones.removeAll()
    grafo.removeAll()

    // LÍNEA 1
    let estL1 = [
        "Villa El Salvador", "Parque Industrial", "Pumacahua", "Villa Maria", 
        "Maria Auxiliadora", "San Juan", "Atocongo", "Jorge Chavez", "Ayacucho", 
        "Cabitos", "Angamos", "San Borja Sur", "La Cultura", "Arriola", 
        "Gamarra", "28 de Julio", "Miguel Grau", "El Angel", "Presbitero Maestro", "Caja de Agua", 
        "Piramide del Sol", "Los Jardines", "Los Postes", "San Carlos", 
        "San Martin", "Santa Rosa", "Bayovar"
    ]
    var l1 = Linea(numero: 1, nombre: "Linea 1 (Sur - Este)", estado: "Operativa", caracteristicas: "Via elevada de Villa El Salvador a SJL.", estacionesIds: [])
    for (i, nombre) in estL1.enumerated() {
        let id = obtenerOCrearEstacion(nombre: nombre, estadoInicial: "Operativa")
        l1.estacionesIds.append(id)
        if i > 0 {
            let idAnt = l1.estacionesIds[i - 1]
            grafo[idAnt, default: []].append((destinoId: id, linea: 1))
            grafo[id, default: []].append((destinoId: idAnt, linea: 1))
        }
    }
    listaLineas.append(l1)

    // LÍNEA 2
    let estL2Operativas = Set(["Evitamiento", "Ovalo Santa Anita", "Colectora Industrial", "Hermilio Valdizan", "Mercado Santa Anita"])
    let estL2 = [
        "Puerto del Callao", "Buenos Aires", "Juan Pablo II", "Insurgentes", 
        "Carmen de la Legua", "Oscar Benavides", "San Jose", "Dique Bellavista", 
        "Tingo Maria", "Parque Murillo", "Plaza Bolognesi", "Estacion Central", 
        "Manco Capac", "Cangallo", "28 de Julio", "Nicolas Ayllon", "Yerbateros", 
        "Circunvalacion", "San Juan de Dios", "Evitamiento", "Ovalo Santa Anita", 
        "Colectora Industrial", "Hermilio Valdizan", "Mercado Santa Anita", 
        "Vista Alegre", "Prolongacion Javier Prado", "Municipalidad de Ate"
    ]
    var l2 = Linea(numero: 2, nombre: "Linea 2 (Oeste - Este)", estado: "Parcialmente Operativa", caracteristicas: "Corredor subterraneo Callao - Ate.", estacionesIds: [])
    for (i, nombre) in estL2.enumerated() {
        let estadoEst = estL2Operativas.contains(nombre) ? "Operativa" : "En Construccion"
        let id = obtenerOCrearEstacion(nombre: nombre, estadoInicial: estadoEst)
        l2.estacionesIds.append(id)
        if i > 0 {
            let idAnt = l2.estacionesIds[i - 1]
            grafo[idAnt, default: []].append((destinoId: id, linea: 2))
            grafo[id, default: []].append((destinoId: idAnt, linea: 2))
        }
    }
    listaLineas.append(l2)

    // LÍNEA 3
    let estL3 = [
        "El Alamo", "Huandoy", "Universidad", "Naranjal", "Izaguirre", 
        "Tomas Valle", "Bartholome de las Casas", "Jose Granda", "Caqueta", 
        "Plaza Acho", "Tacna", "Garcilaso de la Vega", "Estacion Central", 
        "Parque Universitario", "Exposicion", "Pardo de Zela", "Mexico", 
        "Canada", "Javier Prado", "Guardia Civil", "Republica de Panama", 
        "Benavides", "Cabitos", "Higuereta", "Tomas Marsano", "Primavera", "Pedro Miotta"
    ]
    var l3 = Linea(numero: 3, nombre: "Linea 3 (Norte - Sur)", estado: "En Proyecto", caracteristicas: "Eje Comas - Miraflores - Surco.", estacionesIds: [])
    for (i, nombre) in estL3.enumerated() {
        let id = obtenerOCrearEstacion(nombre: nombre, estadoInicial: "En Proyecto")
        l3.estacionesIds.append(id)
        if i > 0 {
            let idAnt = l3.estacionesIds[i - 1]
            grafo[idAnt, default: []].append((destinoId: id, linea: 3))
            grafo[id, default: []].append((destinoId: idAnt, linea: 3))
        }
    }
    listaLineas.append(l3)

    // LÍNEA 4
    let estL4 = [
        "Gambetta", "Canta Callao", "Bocanegra", "Aeropuerto", "El Olivar", 
        "Quilca", "Morales Duarez", "Carmen de la Legua", "Venezuela", 
        "La Alborada", "Universitaria", "La Marina", "Sucre", "Salaverry", 
        "Ugarteche", "San Felipe", "Las Palmeras", "Javier Prado", 
        "Los Frutales", "Mercado Mayorista"
    ]
    var l4 = Linea(numero: 4, nombre: "Linea 4 (Oeste - Este / Aeropuerto)", estado: "En Proyecto", caracteristicas: "Eje Aeropuerto Jorge Chavez - Javier Prado.", estacionesIds: [])
    for (i, nombre) in estL4.enumerated() {
        let id = obtenerOCrearEstacion(nombre: nombre, estadoInicial: "En Proyecto")
        l4.estacionesIds.append(id)
        if i > 0 {
            let idAnt = l4.estacionesIds[i - 1]
            grafo[idAnt, default: []].append((destinoId: id, linea: 4))
            grafo[id, default: []].append((destinoId: idAnt, linea: 4))
        }
    }
    listaLineas.append(l4)

    // LÍNEA 5
    let estL5 = [
        "Huaylas", "Matellini", "Barranco", "Larco", "Benavides", 
        "Angamos", "Pardo", "Miraflores Central"
    ]
    var l5 = Linea(numero: 5, nombre: "Linea 5 (Eje Costero)", estado: "En Proyecto", caracteristicas: "Eje Costero Chorrillos - Miraflores.", estacionesIds: [])
    for (i, nombre) in estL5.enumerated() {
        let id = obtenerOCrearEstacion(nombre: nombre, estadoInicial: "En Proyecto")
        l5.estacionesIds.append(id)
        if i > 0 {
            let idAnt = l5.estacionesIds[i - 1]
            grafo[idAnt, default: []].append((destinoId: id, linea: 5))
            grafo[id, default: []].append((destinoId: idAnt, linea: 5))
        }
    }
    listaLineas.append(l5)

    // LÍNEA 6
    let estL6 = [
        "Tupac Amaru", "San German", "Morales Duarez", "Venezuela", 
        "La Marina", "Ejercito", "Angamos", "Primavera", "El Polo", "Encalada"
    ]
    var l6 = Linea(numero: 6, nombre: "Linea 6 (Transversal Universitaria / Angamos)", estado: "En Proyecto", caracteristicas: "Eje Transversal Universitaria - Angamos.", estacionesIds: [])
    for (i, nombre) in estL6.enumerated() {
        let id = obtenerOCrearEstacion(nombre: nombre, estadoInicial: "En Proyecto")
        l6.estacionesIds.append(id)
        if i > 0 {
            let idAnt = l6.estacionesIds[i - 1]
            grafo[idAnt, default: []].append((destinoId: id, linea: 6))
            grafo[id, default: []].append((destinoId: idAnt, linea: 6))
        }
    }
    listaLineas.append(l6)

    // GENERAR CONEXIONES
    for est in listaEstaciones {
        var lineasAsociadas = Set<Int>()
        for lin in listaLineas {
            if lin.estacionesIds.contains(est.id) {
                lineasAsociadas.insert(lin.numero)
            }
        }
        
        if lineasAsociadas.count > 1 {
            var estConexion = "Proyecto Futuro / Red Basica"
            if lineasAsociadas.contains(1) && lineasAsociadas.contains(2) {
                estConexion = "En Construccion (Intercambio 28 de Julio)"
            } else if lineasAsociadas.contains(2) && lineasAsociadas.contains(4) {
                estConexion = "En Licitacion (Ramal Av. Faucett)"
            }
            listaConexiones.append(Conexion(estacionId: est.id, lineasInvolucradas: lineasAsociadas, estadoConexion: estConexion))
        }
    }
}

// ==========================================
// COMPONENTES DE LECTURA Y CATALOGOS MEJORADOS
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

func seleccionarEstacionPorCatalogo(titulo: String) -> Int {
    cuadroBanner(titulo.uppercased())
    print("  ┌─────┬──────────────────────────────────────────┬──────────────────┐")
    print("  │ NUM │ LINEA DEL METRO                          │ ESTADO DE LINEA  │")
    print("  ├─────┼──────────────────────────────────────────┼──────────────────┤")
    for (index, lin) in listaLineas.enumerated() {
        let idStr = String(format: "%2d", index + 1)
        let nombrePad = lin.nombre.padding(toLength: 40, withPad: " ", startingAt: 0)
        let estadoPad = badgeEstado(lin.estado).padding(toLength: 16, withPad: " ", startingAt: 0)
        print("  │ [\(idStr)]│ \(nombrePad) │ \(estadoPad) │")
    }
    print("  └─────┴──────────────────────────────────────────┴──────────────────┘")

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

func pausarPantalla() {
    print("\n  ► Presione ENTER para continuar...", terminator: "")
    _ = readLine()
}

// ==========================================
// MODULOS DE REQUERIMIENTOS FUNCIONALES
// ==========================================

func rf1_visualizarLineas() {
    cuadroBanner("RF1: RED BASICA DEL METRO DE LIMA (6 LINEAS)")
    for lin in listaLineas {
        print("\n  ╔══════════════════════════════════════════════════════════════════╗")
        print("  ║ LINEA \(lin.numero) ➔ \(lin.nombre.padding(toLength: 53, withPad: " ", startingAt: 0))║")
        print("  ╠══════════════════════════════════════════════════════════════════╣")
        print("  ║ Estado Actual  : \(badgeEstado(lin.estado).padding(toLength: 47, withPad: " ", startingAt: 0))║")
        print("  ║ Estaciones     : \(String(format: "%-47d", lin.estacionesIds.count))║")
        print("  ║ Descripcion    : \(lin.caracteristicas.padding(toLength: 47, withPad: " ", startingAt: 0))║")
        print("  ╚══════════════════════════════════════════════════════════════════╝")
    }
}

func rf2_consultarRecorridoLinea() {
    cuadroBanner("RF2: RECORRIDO COMPLETO DE UNA LINEA")
    print("  Seleccione la linea a consultar:")
    for (index, lin) in listaLineas.enumerated() {
        print("    [\(index + 1)] Linea \(lin.numero) - \(lin.nombre)")
    }
    let opc = solicitarOpcionNum(minVal: 1, maxVal: listaLineas.count)
    let lin = listaLineas[opc - 1]

    cuadroBanner("RECORRIDO: LINEA \(lin.numero)")
    print("  Estado General: \(badgeEstado(lin.estado))\n")
    print("  ┌────┬──────────────────────────────┬──────────────────────┬─────────────┐")
    print("  │ N° │ ESTACION                     │ ESTADO OPERATIVO     │ TRASBORDO   │")
    print("  ├────┼──────────────────────────────┼──────────────────────┼─────────────┤")

    for (index, estId) in lin.estacionesIds.enumerated() {
        let est = mapaIdAEstacion[estId]
        let numStr = String(format: "%2d", index + 1)
        let nombrePad = (est?.nombre ?? "").padding(toLength: 28, withPad: " ", startingAt: 0)
        let estadoPad = badgeEstado(est?.estado ?? "").padding(toLength: 20, withPad: " ", startingAt: 0)
        let esCruce = listaConexiones.contains(where: { $0.estacionId == estId }) ? " 🔀 [SI] " : "  --    "
        print("  │ \(numStr) │ \(nombrePad) │ \(estadoPad) │ \(esCruce) │")
    }
    print("  └────┴──────────────────────────────┴──────────────────────┴─────────────┘")
}

func rf3_rf4_buscarEIdentificarEstacion() {
    cuadroBanner("RF3 & RF4: BUSCAR E IDENTIFICAR ESTACION")
    print("  [1] Seleccionar mediante Catalogo por Lineas")
    print("  [2] Buscar por Coincidencia de Texto (Nombre)")
    let modo = solicitarOpcionNum(minVal: 1, maxVal: 2)

    var estIdSeleccionado = -1

    if modo == 1 {
        estIdSeleccionado = seleccionarEstacionPorCatalogo(titulo: "CATALOGO DE ESTACIONES")
    } else {
        print("\n  ► Ingrese el texto a buscar: ", terminator: "")
        guard let texto = readLine(), !texto.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("\n  ❌ Texto no valido.")
            return
        }

        let textoMin = texto.lowercased()
        let coincidencias = listaEstaciones.filter { $0.nombre.lowercased().contains(textoMin) }

        if coincidencias.isEmpty {
            print("\n  ❌ No se encontraron estaciones que contengan '\(texto)'.")
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
    }

    let estObj = mapaIdAEstacion[estIdSeleccionado]
    let nombreEst = estObj?.nombre ?? "Desconocido"
    let estadoEst = estObj?.estado ?? "Desconocido"

    cuadroBanner("FICHA TECNICA: \(nombreEst.uppercased())")
    print("  • Estado Operativo Individual : \(badgeEstado(estadoEst))")
    print("  • Lineas asociadas a esta estacion:")

    var totalLineas = 0
    for lin in listaLineas {
        if lin.estacionesIds.contains(estIdSeleccionado) {
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

func rf8_consultarEstadoServicio() {
    cuadroBanner("RF8: ESTADO DEL SERVICIO Y DISPONIBILIDAD")
    print("  [1] Consultar estado por LINEA")
    print("  [2] Consultar estado por ESTACION")
    let opc = solicitarOpcionNum(minVal: 1, maxVal: 2)

    if opc == 1 {
        print("\n  ESTADO GENERAL DE LAS LINEAS DEL METRO:")
        for lin in listaLineas {
            print("   ✦ Linea \(lin.numero) (\(lin.nombre)): \(badgeEstado(lin.estado))")
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

func rf6_rf7_planificarRuta() {
    cuadroBanner("RF6 & RF7: PLANIFICADOR DE RUTAS Y TRASBORDOS")
    
    print("\n  SELECCIONE MODO DE RUTA:")
    print("  [1] Solo Tramos OPERATIVOS ACTUALMENTE (Ruta Comercial Activa)")
    print("  [2] Red Completa (Incluye Proyectos Futuros)")
    let modoRuta = solicitarOpcionNum(minVal: 1, maxVal: 2)
    let soloOperativas = (modoRuta == 1)

    print("\n  --- PASO 1: ORIGEN ---")
    let idOrigen = seleccionarEstacionPorCatalogo(titulo: "SELECCIONAR ORIGEN")

    print("\n  --- PASO 2: DESTINO ---")
    let idDestino = seleccionarEstacionPorCatalogo(titulo: "SELECCIONAR DESTINO")

    if idOrigen == idDestino {
        print("\n  ❌ El origen y el destino coinciden. No se requiere viaje.")
        return
    }

    if soloOperativas {
        let estOrigen = mapaIdAEstacion[idOrigen]
        let estDestino = mapaIdAEstacion[idDestino]

        if estOrigen?.estado != "Operativa" {
            print("\n  ❌ ERROR: La estacion de origen [\(estOrigen?.nombre ?? "")] no esta disponible.")
            return
        }

        if estDestino?.estado != "Operativa" {
            print("\n  ❌ ERROR: La estacion de destino [\(estDestino?.nombre ?? "")] no esta disponible.")
            return
        }
    }

    // Algoritmo BFS
    var cola: [EstadoRuta] = []
    var visitados = Set<String>()

    if let vecinos = grafo[idOrigen] {
        for vecino in vecinos {
            let estDestinoVecino = mapaIdAEstacion[vecino.destinoId]
            if soloOperativas && estDestinoVecino?.estado != "Operativa" { continue }

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
                if soloOperativas && estDestinoVecino?.estado != "Operativa" { continue }

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
        print("\n  ❌ No existe una ruta comercial activa para las estaciones seleccionadas.")
        return
    }

    let nombreOrigen = mapaIdANombre[idOrigen] ?? ""
    let nombreDestino = mapaIdANombre[idDestino] ?? ""

    cuadroBanner("RESUMEN DE RUTA Y TRASBORDOS")
    print("  • Modo de Viaje   : \(soloOperativas ? "COMERCIAL (Solo Operativas)" : "RED COMPLETA")")
    print("  • Origen          : \(nombreOrigen)")
    print("  • Destino         : \(nombreDestino)")
    print("  • Paradas Totales : \(ruta.camino.count - 1) estaciones")

    print("\n  ---------------- INSTRUCCIONES PASO A PASO ----------------")

    var lineaActual = ruta.camino[0].numeroLinea
    var numTrasbordos = 0

    let primerEstNombre = mapaIdANombre[ruta.camino[0].estacionId] ?? ""
    print("\n  1. Aborde en [\(primerEstNombre)] tomando la LINEA \(lineaActual).")

    for i in 1..<ruta.camino.count {
        let estId = ruta.camino[i].estacionId
        let linSegmento = ruta.camino[i].numeroLinea
        let estNombre = mapaIdANombre[estId] ?? ""

        if linSegmento != lineaActual {
            numTrasbordos += 1
            let estacionTrasbordo = mapaIdANombre[ruta.camino[i-1].estacionId] ?? ""
            print("\n  ╔════════════════════════════════════════════════════════════════╗")
            print("  ║ 🔀 TRASBORDO N°\(numTrasbordos) EN ESTACION: \(estacionTrasbordo.padding(toLength: 30, withPad: " ", startingAt: 0))║")
            print("  ║    Baje de la LINEA \(lineaActual) y cambie a la LINEA \(linSegmento).        ║")
            print("  ╚════════════════════════════════════════════════════════════════╝\n")
            lineaActual = linSegmento
        }

        print("     ↓ Estacion: \(estNombre) (Linea \(lineaActual))")
    }

    print("\n  ================================================================")
    print("  🏁 LLEGADA AL DESTINO: \(nombreDestino)")
    print("  Total Trasbordos Requeridos: \(numTrasbordos)")
    print("  ================================================================")
}

// ==========================================
// PROGRAMA PRINCIPAL (MENU INTERACTIVO)
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
        print("  [0] Salir del Sistema")
        print("  ────────────────────────────────────────────────────────────────")

        opcion = solicitarOpcionNum(minVal: 0, maxVal: 7)

        switch opcion {
        case 1:
            rf1_visualizarLineas()
        case 2:
            rf2_consultarRecorridoLinea()
        case 3, 4:
            rf3_rf4_buscarEIdentificarEstacion()
        case 5:
            rf5_visualizarCruces()
        case 6:
            rf6_rf7_planificarRuta()
        case 7:
            rf8_consultarEstadoServicio()
        case 0:
            print("\n  ¡Gracias por usar el Sistema de Rutas del Metro de Lima! Hasta pronto.\n")
        default:
            print("\n  ❌ Opcion invalida.")
        }

        if opcion != 0 {
            pausarPantalla()
        }

    } while opcion != 0
}

// Ejecución
menuPrincipal()