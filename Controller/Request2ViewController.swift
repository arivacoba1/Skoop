//
//  Request2ViewController.swift
//  SchoolLift
//
//  Created by Adrian Rivacoba on 8/14/18.
//  Copyright © 2018 TBD. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

////import Contacts
//
//protocol ride {
//    func didTapPickUp(pickuplocationlatitude: Double, pickuplocationlongitude: Double)
//}

class Request2ViewController: UIViewController, CLLocationManagerDelegate {

    @IBAction func unwindtotwo(_ sender: UIStoryboardSegue) {
        
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        if AuthProvider.Instance.logOut() {
            dismiss(animated: true, completion: nil)
        } else {

        }
    }
    
    var garage = ""
    
//    var ride: ride? = nil
    
    var annotation = MKPointAnnotation()
    var garageL = MKPointAnnotation()

    @IBOutlet weak var customNavigationBar: UINavigationBar!
    
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private var riderLocation: CLLocationCoordinate2D?
    private var pointCoordinate: CLLocationCoordinate2D?
    private var location1: CLLocationCoordinate2D?
    private var region1: MKCoordinateRegion?
    
    @IBOutlet weak var Confirmb: UIButton!
    @IBOutlet weak var labelselect: UILabel!
    @IBOutlet weak var Xb: UIButton!
    
    
    @IBOutlet weak var tabbarbackground: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.Confirmb.isHidden = true
        self.Xb.isHidden = true
        self.labelselect.isHidden = true
        
        initializeLocationManager()
        //sets up navigation bar
        self.tabbarbackground.backgroundColor = color.realblue
        self.customNavigationBar.barTintColor = .clear
        self.customNavigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.customNavigationBar.shadowImage = UIImage()
        self.customNavigationBar.isTranslucent = true
        self.customNavigationBar.clipsToBounds = true
        
        alertUser()

        mapView.delegate = self

        
        addPickedGarage()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressMap(sender:)))
        longPressGesture.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(longPressGesture)
        
    }
    
    @IBAction func Confirmb(_ sender: Any) {
        self.performSegue(withIdentifier: "ConfirmSegue", sender: self)
    }
    
    @IBAction func Xb(_ sender: Any) {
     //   self.RMap.removeAnnotation(annotation)
        self.labelselect.isHidden = true
        self.Xb.isHidden = true
        self.Confirmb.isHidden = true
    }
    
    
    @objc func didLongPressMap(sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: mapView)
            let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            
            self.Confirmb.isHidden = false
            self.Confirmb.backgroundColor = color.realgold
            self.Confirmb.layer.cornerRadius = 10
            self.Xb.isHidden = false
            self.labelselect.isHidden = false
            self.labelselect.text = "Pickup Spot Selected!"

            annotation.coordinate = touchCoordinate
            annotation.title = "Pick Up Here"
            annotation.subtitle = ""
            self.mapView.addAnnotation(annotation) //drops the pin
           
            // Add below code to get address for touch coordinates.
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                
                // Place details
                var placeMark: CLPlacemark!
                placeMark = placemarks?[0]
                
                // Location name

                // Street address
                if let street = placeMark.thoroughfare {
                    print(street)
                    self.annotation.subtitle = "\(street)"
                }
                // City
                if let city = placeMark.subAdministrativeArea {
                    print(city)
                }
                // Zip code
                if let zip = placeMark.isoCountryCode {
                    print(zip)
                }
                // Country
                if let country = placeMark.country {
                    print(country)
                }
            })
        }
    }
    
    private func initializeLocationManager() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // if we have the coordinates from the manager
        if let location = locationManager.location?.coordinate {
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            
            mapView.setRegion(region, animated: true)
    
            annotation.coordinate = userLocation!
            annotation.title = "Drivers Location"
            mapView.addAnnotation(annotation)
            
            locationManager.stopUpdatingLocation()
        }
    }
    
    func addPickedGarage() {
        switch garage {
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "ConfirmSegue":
                let controller = segue.destination as! RequestConfirmViewController
                controller.pickuplocation = self.annotation
                controller.garagelocation = self.garageL
                if controller.garagename.isEmpty == true {
                print("garagename is nil")
                } else {
                    controller.garagename = self.garageL.title!
                }
            default:
                print("error")
            }
        }
    }
}

extension Request2ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isMember(of: MKUserLocation.self) {
            return nil
        }
        
        let reuseId = "MKAnnotationView"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)}
        pinView!.canShowCallout = true
        pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        pinView!.image = UIImage(named: "icons8-marker") // make sure this name is the name of image
        
        return pinView

    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("the annotation was selected")
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let title = "Confirm"
        let message = "Click to Confirm Your Pick Up Location"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        
        let accept = UIAlertAction(title: "Accept", style: .default, handler: {(alertAction: UIAlertAction) in
        self.performSegue(withIdentifier: "ConfirmSegue", sender: self)

        })
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(accept)
        alert.addAction(cancel)

        present(alert, animated: true,completion: nil)

    }
    
    func alertUser() {
        let title = "Pick Up Spot"
        let message = "Where do you want to be picked up at?"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        
        let accept = UIAlertAction(title: "OK, Let Me Choose!", style: .default, handler: nil)

        
        alert.addAction(accept)

        
        present(alert, animated: true,completion: nil)    }
    
}

