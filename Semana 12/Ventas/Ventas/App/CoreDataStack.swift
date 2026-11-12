import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "Ventas")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("No se pudo abrir la base de datos: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }

    func save() throws {
        guard context.hasChanges else { return }
        try context.save()
    }
}
