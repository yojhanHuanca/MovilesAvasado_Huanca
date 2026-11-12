import CoreData
import Foundation

enum AppRole {
    static let seller = "Vendedor"
    static let supervisor = "Supervisor"
}

enum SalesPeriod: Int {
    case all
    case today
    case month

    var title: String {
        switch self {
        case .all: return "Todas"
        case .today: return "Hoy"
        case .month: return "Mes"
        }
    }
}

struct SaleAmounts {
    let subtotal: Double
    let discount: Double
    let tax: Double
    let total: Double
}

enum BusinessError: LocalizedError {
    case invalidRegistration
    case duplicateUsername
    case invalidCredentials
    case missingData
    case insufficientStock
    case supervisorOnly
    case reasonRequired
    case linkedRecord

    var errorDescription: String? {
        switch self {
        case .invalidRegistration:
            return "Completa todos los campos. La clave necesita 6 caracteres y debe coincidir con su confirmación."
        case .duplicateUsername:
            return "Ese usuario ya está registrado."
        case .invalidCredentials:
            return "Usuario o clave incorrectos"
        case .missingData:
            return "Completa los datos requeridos."
        case .insufficientStock:
            return "No hay stock suficiente. La venta no se registró."
        case .supervisorOnly:
            return "Esta acción solo está disponible para el Supervisor."
        case .reasonRequired:
            return "Escribe el motivo de la anulación."
        case .linkedRecord:
            return "No se puede borrar porque ya tiene ventas relacionadas."
        }
    }
}

final class SalesService {
    static let shared = SalesService()

    private let context = CoreDataStack.shared.context

    private init() {}

    func registerUser(
        name: String,
        username: String,
        password: String,
        confirmation: String,
        role: String
    ) throws -> Usuario {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty,
              !cleanUsername.isEmpty,
              password.count >= 6,
              password == confirmation else {
            throw BusinessError.invalidRegistration
        }

        let request = Usuario.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "usuario ==[c] %@", cleanUsername)
        guard try context.fetch(request).isEmpty else {
            throw BusinessError.duplicateUsername
        }

