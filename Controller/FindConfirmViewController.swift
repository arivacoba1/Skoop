//
//  FindConfirmViewController.swift
//  SchoolLift
//
//  Created by Adrian Rivacoba on 8/27/18.
//  Copyright © 2018 TBD. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation



class FindConfirmViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var garage: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var location: UILabel!
    
    var passengerKey: String?
    let currentUserId = Auth.auth().currentUser?.uid
   
    
    let locationManager = CLLocationManager()
    var userLocationDriver:CLLocation!
    
    var garagename:String!
    var timestamp:String?
    var latitude:Double?
    var longitude:Double?
    var timeanddate:String?
    
    var myRoute:MKRoute = MKRoute()
    var directionsResponse:MKDirections.Response = MKDirections.Response()
    
    var garageL = MKPointAnnotation()
    var userlocation = MKPointAnnotation()


    @IBAction func Acceptbutton(_ sender: Any) {
        
        let ref = Database.database().reference().child("Request").child(passengerKey!)
        ref.updateChildValues([
            "isActivated": "true"
            ])
        
        DBProvider.Instance.acceptTrip(withPassengerKey: passengerKey!, andDriverKey: currentUserId!)


        //if within 30 mins do this:
        if self.checkTimeStamp(date: timeanddate) == true {
        
        SingleAppDelegate.sharedInstance.vcadcontroller = 1
            
        locationManager.delegate = self
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()

        let destinationName = (userlocation.title ?? nil) ?? "Pick Up Location"
        openMapsAppWithDirections(to: userlocation.coordinate, destinationName: destinationName)
            
        } else {
        self.performSegue(withIdentifier: "confirmToyourRides", sender: self)
        }
       
    }

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var customNavigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //adds custom navigation bar
        self.customNavigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.customNavigationBar.shadowImage = UIImage()
        self.customNavigationBar.isTranslucent = true
        self.customNavigationBar.clipsToBounds = true
        
        mapView.delegate = self
        
        //for the Mkpointannotation
        garageL.subtitle = "Car Parked"
        userlocation.subtitle = "Pick Up"
        
        //receives the information for which garage and time of pick up from the last view controller and updates into these values:
        garage.text = garagename
        time.text = timestamp
        
        //adds current location of user accepting
        userlocation.coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        mapView.addAnnotation(userlocation)
        
        //all this does is convert last coordinates to street address to display
        fetchlocation()
        
        //this adds the destination garage location object
        addPickedGarage()
        
        //add placemarks to map for pick up spot and parking spot
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: garageL.coordinate.latitude, longitude: garageL.coordinate.longitude), addressDictionary: nil))
        
        
        // supposed to add a driving directions line on map (not working)
        request.transportType = MKDirectionsTransportType.automobile
        let directions = MKDirections(request: request)
        directions.calculate { (response:MKDirections.Response?, error:Error?) -> Void in
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion.init(rect), animated: true)
    }
}
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKUserLocation) {
            return nil
        }
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: "annId")
        
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annId")
        }
        else {
            anView?.annotation = annotation
        }
        
        anView?.canShowCallout = true
        
        if (annotation.subtitle! == "Pick Up") {
            anView?.image = UIImage(named: "icons8-collaborator")
        }
        else if (annotation.subtitle! == "Car Parked") {
            anView?.image = UIImage(named: "icons8-marker")
        }
        return anView

    }
    
    private func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        let myLineRenderer = MKPolylineRenderer(overlay: overlay)
        myLineRenderer.strokeColor = UIColor.red
        myLineRenderer.lineWidth = 5
        return myLineRenderer
    }

    func fetchlocation() {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude!, longitude: longitude!)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]

            // Location name
            
            // Street address
            
            if let street = placeMark.thoroughfare {
                if let zip = placeMark.postalCode {
                    if let city = placeMark.subAdministrativeArea {
                        self.location.text = "\(street) , \(city) , \(zip)"
                    }
                }
            }
        })
    }
    

    func addPickedGarage() {
        switch garagename {
        case "Speck Garage":
            garageL.title = "Speck Garage"
            garageL.coordinate = CLLocationCoordinate2D(latitude: 29.890803, longitude: -97.953118)
            mapView.addAnnotation(garageL)
        case "Coliseum/Bobcat Stadium":
            
            garageL.title = "Coliseum/Bobcat Stadium"
            garageL.coordinate = CLLocationCoordinate2D(latitude: 29.889558, longitude: -97.930249)
            mapView.addAnnotation(garageL)
        case "Sessom Lot":
            
            garageL.title = "Sessom Lot"
            garageL.coordinate = CLLocationCoordinate2D(latitude: 29.891028, longitude:  -97.937063)
            mapView.addAnnotation(garageL)
        case "James Lot":
            
            garageL.title = "James Lot"
            garageL.coordinate = CLLocationCoordinate2D(latitude: 29.887928, longitude: -97.948513)
            mapView.addAnnotation(garageL)
        case "Sewell North":
            
            garageL.title = "Sewell North"
            garageL.coordinate = CLLocationCoordinate2D(latitude: 29.889414, longitude: -97.933227)
            
            mapView.addAnnotation(garageL)
        default:
            print("error")
        }
    }
}

// This extension will handle the check if time is within 30 mins and the solution if its true
extension  FindConfirmViewController: CLLocationManagerDelegate{
    

    func openMapsAppWithDirections(to coordinate: CLLocationCoordinate2D, destinationName name: String) {
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name // Provide the name of the destination in the To: field
        mapItem.openInMaps(launchOptions: options)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("New location is \(location)")
            
            DBProvider.Instance.startRide(withPassengerKey: passengerKey!, dlatitude: location.coordinate.latitude, dlongitude: location.coordinate.longitude)
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
        // you're good to go!
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    
    
    //compares current time and date with requests time and date
    func checkTimeStamp(date: String!) -> Bool {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/dd/yyyy, h:mm a"
        dateFormatter.locale = Locale(identifier:"en_US_POSIX")
        let datecomponents = dateFormatter.date(from: date)
        let datecomponentswith30 = datecomponents?.addingTimeInterval(TimeInterval(-30.0 * 60.0))
        let now = Date()

        if (now >= datecomponentswith30! && now < datecomponents!) {
            return true
        } else {
            return false
        }
    }
}
