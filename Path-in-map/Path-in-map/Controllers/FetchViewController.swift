import UIKit
import CoreData

class FetchViewController: UIViewController {
    
    // MARK: Properties
    var path = [Path]()
    var path2: Path?
    

    // MARK: FetchResultController properties
    var managedObjectContext: NSManagedObjectContext!
    
    lazy var coreDataStack = CoreDataStack(modelName: "Paths")
    
    lazy var fetchedResultsController: NSFetchedResultsController<Path> = {
      let fetchRequest: NSFetchRequest<Path> = Path.fetchRequest()
      let sortDescriptor = NSSortDescriptor(key: #keyPath(Path.timestamp), ascending: false)
      fetchRequest.sortDescriptors = [sortDescriptor]

      let fetchedResultsController = NSFetchedResultsController(
        fetchRequest: fetchRequest,
        managedObjectContext: coreDataStack.managedContext,
        //managedObjectContext: self.managedObjectContext, ///test
        sectionNameKeyPath: #keyPath(Path.timestamp),
        cacheName: "trailhero")
        
        fetchedResultsController.delegate = self /// Sends to to extension delegate
      return fetchedResultsController
    }()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray
        performFetch()

    }
    
    // MARK: Functions
    func performFetch() {
      do {
        //tableView.reloadData()
        print("View updated.")
        try fetchedResultsController.performFetch()
      } catch let error as NSError {
        print("Fetching error: \(error), \(error.userInfo)")
      }
    }
    
    
}

// MARK: - NSFetchedResultsControllerDelegate
extension FetchViewController: NSFetchedResultsControllerDelegate {
    
    
}
