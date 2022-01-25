import UIKit
import MapKit
import CoreData

class PathDetailsViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    // MARK: Properties
    var routeOverlay: MKOverlay?
    var routeCoordinates: [CLLocation] = []
    
    let dateFormatter: DateFormatter = {
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "MMMM dd, YYYY hh:mm"
          return dateFormatter
    }()
    
    var path: Path?
//    var path2 = [Path]() // Just testing: Same solution than in MyLocations MapVC
    
  //  var managedObjectContext: NSManagedObjectContext
    var runData: Path? {
        didSet {
            distanceLabel?.text = String(runData?.distance ?? 0)
            timeLabel?.text = String(runData?.duration ?? 0)
            dateLabel?.text = dateFormatter.string(from: runData?.timestamp ?? Date())
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
      super.viewDidLoad()
      configureView()
        mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ViewDidAppear")
        //mapRegion()
        loadMap2(path: routeCoordinates)
    }
    
    // MARK: Helpers
    
    private func configureView() {
        let distance = Measurement(value: path?.distance ?? 1, unit: UnitLength.meters)
        let seconds = Int(path?.duration ?? 0)
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedDate = FormatDisplay.date(path?.timestamp ?? Date())
        let formattedTime = FormatDisplay.time(seconds)
      
      distanceLabel.text = "Distance:  \(formattedDistance)"
      dateLabel.text = formattedDate
      timeLabel.text = "Time:  \(formattedTime)"
      loadMap()
    }
    
    private func mapRegion() -> MKCoordinateRegion? {
      guard
        let locations = path?.locations,
        locations.count > 0
      else {
        return nil
      }
        print("jotain paikkatietoa \(locations.array)")
      
      let latitudes = locations.map { location -> Double in
        let location = location as! Paikka
          print("jotain paikkatietoa \(location.latitude)")
        return location.latitude
      }
      
      let longitudes = locations.map { location -> Double in
        let location = location as! Paikka
        return location.longitude
      }
      
      let maxLat = latitudes.max()!
      let minLat = latitudes.min()!
      let maxLong = longitudes.max()!
      let minLong = longitudes.min()!
      
      let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLong + maxLong) / 2)
      let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3, longitudeDelta: (maxLong - minLong) * 1.3)
      return MKCoordinateRegion(center: center, span: span)
    }
    
    private func polyLine() -> [MulticolorPolyline] {
      
      let locations = path?.locations?.array as! [Paikka]
      var coordinates: [(CLLocation, CLLocation)] = []
      var speeds: [Double] = []
      var minSpeed = Double.greatestFiniteMagnitude
      var maxSpeed = 0.0
      
      for (first, second) in zip(locations, locations.dropFirst()) {
        let start = CLLocation(latitude: first.latitude, longitude: first.longitude)
        let end = CLLocation(latitude: second.latitude, longitude: second.longitude)
        coordinates.append((start, end))
        
        let distance = end.distance(from: start)
        let time = second.timestamp!.timeIntervalSince(first.timestamp! as Date)
        let speed = time > 0 ? distance / time : 0
        speeds.append(speed)
        minSpeed = min(minSpeed, speed)
        maxSpeed = max(maxSpeed, speed)
      }
      
      let midSpeed = speeds.reduce(0, +) / Double(speeds.count)
      
      var segments: [MulticolorPolyline] = []
      for ((start, end), speed) in zip(coordinates, speeds) {
        let coords = [start.coordinate, end.coordinate]
        let segment = MulticolorPolyline(coordinates: coords, count: 2)
        segments.append(segment)
      }
      return segments
    }
    
    private func loadMap() {
      guard
        let locations = path?.locations,
        locations.count > 0,
        let region = mapRegion()
      else {
          let alert = UIAlertController(title: "Error", message: "Sorry, this run has no locations saved", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .cancel))
          present(alert, animated: true)
          return
      }
      mapView.setRegion(region, animated: true)
      mapView.addOverlays(polyLine())
      print("Load map called")
    }
    
    // MARK: Proto testing:
    
    func loadMap2(path: [CLLocation]) {
        if path.count == 0 {
            print("No coordinates to show... ")
            return
        }
        
        let coordinates = path.map { location -> CLLocationCoordinate2D in
            return location.coordinate
        }
        
        DispatchQueue.main.async {
            self.routeOverlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
            self.mapView.addOverlay(self.routeOverlay!, level: .aboveRoads)
        }
        
    }
    
    func loadMap3() {
        mapView.delegate = self
        
        let locations = path?.locations?.array as! [Paikka]
        var latitude: [(CLLocation, CLLocation)] = []
        var lat = locations.map { $0.latitude }
        var lon = locations.map { $0.longitude }
        guard let alue = mapRegion() else { return }
        
        print("Load map3 called")
        mapView.setRegion(alue, animated: true)
        mapView.addOverlays(polyLine())
    }

}

//     let longitudes = locations.map { location -> Double in
//let location = location as! Paikka
//return location.longitude
//}


// MARK: Extensions: Map View Delegate

extension PathDetailsViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      print("MapView Delegate rendered access...")
    guard let polyline = overlay as? MulticolorPolyline else {
      return MKOverlayRenderer(overlay: overlay)
    }
    let renderer = MKPolylineRenderer(polyline: polyline)
    renderer.strokeColor = .systemBlue
    renderer.lineWidth = 3
    return renderer
  }
}
