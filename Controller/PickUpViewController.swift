//
//  PickUpViewController.swift
//  SchoolLift
//
//  Created by Adrian Rivacoba on 9/27/18.
//  Copyright © 2018 TBD. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import FirebaseAuth
import FirebaseDatabase

class PickUpViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {


    
    @IBOutlet weak var mapView: MKMapView!
    
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private var riderLocation: CLLocationCoordinate2D?
    private var pointCoordinate: CLLocationCoordinate2D?
    var annotation = MKPointAnnotation()
    var fnamefinal: String?
    var driverannotation = MKPointAnnotation()
    var currentUserId = Auth.auth().currentUser?.uid
    var ref = Database.database().reference()


    
    override func viewDidLoad() {
        super.viewDidLoad()

        checkUserDatabase()

        mapView.delegate = self
        initializeLocationManager()
        
        monitorDropOff()
    }
    
    private func initializeLocationManager () {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }

    var userLocationDriver:CLLocation!
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // if we have the coordinates from the manager
        if let location = locationManager.location?.coordinate {
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            
            mapView.setRegion(region, animated: true)
            annotation.coordinate = userLocation!
            annotation.title = "Your Location"
            mapView.addAnnotation(annotation)
            
            driverannotation.title = "Drivers Location"
            mapView.addAnnotation(driverannotation)
            
            //start geofence for request pick up location
            let geofenceRegionCenter = CLLocationCoordinate2DMake(driverannotation.coordinate.latitude, driverannotation.coordinate.longitude)
            let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter,
                                                  radius: 50,
                                                  identifier: "UniqueIdentifier")
            geofenceRegion.notifyOnEntry = true
            
            locationManager.startMonitoring(for: geofenceRegion)

        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
//        if annotation.isMember(of: MKUserLocation.self) {
//            return nil
//        }
        
        let reuseId = "MKAnnotationView"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)}
     
        pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        pinView!.image = UIImage(named: "icons8-marker") // make sure this name is the name of image
        
        return pinView
        
    }
    
    func checkUserDatabase() {
        ref.child("Users").child("\(currentUserId!)").child("data").observe(.value, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                
                if let rkey = dictionary["requestkey"] as? String {
                    self.ref.child("Request").child(rkey).observe(.childChanged, with: { (snapshot) in
                        let g = snapshot.key
                        let f = snapshot.value

                        if g == "driverlatitude" {
                            self.driverannotation.coordinate.latitude = f as! CLLocationDegrees
                            self.mapView.addAnnotation(self.driverannotation)
                        } else if g == "driverlongitude" {
                            self.driverannotation.coordinate.longitude = f as! CLLocationDegrees
                            self.mapView.addAnnotation(self.driverannotation)
                        }
                    })
                }
            }
        })
    }
    
    //when driver finishes drop off:
    func monitorDropOff() {
        ref.child("Users").child(currentUserId!).child("data").observeSingleEvent(of: .value, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                if let requestkey = dictionary["requestkey"] as? String {
                    self.ref.child("Request").child(requestkey).observeSingleEvent(of: .childRemoved, with: {(snapshot) in
                        
                        // make vcadcontroller = 0 or 3 when I finish the rating system
                        SingleAppDelegate.sharedInstance.vcadcontroller = 0
                        
                        self.performSegue(withIdentifier: "riderdone", sender: self)
                        
                    })
                }
            }
        })
    }
}