        let user = Usuario(context: context)
        user.id = UUID()
        user.nombre = cleanName
        user.usuario = cleanUsername
        user.clave = password
        user.rol = role
        try save()
        return user
    }

    func login(username: String, password: String) throws -> Usuario {
        let request = Usuario.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "usuario ==[c] %@ AND clave == %@",
            username.trimmingCharacters(in: .whitespacesAndNewlines),
            password
        )
        guard let user = try context.fetch(request).first else {
            throw BusinessError.invalidCredentials
        }
        return user
    }

    func products() throws -> [Producto] {
        let request = Producto.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "categoria", ascending: true),
            NSSortDescriptor(key: "nombre", ascending: true)
        ]
        return try context.fetch(request)
    }

    func saveProduct(
        existing: Producto?,
        name: String,
        category: String,
        price: Double,
        stock: Int
    ) throws {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty, !cleanCategory.isEmpty, price > 0, stock >= 0 else {
            throw BusinessError.missingData
        }

        let product = existing ?? Producto(context: context)
        if existing == nil { product.id = UUID() }
        product.nombre = cleanName
        product.categoria = cleanCategory
        product.precio = price
        product.stock = Int64(stock)
        try save()
    }

    func deleteProduct(_ product: Producto) throws {
        if let sales = product.ventas as? Set<Venta>, !sales.isEmpty {
            throw BusinessError.linkedRecord
        }
        context.delete(product)
        try save()
    }

    func clients() throws -> [Cliente] {
        let request = Cliente.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "nombre", ascending: true)]
        return try context.fetch(request)
    }

    func saveClient(existing: Cliente?, name: String, document: String) throws {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDocument = document.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty, !cleanDocument.isEmpty else {
            throw BusinessError.missingData
        }

        let client = existing ?? Cliente(context: context)
        if existing == nil { client.id = UUID() }
        client.nombre = cleanName
        client.documento = cleanDocument
        try save()
    }

    func deleteClient(_ client: Cliente) throws {
        if let sales = client.ventas as? Set<Venta>, !sales.isEmpty {
            throw BusinessError.linkedRecord
        }
        context.delete(client)
        try save()
    }

    func amountSpent(by client: Cliente) -> Double {
        let sales = (client.ventas as? Set<Venta> ?? []).filter { !$0.anulada }
        return sales.reduce(0) { $0 + $1.total }
    }

    func category(for client: Cliente) -> String {
        let total = amountSpent(by: client)
        if total >= 5_000 { return "VIP" }
        if total >= 1_000 { return "Frecuente" }
        return "Regular"
    }

    func calculateSale(client: Cliente, product: Producto, quantity: Int) -> SaleAmounts {
        let subtotal = product.precio * Double(quantity)
        let discount = category(for: client) == "VIP" ? subtotal * 0.10 : 0
        let tax = (subtotal - discount) * 0.18
        return SaleAmounts(
            subtotal: subtotal,
            discount: discount,
            tax: tax,
            total: subtotal - discount + tax
        )
    }

    @discardableResult
    func createSale(
        seller: Usuario,
        client: Cliente,
        product: Producto,
        quantity: Int
    ) throws -> Venta {
        guard seller.rol == AppRole.seller else {
            throw BusinessError.supervisorOnly
        }
        guard quantity > 0, Int64(quantity) <= product.stock else {
            throw BusinessError.insufficientStock
        }

        let amounts = calculateSale(client: client, product: product, quantity: quantity)
        let sale = Venta(context: context)
        sale.id = UUID()
        sale.fecha = Date()
        sale.cantidad = Int64(quantity)
        sale.precioUnitario = product.precio
        sale.descuento = amounts.discount
        sale.igv = amounts.tax
        sale.total = amounts.total
        sale.anulada = false
        sale.vendedor = seller
        sale.cliente = client
        sale.producto = product
        product.stock -= Int64(quantity)

        do {
            try save()
            return sale
        } catch {
            context.rollback()
            throw error
        }
    }

    func sales(
        isSupervisor: Bool,
        viewer: Usuario,
        period: SalesPeriod,
        seller: Usuario? = nil
    ) throws -> [Venta] {
        var predicates: [NSPredicate] = []
        if !isSupervisor {
            predicates.append(NSPredicate(format: "vendedor == %@", viewer))
        } else if let seller {
            predicates.append(NSPredicate(format: "vendedor == %@", seller))
        }

        let calendar = Calendar.current
        let now = Date()
        if period == .today {
            let start = calendar.startOfDay(for: now)
            predicates.append(NSPredicate(format: "fecha >= %@", start as NSDate))
        } else if period == .month,
                  let start = calendar.dateInterval(of: .month, for: now)?.start {
            predicates.append(NSPredicate(format: "fecha >= %@", start as NSDate))
        }

        let request = Venta.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "fecha", ascending: false)]
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        return try context.fetch(request)
    }

    func sellers() throws -> [Usuario] {
        let request = Usuario.fetchRequest()
        request.predicate = NSPredicate(format: "rol == %@", AppRole.seller)
        request.sortDescriptors = [NSSortDescriptor(key: "nombre", ascending: true)]
        return try context.fetch(request)
    }

    func annul(sale: Venta, supervisor: Usuario, reason: String) throws {
        guard supervisor.rol == AppRole.supervisor else {
            throw BusinessError.supervisorOnly
        }
        let cleanReason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanReason.isEmpty else { throw BusinessError.reasonRequired }
        guard !sale.anulada else { return }

        sale.anulada = true
        sale.motivoAnulacion = cleanReason
        sale.producto?.stock += sale.cantidad
        do {
            try save()
        } catch {
            context.rollback()
            throw error
        }
    }

    private func save() throws {
        try CoreDataStack.shared.save()
    }
}

enum DemoDataSeeder {
    static func seedIfNeeded() {
        let context = CoreDataStack.shared.context
        let request = Producto.fetchRequest()
        request.fetchLimit = 1
        guard (try? context.fetch(request).isEmpty) == true else { return }

        let demoSeller = Usuario(context: context)
        demoSeller.id = UUID()
        demoSeller.nombre = "Vendedor de demostración"
        demoSeller.usuario = "demo"
        demoSeller.clave = "demo123"
        demoSeller.rol = AppRole.seller

        let laptop = Producto(context: context)
        laptop.id = UUID()
        laptop.nombre = "Laptop"
        laptop.categoria = "Tecnología"
        laptop.precio = 200
        laptop.stock = 62

        let mouse = Producto(context: context)
        mouse.id = UUID()
        mouse.nombre = "Mouse"
        mouse.categoria = "Accesorios"
        mouse.precio = 35
        mouse.stock = 40

        let vipClient = Cliente(context: context)
        vipClient.id = UUID()
        vipClient.nombre = "Cliente VIP de prueba"
        vipClient.documento = "VIP-001"

        let regularClient = Cliente(context: context)
        regularClient.id = UUID()
        regularClient.nombre = "Cliente Regular de prueba"
        regularClient.documento = "REG-001"

        let oldSale = Venta(context: context)
        oldSale.id = UUID()
        oldSale.fecha = Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date()
        oldSale.cantidad = 22
        oldSale.precioUnitario = 200
        oldSale.descuento = 0
        oldSale.igv = 792
        oldSale.total = 5_192
        oldSale.anulada = false
        oldSale.vendedor = demoSeller
        oldSale.cliente = vipClient
        oldSale.producto = laptop
        laptop.stock -= oldSale.cantidad

        do {
            try CoreDataStack.shared.save()
        } catch {
            context.rollback()
            print("No se pudieron cargar los datos de demostración: \(error)")
        }
    }
}
