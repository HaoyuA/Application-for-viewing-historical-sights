//
//  MapViewController.swift
//  FIT5140-Assign1
//
//  Created by 张昊宇 on 2/9/19.
//  Copyright © 2019 Haoyu Zhang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController,DatabaseListener,MKMapViewDelegate,CLLocationManagerDelegate{
    
    var listenerType = ListenerType.sights
    var allSights: [Sight] = []
    var locationList = [LocationAnnotation]()
    var annotation: LocationAnnotation?
    var sightForEdit: Sight?
    var locationManager: CLLocationManager = CLLocationManager()
    var geoLocation: CLCircularRegion?
    let CBDRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -37.8124, longitude: 144.9623) , latitudinalMeters: 30000,longitudinalMeters: 30000)
    
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        mapView.register(locationAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        //mapView.setRegion(CBDRegion, animated: true )
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()

        for Sight in allSights{
            let name = Sight.name
            let desc = Sight.desc
            let latitude = Sight.latitude
            let longitude = Sight.longitude
            let icon = Sight.icon
            let image = Sight.photo
            let location = LocationAnnotation(title: name!, subtitle: desc!, lat: latitude, long: longitude, icon: icon!, image: image!)
            let annotation: MKAnnotation = location
            
            locationList.append(location)
            mapView.addAnnotation(annotation)
            geoLocation = CLCircularRegion(center: annotation.coordinate, radius: 500,
                                           identifier: "\(annotation.title)")
            geoLocation!.notifyOnEntry = true
            
            locationManager.startMonitoring(for: geoLocation!)
        }
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func focusOn(annotation: LocationAnnotation){
        
//        mapView.addAnnotation(annotation)
//        mapView.selectAnnotation(annotation, animated: true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate , latitudinalMeters: 1000,longitudinalMeters: 1000)
        mapView.setRegion(zoomRegion, animated: true)
        
    }

    func onSightListChange(change: DatabaseChange, sights: [Sight]) {
        allSights = sights
        self.mapView.removeAnnotations(locationList)
        
        self.viewDidLoad()
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let alert = UIAlertController(title: "Movement Detected!", message: "You have entered \(region.identifier)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sightListSegue" {
            let destination = segue.destination as! SightListTableViewController
            destination.mapViewController = self
        }
        if segue.identifier == "detailSegue"{
            let destination = segue.destination as! SightDetailViewController
            destination.annotation = self.annotation
            destination.sightForEdit = self.sightForEdit
        }
    }
    
//    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
//        let location = locations.last as! CLLocation
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        var region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
//        region.center = mapView.userLocation.coordinate
//        mapView.setRegion(region, animated: true)
//    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        self.annotation = (view.annotation as! LocationAnnotation)
        self.sightForEdit = allSights.filter{ $0.name == annotation?.title}.first
        performSegue(withIdentifier: "detailSegue", sender: nil)
    }
    
    @IBAction func foucuson(_ sender: Any) {
        
        mapView.setRegion(mapView.regionThatFits(CBDRegion), animated: true)
    }
   
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//        guard let annotation = annotation as? LocationAnnotation else { return nil }
//
//        let identifier = "marker"
//        var view: MKMarkerAnnotationView
//
//        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//            as? MKMarkerAnnotationView {
//            dequeuedView.annotation = annotation
//            view = dequeuedView
//        } else {
//
//            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            view.canShowCallout = true
//            view.calloutOffset = CGPoint(x: -5, y: 5)
//            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//            let i = UIImageView(frame: CGRect(origin: CGPoint.zero,
//                                              size: CGSize(width: 40, height: 40)))
//            if let image: String = annotation.image{
//                i.image = UIImage(named:"picture/"+image)}
//            else{
//                i.image = nil
//            }
//            view.leftCalloutAccessoryView = i
//        }
//        return view
//    }
    
    
    
    
}

