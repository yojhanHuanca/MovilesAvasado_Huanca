import Foundation

enum SistemaPension: String, CaseIterable, Identifiable {
    case onp = "ONP"
    case afp = "AFP"

    var id: String { rawValue }
}

enum TipoComisionAFP: String, CaseIterable, Identifiable {
    case flujo = "Sobre remuneración"
    case saldo = "Sobre saldo"

    var id: String { rawValue }
}

struct TasasAFP {
    let fondo: Double
    let comisionFlujo: Double
    let comisionSaldoAnual: Double
    let seguro: Double
    let topeSeguro: Double
}

struct DatosBoleta {
    let sueldoBasico: Double
    let diasLaborados: Int
    let tieneHijos: Bool
    let sistemaPension: SistemaPension
    let afp: String
    let tipoComisionAFP: TipoComisionAFP
    let horas25: Double
    let horas35: Double
    let adelantos: Double
}

struct ConceptoBoleta: Identifiable {
    let nombre: String
    let monto: Double

    var id: String { nombre }
}

struct ResultadoBoleta {
    let remuneraciones: [ConceptoBoleta]
    let descuentos: [ConceptoBoleta]
    let aportaciones: [ConceptoBoleta]
    let totalRemuneraciones: Double
    let totalDescuentos: Double
    let netoPagar: Double
}

enum ErrorCalculoBoleta: LocalizedError {
    case datosInvalidos
    case faltaTasaAFP(String)

    var errorDescription: String? {
        switch self {
        case .datosInvalidos:
            return "Revisa los datos: sueldo mayor que cero, días entre 1 y 30 y otros montos sin valores negativos."
        case .faltaTasaAFP(let afp):
            return "No hay tasas configuradas para \(afp)."
        }
    }
}

final class Boleta {
    // Parámetros consultados el 26/10/2026. La comisión sobre saldo se cobra
    // sobre el fondo acumulado, no como retención de la remuneración mensual.
    static let rmv = 1_230.00
    static let tasaONP = 0.13
    static let tasaEsSalud = 0.09
    static let fechaConsultaParametros = "26 de octubre de 2026"
    static let fuenteAFP = "SBS — Comisiones y primas del SPP"
    static let fuenteAportes = "SUNAT — Aportes a ONP y EsSalud"
    static let fuenteRMV = "SUNAT — Remuneración mínima vital"
    static let tasaAFP = 0.10
    static let tasaSeguroAFP = 0.0137
    static let topeSeguroAFP = 12_732.70

    static let tasasAFP: [String: TasasAFP] = [
        "AFP Habitat": TasasAFP(fondo: tasaAFP, comisionFlujo: 0.0147, comisionSaldoAnual: 0.0125, seguro: tasaSeguroAFP, topeSeguro: topeSeguroAFP),
        "AFP Integra": TasasAFP(fondo: tasaAFP, comisionFlujo: 0.0155, comisionSaldoAnual: 0.0078, seguro: tasaSeguroAFP, topeSeguro: topeSeguroAFP),
        "Prima AFP": TasasAFP(fondo: tasaAFP, comisionFlujo: 0.0160, comisionSaldoAnual: 0.0125, seguro: tasaSeguroAFP, topeSeguro: topeSeguroAFP),
        "Profuturo AFP": TasasAFP(fondo: tasaAFP, comisionFlujo: 0.0169, comisionSaldoAnual: 0.0068, seguro: tasaSeguroAFP, topeSeguro: topeSeguroAFP)
    ]

    private func redondear(_ monto: Double) -> Double {
        var valor = Decimal(monto)
        var resultado = Decimal()
        NSDecimalRound(&resultado, &valor, 2, .plain)
        return NSDecimalNumber(decimal: resultado).doubleValue
    }

