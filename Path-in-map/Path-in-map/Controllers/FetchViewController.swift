import UIKit
import CoreData
import CoreLocation

class FetchViewController: UITableViewController {
    
    // MARK: Properties
    private var path2: Path?
    var path = [Path]()
    fileprivate let CustomCell:String = "CustomCell"

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
        sectionNameKeyPath: #keyPath(Path.timestamp),
        cacheName: "trailhero")
        
        fetchedResultsController.delegate = self
      return fetchedResultsController
    }()
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        setupTableView()
       
        do {
          print("First time view loaded.")
          try fetchedResultsController.performFetch()
        } catch let error as NSError {
          print("Fetching error: \(error), \(error.userInfo)")
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      performFetch()
    }
    
    // MARK: Helpers
    func performFetch() {
      do {
        tableView.reloadData()
        print("View updated.")
        try fetchedResultsController.performFetch()
      } catch let error as NSError {
        print("Fetching error: \(error), \(error.userInfo)")
      }
    }
    
    fileprivate func setupTableView() {
        tableView.register(PathCell.self, forCellReuseIdentifier: CustomCell)
    }
    
    // MARK: Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
      if let sections = fetchedResultsController.sections {
        return sections.count
      }
      return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if let sections = fetchedResultsController.sections {
        return sections[section].numberOfObjects
      }
      return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! PathCell
        let location = fetchedResultsController.object(at: indexPath)
        //cell.configure(for: location)
        cell.runData = location
        return cell
    }
    
    // MARK: didSelectRowAt
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt tapped..")
        ///v1
        let DetailController = PathDetailsViewController()

        let location = fetchedResultsController.object(at: indexPath)
        DetailController.runData = location
        
        //navigationController?.pushViewController(DetailController, animated: true)
        performSegue(withIdentifier: .details, sender: nil)
    }
    
//    // MARK: Navigation to the LocationDetailsVC
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//      if segue.identifier == "PathDetailsViewController" {
//        let controller = segue.destination  as! PathDetailsViewController // Testaa tätä!
////        controller.managedObjectContext = managedObjectContext
//          controller.path = path2
//
//        if let indexPath = tableView.indexPath(
//          for: sender as! UITableViewCell) {
//          let location = fetchedResultsController.object(at: indexPath)
//          controller.runData = location
//        }
//      }
//    }
    
} // END

// self.performSegue(withIdentifier: .details, sender: nil)

//// MARK: Navigation
extension FetchViewController: SegueHandlerType {
  enum SegueIdentifier: String {
    case details = "PathDetailsViewController"
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segueIdentifier(for: segue) {
    case .details:
      let destination = segue.destination as! PathDetailsViewController
      destination.path = path2
    }
  }
}



// MARK: - NSFetchedResultsControllerDelegate
extension FetchViewController: NSFetchedResultsControllerDelegate {
  
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    print("*** controllerWillChangeContent")
    tableView.beginUpdates()
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?,for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      print("*** NSFetchedResultsChangeInsert (object)")
      tableView.insertRows(at: [newIndexPath!], with: .fade)

    case .delete:
      print("*** NSFetchedResultsChangeDelete (object)")
      tableView.deleteRows(at: [indexPath!], with: .fade)

    case .update:
      print("*** NSFetchedResultsChangeUpdate (object)")
      if let cell = tableView.cellForRow(
        at: indexPath!) as? PathCell {
        let noteForRow = controller.object(
          at: indexPath!) as! Path
        cell.runData = noteForRow
          //cell.configure(for: noteForRow)
      }

    case .move:
      print("*** NSFetchedResultsChangeMove (object)")
      tableView.deleteRows(at: [indexPath!], with: .fade)
      tableView.insertRows(at: [newIndexPath!], with: .fade)
      
    @unknown default:
      print("*** NSFetchedResults unknown type")
    }
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    switch type {
    case .insert:
      print("*** NSFetchedResultsChangeInsert (section)")
      tableView.insertSections(
        IndexSet(integer: sectionIndex), with: .fade)
    case .delete:
      print("*** NSFetchedResultsChangeDelete (section)")
      tableView.deleteSections(
        IndexSet(integer: sectionIndex), with: .fade)
    case .update:
      print("*** NSFetchedResultsChangeUpdate (section)")
    case .move:
      print("*** NSFetchedResultsChangeMove (section)")
    @unknown default:
      print("*** NSFetchedResults unknown type")
    }
  }

  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    print("*** controllerDidChangeContent")
    tableView.endUpdates()
  }
  
}
