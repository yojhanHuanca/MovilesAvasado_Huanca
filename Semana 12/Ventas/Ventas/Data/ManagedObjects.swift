import CoreData

@objc(Usuario)
public final class Usuario: NSManagedObject {}

extension Usuario {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Usuario> {
        NSFetchRequest<Usuario>(entityName: "Usuario")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var nombre: String
    @NSManaged public var usuario: String
    @NSManaged public var clave: String
    @NSManaged public var rol: String
    @NSManaged public var ventas: NSSet?
}

@objc(Producto)
public final class Producto: NSManagedObject {}

extension Producto {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Producto> {
        NSFetchRequest<Producto>(entityName: "Producto")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var nombre: String
    @NSManaged public var categoria: String
    @NSManaged public var precio: Double
    @NSManaged public var stock: Int64
    @NSManaged public var ventas: NSSet?
}

@objc(Cliente)
public final class Cliente: NSManagedObject {}

extension Cliente {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cliente> {
        NSFetchRequest<Cliente>(entityName: "Cliente")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var nombre: String
    @NSManaged public var documento: String
    @NSManaged public var ventas: NSSet?
}

@objc(Venta)
public final class Venta: NSManagedObject {}

extension Venta {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Venta> {
        NSFetchRequest<Venta>(entityName: "Venta")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var fecha: Date
    @NSManaged public var cantidad: Int64
    @NSManaged public var precioUnitario: Double
    @NSManaged public var descuento: Double
    @NSManaged public var igv: Double
    @NSManaged public var total: Double
    @NSManaged public var anulada: Bool
    @NSManaged public var motivoAnulacion: String?
    @NSManaged public var vendedor: Usuario?
    @NSManaged public var producto: Producto?
    @NSManaged public var cliente: Cliente?
}