    func calcular(_ datos: DatosBoleta) throws -> ResultadoBoleta {
        guard datos.sueldoBasico.isFinite, datos.sueldoBasico > 0,
              (1...30).contains(datos.diasLaborados),
              datos.horas25.isFinite, datos.horas25 >= 0,
              datos.horas35.isFinite, datos.horas35 >= 0,
              datos.adelantos.isFinite, datos.adelantos >= 0 else {
            throw ErrorCalculoBoleta.datosInvalidos
        }

        let sueldoComputable = redondear(datos.sueldoBasico / 30 * Double(datos.diasLaborados))
        let asignacionFamiliar = redondear(datos.tieneHijos ? Self.rmv * 0.10 : 0)

        // La remuneración ordinaria para horas extra incluye la asignación familiar.
        let remuneracionOrdinaria = datos.sueldoBasico + asignacionFamiliar
        let valorHora = remuneracionOrdinaria / 30 / 8
        let horas25 = redondear(valorHora * 1.25 * datos.horas25)
        let horas35 = redondear(valorHora * 1.35 * datos.horas35)

        let remuneraciones = [
            ConceptoBoleta(nombre: "Sueldo computable", monto: sueldoComputable),
            ConceptoBoleta(nombre: "Asignación familiar", monto: asignacionFamiliar),
            ConceptoBoleta(nombre: "Horas extras 25%", monto: horas25),
            ConceptoBoleta(nombre: "Horas extras 35%", monto: horas35)
        ]
        let totalRemuneraciones = redondear(remuneraciones.reduce(0) { $0 + $1.monto })

        var descuentos: [ConceptoBoleta] = []
        switch datos.sistemaPension {
        case .onp:
            descuentos.append(ConceptoBoleta(
                nombre: "ONP (13%)",
                monto: redondear(totalRemuneraciones * Self.tasaONP)
            ))
            descuentos.append(ConceptoBoleta(nombre: "Aporte AFP al fondo", monto: 0))
            descuentos.append(ConceptoBoleta(nombre: "Comisión AFP", monto: 0))
            descuentos.append(ConceptoBoleta(nombre: "Seguro AFP", monto: 0))
        case .afp:
            guard let tasas = Self.tasasAFP[datos.afp] else {
                throw ErrorCalculoBoleta.faltaTasaAFP(datos.afp)
            }
            let comision = datos.tipoComisionAFP == .flujo
                ? redondear(totalRemuneraciones * tasas.comisionFlujo)
                : 0
            let baseSeguro = min(totalRemuneraciones, tasas.topeSeguro)
            descuentos.append(ConceptoBoleta(nombre: "ONP", monto: 0))
            descuentos.append(ConceptoBoleta(
                nombre: "Aporte AFP al fondo (10%)",
                monto: redondear(totalRemuneraciones * tasas.fondo)
            ))
            descuentos.append(ConceptoBoleta(
                nombre: datos.tipoComisionAFP == .flujo
                    ? "Comisión AFP sobre remuneración"
                    : "Comisión AFP sobre saldo (no retenida)",
                monto: comision
            ))
            descuentos.append(ConceptoBoleta(
                nombre: "Seguro AFP (1.37%)",
                monto: redondear(baseSeguro * tasas.seguro)
            ))
        }
        descuentos.append(ConceptoBoleta(nombre: "Adelantos", monto: redondear(datos.adelantos)))

        let totalDescuentos = redondear(descuentos.reduce(0) { $0 + $1.monto })
        let netoPagar = redondear(totalRemuneraciones - totalDescuentos)
        // SUNAT indica que la base mínima mensual de EsSalud es la RMV,
        // independientemente de las horas y días laborados. No se modelan subsidios.
        let baseEsSalud = max(totalRemuneraciones, Self.rmv)
        let aportaciones = [
            ConceptoBoleta(
                nombre: "EsSalud (9% sobre base S/ \(String(format: "%.2f", baseEsSalud)))",
                monto: redondear(baseEsSalud * Self.tasaEsSalud)
            )
        ]

        return ResultadoBoleta(
            remuneraciones: remuneraciones,
            descuentos: descuentos,
            aportaciones: aportaciones,
            totalRemuneraciones: totalRemuneraciones,
            totalDescuentos: totalDescuentos,
            netoPagar: netoPagar
        )
    }
}
