import Foundation
import CoreData

class CoreDataStack {
    private let modelName: String

    init(modelName: String) {
      self.modelName = modelName
    }
  
    // MARK: Context
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    lazy var managedContext: NSManagedObjectContext = {
      return self.storeContainer.viewContext
    }()
    
    private lazy var storeContainer: NSPersistentContainer = {
      let container = NSPersistentContainer(name: self.modelName)
      container.loadPersistentStores { _, error in
        if let error = error as NSError? {
          print("Unresolved error \(error), \(error.userInfo)")
        }
      }
      return container
    }()
    
    // MARK: PersistContainer
    static let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Paths")
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // MARK: Functions
    class func saveContext () {
      let context = persistentContainer.viewContext
      
      guard context.hasChanges else {
        return
      }
      
      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }

}
