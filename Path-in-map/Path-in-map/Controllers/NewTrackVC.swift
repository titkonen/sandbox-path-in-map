import UIKit
import CoreLocation
import MapKit

class NewTrackVC: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    // MARK: Properties
    private var path: Path?
    private let locationManager = LocationManager.shared
    private var seconds = 0
    private var timer: Timer?
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var paikkaListausObjekti: [CLLocation] = []
    
    // MARK: View Life
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        mapView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      timer?.invalidate()
    }

    // MARK: Actions
    @IBAction func startTrackingPressed(_ sender: UIButton) {
        startTrack()
    }
    
    @IBAction func stopTrackingPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Choose action", message: "PÖÖ", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Continue", style: .cancel))
        alertController.addAction(UIAlertAction(title: "End tracking", style: .destructive) { _ in
          self.stopTrack()
          self.saveTrack()
          self.performSegue(withIdentifier: .details, sender: nil)
            //self.present(alertController, animated: true, completion: nil)
          //_ = self.navigationController?.popToRootViewController(animated: true)
        })
        present(alertController, animated: true)
    }
    
    // MARK: Functions
    private func startTrack() {
        mapView.removeOverlays(mapView.overlays)
        seconds = 0
        distance = Measurement(value: 0, unit: UnitLength.meters)
        paikkaListausObjekti.removeAll()
        updateDisplay()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
          self.eachSecond()
        }
        startLocationUpdates()
        print("Printtaa etäisyys...\(distance)")
    }
    
    private func stopTrack() {
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
    }
    
    func eachSecond() {
        seconds += 1
        updateDisplay()
    }
    
    private func saveTrack() {
        let newPath = Path(context: CoreDataStack.context)
        newPath.distance = distance.value
        newPath.duration = Int16(seconds)
        newPath.timestamp = Date()
        
        for paikka in paikkaListausObjekti {
            let paikkaObjekti = Paikka(context: CoreDataStack.context)
            paikkaObjekti.timestamp = paikka.timestamp
            paikkaObjekti.latitude = paikka.coordinate.latitude
            paikkaObjekti.longitude = paikka.coordinate.longitude
            newPath.addToPaikat(paikkaObjekti)
        }
        CoreDataStack.saveContext()
        path = newPath
    }
    
    private func updateDisplay() {
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedTime = FormatDisplay.time(seconds)
        distanceLabel.text = "Distance: \(formattedDistance)"
        timeLabel.text = "Time: \(formattedTime)"
    }
    
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
    }
    
   
    
} //END

// MARK: Navigation
extension NewTrackVC: SegueHandlerType {
  enum SegueIdentifier: String {
    case details = "PathDetailsViewController"
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segueIdentifier(for: segue) {
    case .details:
      let destination = segue.destination as! PathDetailsViewController
      destination.path = path
    }
  }
}

// MARK: - Location Manager Delegate
extension NewTrackVC: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations paikat: [CLLocation]) {
      print("testing...")
    for newLocation in paikat {
      let howRecent = newLocation.timestamp.timeIntervalSinceNow
      guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
      
      if let lastLocation = paikkaListausObjekti.last {
        let delta = newLocation.distance(from: lastLocation)
        distance = distance + Measurement(value: delta, unit: UnitLength.meters)
        let coordinates = [lastLocation.coordinate, newLocation.coordinate]
        mapView.addOverlay(MKPolyline(coordinates: coordinates, count: 2))
        let region = MKCoordinateRegion.init(center: newLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
      }
      paikkaListausObjekti.append(newLocation)
    }
  }
}

// MARK: - Map View Delegate
extension NewTrackVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("Uusi yritys")
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 6
        return renderer
    }
    
}
