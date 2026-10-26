import SwiftUI

struct ContentView: View {
    @State private var sueldoTexto = ""
    @State private var diasTexto = "30"
    @State private var horas25Texto = "0"
    @State private var horas35Texto = "0"
    @State private var adelantoTexto = "0"
    @State private var tieneHijos = false
    @State private var sistemaPension: SistemaPension = .onp
    @State private var afpSeleccionada = "AFP Habitat"
    @State private var tipoComisionAFP: TipoComisionAFP = .flujo
    @State private var resultado: ResultadoBoleta?
    @State private var mensajeError: String?

    private let calculadora = Boleta()
    private let tinta = Color.primary
    private let tintaEncabezado = Color(red: 0.10, green: 0.19, blue: 0.28)
    private let acento = Color(red: 0.06, green: 0.48, blue: 0.43)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                encabezado

                tarjeta("Datos del trabajador", icono: "person.text.rectangle") {
                    campo("Sueldo básico", detalle: "Monto mensual", texto: $sueldoTexto, decimal: true, sufijo: "S/")
                    separador
                    campo("Días laborados", detalle: "Del 1 al 30", texto: $diasTexto, sufijo: "días")
                    separador
                    VStack(alignment: .leading, spacing: 9) {
                        Text("¿Tiene hijos?")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(tinta)
                        Picker("¿Tiene hijos?", selection: $tieneHijos) {
                            Text("No").tag(false)
                            Text("Sí").tag(true)
                        }
                        .pickerStyle(.segmented)
                    }
                    separador
                    VStack(alignment: .leading, spacing: 9) {
                        Text("Sistema de pensiones")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(tinta)
                        Picker("Sistema de pensiones", selection: $sistemaPension) {
                            ForEach(SistemaPension.allCases) { sistema in
                                Text(sistema.rawValue).tag(sistema)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    if sistemaPension == .afp {
                        separador
                        Picker("Administradora", selection: $afpSeleccionada) {
                            ForEach(Array(Boleta.tasasAFP.keys.sorted()), id: \.self) { afp in
                                Text(afp).tag(afp)
                            }
                        }
                        .tint(acento)

                        Picker("Tipo de comisión", selection: $tipoComisionAFP) {
                            ForEach(TipoComisionAFP.allCases) { tipo in
                                Text(tipo.rawValue).tag(tipo)
                            }
                        }
                        .tint(acento)

                        if let tasas = Boleta.tasasAFP[afpSeleccionada] {
                            Text(detalleTasas(tasas))
                                .font(.caption)
                                .lineSpacing(3)
                                .foregroundStyle(.secondary)
                        }

                        Text("Tasas del SPP vigentes para octubre de 2026, según SBS.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                tarjeta("Otros conceptos", icono: "clock.badge.checkmark") {
                    campo("Horas extras al 25%", detalle: "Primeras horas extra", texto: $horas25Texto, decimal: true, sufijo: "h")
                    separador
                    campo("Horas extras al 35%", detalle: "Horas siguientes", texto: $horas35Texto, decimal: true, sufijo: "h")
                    separador
                    campo("Adelantos", detalle: "Se descuentan del neto", texto: $adelantoTexto, decimal: true, sufijo: "S/")
                }

                Button(action: calcular) {
                    HStack(spacing: 10) {
                        Image(systemName: "calculator.fill")
                        Text("Calcular boleta")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [acento, Color(red: 0.04, green: 0.36, blue: 0.39)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
                }
                .buttonStyle(.plain)

                if let mensajeError {
                    Label(mensajeError, systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                        .accessibilityLabel("Error: \(mensajeError)")
                }

                if let resultado {
                    vistaBoleta(resultado)
                }

                Text("Parámetros consultados el \(Boleta.fechaConsultaParametros). \(Boleta.fuenteAFP); \(Boleta.fuenteAportes); RMV: \(Boleta.fuenteRMV).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
                Text("El cálculo no incluye retención de renta de quinta categoría.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
    }

    private var encabezado: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "doc.text.fill")
                Text("GESTIÓN DE PLANILLAS")
                    .tracking(1.2)
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(.white.opacity(0.78))

            Text("Calcula tu\nboleta de pago")
                .font(.system(size: 31, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text("Revisa remuneraciones, descuentos y el neto del período en un solo lugar.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.84))

            HStack(spacing: 7) {
                Image(systemName: "info.circle.fill")
                Text("RMV vigente · S/ \(Boleta.rmv, specifier: "%.2f")")
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 11)
            .padding(.vertical, 8)
            .background(.white.opacity(0.14), in: Capsule())
        }
        .padding(21)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [tintaEncabezado, acento], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
    }

    private func detalleTasas(_ tasas: TasasAFP) -> String {
        let comision: String
        switch tipoComisionAFP {
        case .flujo:
            comision = "Comisión sobre remuneración: \(porcentaje(tasas.comisionFlujo))"
        case .saldo:
            comision = "Comisión anual sobre saldo: \(porcentaje(tasas.comisionSaldoAnual)); no se retiene de esta remuneración"
        }
        return "Aporte al fondo: \(porcentaje(tasas.fondo)) · \(comision) · Seguro: \(porcentaje(tasas.seguro)) hasta \(moneda(tasas.topeSeguro))."
    }

    private func porcentaje(_ tasa: Double) -> String {
        let formato = NumberFormatter()
        formato.locale = Locale(identifier: "es_PE")
        formato.numberStyle = .percent
        formato.minimumFractionDigits = 2
        formato.maximumFractionDigits = 2
        return formato.string(from: NSNumber(value: tasa)) ?? "\(tasa * 100)%"
    }

    private var separador: some View {
        Divider().padding(.vertical, 1)
    }

    private func tarjeta<Contenido: View>(
        _ titulo: String,
        icono: String,
        @ViewBuilder contenido: () -> Contenido
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: icono)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(acento)
                    .frame(width: 34, height: 34)
                    .background(acento.opacity(0.10), in: RoundedRectangle(cornerRadius: 11))
                Text(titulo)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(tinta)
            }
            contenido()
        }
        .padding(17)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(tinta.opacity(0.06), lineWidth: 1)
        }
    }

    private func campo(
        _ titulo: String,
        detalle: String? = nil,
        texto: Binding<String>,
        decimal: Bool = false,
        sufijo: String
    ) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(titulo)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(tinta)
                if let detalle {
                    Text(detalle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 5)
            TextField("0", text: texto)
                .multilineTextAlignment(.trailing)
                .keyboardType(decimal ? .decimalPad : .numberPad)
                .font(.body.weight(.semibold).monospacedDigit())
                .frame(minWidth: 42, maxWidth: 100)
                .accessibilityLabel(titulo)
            Text(sufijo)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(minWidth: 28, alignment: .leading)
        }
        .padding(.vertical, 2)
    }

    private func calcular() {
        mensajeError = nil
        resultado = nil

        guard let sueldo = numero(sueldoTexto), sueldo > 0 else {
            mensajeError = "Ingresa un sueldo mayor que cero."
            return
        }
        guard let dias = Int(diasTexto), (1...30).contains(dias) else {
            mensajeError = "Los días laborados deben estar entre 1 y 30."
            return
        }
        guard let horas25 = numero(horas25Texto, vacioEsCero: true), horas25 >= 0,
              let horas35 = numero(horas35Texto, vacioEsCero: true), horas35 >= 0 else {
            mensajeError = "Las horas extras deben ser cero o mayores."
            return
        }
        guard let adelanto = numero(adelantoTexto, vacioEsCero: true), adelanto >= 0 else {
            mensajeError = "El adelanto debe ser cero o mayor."
            return
        }

        let datos = DatosBoleta(
            sueldoBasico: sueldo,
            diasLaborados: dias,
            tieneHijos: tieneHijos,
            sistemaPension: sistemaPension,
            afp: afpSeleccionada,
            tipoComisionAFP: tipoComisionAFP,
            horas25: horas25,
            horas35: horas35,
            adelantos: adelanto
        )

        do {
            resultado = try calculadora.calcular(datos)
        } catch {
            mensajeError = error.localizedDescription
        }
    }

    private func numero(_ texto: String, vacioEsCero: Bool = false) -> Double? {
        let limpio = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        if limpio.isEmpty && vacioEsCero { return 0 }
        return Double(limpio.replacingOccurrences(of: ",", with: "."))
    }

    private func vistaBoleta(_ resultado: ResultadoBoleta) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Resultado")
                        .font(.caption.weight(.bold))
                        .tracking(1)
                        .foregroundStyle(acento)
                    Text("Tu boleta")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(tinta)
                }
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundStyle(acento)
            }

            bloque("REMUNERACIONES", icono: "plus.circle.fill", conceptos: resultado.remuneraciones)
            filaTotal("Total remuneraciones", resultado.totalRemuneraciones)
            bloque("RETENCIONES / DESCUENTOS", icono: "minus.circle.fill", conceptos: resultado.descuentos)
            filaTotal("Total descuentos", resultado.totalDescuentos)
            bloque("APORTACIONES DEL EMPLEADOR", icono: "building.2.fill", conceptos: resultado.aportaciones)

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("NETO A PAGAR")
                        .font(.caption.weight(.bold))
                        .tracking(0.8)
                    Text("Monto que recibe el trabajador")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.78))
                }
                Spacer(minLength: 8)
                Text(moneda(resultado.netoPagar))
                    .font(.system(size: 22, weight: .bold, design: .rounded).monospacedDigit())
            }
            .foregroundStyle(.white)
            .padding(18)
            .background(LinearGradient(colors: [acento, Color(red: 0.04, green: 0.36, blue: 0.39)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

            Label("EsSalud lo paga el empleador; no se descuenta al trabajador.", systemImage: "info.circle")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 3)
        }
        .padding(17)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func bloque(_ titulo: String, icono: String, conceptos: [ConceptoBoleta]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(titulo, systemImage: icono)
                .font(.caption.weight(.bold))
                .tracking(0.35)
                .foregroundStyle(acento)
            ForEach(conceptos) { concepto in
                HStack(spacing: 8) {
                    Text(concepto.nombre)
                        .font(.subheadline)
                        .foregroundStyle(tinta)
                    Spacer(minLength: 4)
                    Text(moneda(concepto.monto))
                        .font(.subheadline.weight(.medium).monospacedDigit())
                        .foregroundStyle(tinta)
                }
                if concepto.id != conceptos.last?.id {
                    Divider()
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
    }

    private func filaTotal(_ titulo: String, _ monto: Double) -> some View {
        HStack {
            Text(titulo).font(.subheadline.weight(.bold))
            Spacer()
            Text(moneda(monto)).font(.subheadline.weight(.bold).monospacedDigit())
        }
        .foregroundStyle(tinta)
        .padding(.horizontal, 3)
    }

    private func moneda(_ monto: Double) -> String {
        let formato = NumberFormatter()
        formato.locale = Locale(identifier: "es_PE")
        formato.numberStyle = .currency
        formato.currencyCode = "PEN"
        formato.minimumFractionDigits = 2
        formato.maximumFractionDigits = 2
        return formato.string(from: NSNumber(value: monto)) ?? String(format: "S/ %.2f", monto)
    }
}
