//
//  RequestVC.swift
//  SchoolLift
//
//  Created by Adrian Rivacoba on 5/9/18.
//  Copyright © 2018 TBD. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth
import CoreLocation
import UserNotifications


class RequestVC: UIViewController {

    var garagetext = ""
    var fname:String?
    var ref: DatabaseReference!
    var fnamefinal:String?

    @IBOutlet weak var instruction: UILabel!
    @IBOutlet weak var RMap: MKMapView!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var Xlabel: UIButton!
    @IBOutlet weak var Confirm: UIButton!
    
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private var riderLocation: CLLocationCoordinate2D?
    
    var annotation = MKPointAnnotation()
    
    private var authUser : User? {
        return Auth.auth().currentUser
    }
    
    public func sendVerificationMail() {
        if self.authUser != nil && !self.authUser!.isEmailVerified {
            self.authUser!.sendEmailVerification(completion: { (error) in
                // Notify the user that the mail has sent or couldn't because of an error.
                print(error as Any)
                print("couldnt send verification email")
            })
        }
    }
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.Confirm.isHidden = true
        self.Xlabel.isHidden = true
        self.leftLabel.isHidden = true
        self.addLogout()
        
        self.titleLabel.textColor = color.realblue
        self.titleLabel.backgroundColor = .clear

        self.view.clipsToBounds = true
    
        //sets up instructions for 20 seconds
        self.instruction.layer.cornerRadius = 10
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            self.instruction.isHidden = true
        }

        
        RMap.delegate = self
        
        getlocation()
        
        //adds ability to drop pin on map
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressMap(sender:)))
        longPressGesture.minimumPressDuration = 1.0
        self.RMap.addGestureRecognizer(longPressGesture)
        
        //adds garage locations
        let Garage1Point = MKPointAnnotation()
        Garage1Point.title = "Speck Garage"
        Garage1Point.coordinate = CLLocationCoordinate2D(latitude: 29.890803, longitude: -97.953118)
        RMap.addAnnotation(Garage1Point)
        let Garage2Point = MKPointAnnotation()
        Garage2Point.title = "Coliseum/Bobcat Stadium"
        Garage2Point.coordinate = CLLocationCoordinate2D(latitude: 29.889558, longitude: -97.930249)
        RMap.addAnnotation(Garage2Point)
        let Garage3Point = MKPointAnnotation()
        Garage3Point.title = "Sessom Lot"
        Garage3Point.coordinate = CLLocationCoordinate2D(latitude: 29.891028, longitude:  -97.937063)
        RMap.addAnnotation(Garage3Point)
        let Garage4Point = MKPointAnnotation()
        Garage4Point.title = "James Lot"
        Garage4Point.coordinate = CLLocationCoordinate2D(latitude: 29.887928, longitude: -97.948513)
        RMap.addAnnotation(Garage4Point)
        let Garage5Point = MKPointAnnotation()
        Garage5Point.title = "Sewell North"
        Garage5Point.coordinate = CLLocationCoordinate2D(latitude: 29.889414, longitude: -97.933227)
        RMap.addAnnotation(Garage5Point)
        
        //asks for authorization to send notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in
            
        })
        
        //checks to see if user already has a ride or pickup
        waitingForRide()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            
            if identifier == "PickedCar" {
                let controller = segue.destination as! Request2ViewController
                controller.garage = self.garagetext
            }
        }
    }

    @IBAction func logout(_ sender: Any) {
        if AuthProvider.Instance.logOut() {
            dismiss(animated: true, completion: nil)
        } else {

        }
    }
    
    @objc func logoutUser(){
   
    }
    
    //removes leftLabel and its memory
    @IBAction func Xlabelf(_ sender: Any) {
        
        self.RMap.removeAnnotation(annotation)
        self.leftLabel.isHidden = true
        self.Xlabel.isHidden = true
        self.Confirm.isHidden = true
    }
    
    @IBAction func ConfirmB(_ sender: Any) {
        self.performSegue(withIdentifier: "PickedCar", sender: self)
    }
    
    func addLogout() {
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 340, y: 70, width: 40, height: 40)
            button.layer.cornerRadius = 0.5 * button.bounds.size.width
            button.layer.masksToBounds = true
            button.layer.backgroundColor = UIColor.white.cgColor
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.white.cgColor
            button.setImage(UIImage(named:"logout"), for: .normal)
            button.addTarget(self, action: #selector(logoutUser), for: .touchUpInside)
            view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = true
        let horizontalConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute:NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)

        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint])
            }
    //right now, just checks if a ride or request is active with user and sends them to YourRidesViewController
    func waitingForRide() {
        let uid = Auth.auth().currentUser?.uid

        Database.database().reference().child("Users").child(uid!).child("data").observeSingleEvent(of: .value, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let isActive = dictionary["isActive"] as? Bool
                let isOnRide = dictionary["driverIsOnTrip"] as? Bool

                if isActive == false {
                    self.waitingForRideTrue()
                } else if isOnRide == true {
                    self.pickupP()
                }
            }
        })
    }
    
    func waitingForRideTrue() {
        performSegue(withIdentifier: "YourRides", sender: self)
    }
    
    func pickupP() {
        performSegue(withIdentifier: "YourRides", sender: self)
    }
    
}

extension RequestVC: MKMapViewDelegate {
    
    @objc func didLongPressMap(sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: RMap)
            let touchCoordinate = RMap.convert(touchPoint, toCoordinateFrom: self.RMap)
            
            self.Confirm.isHidden = false
            self.Confirm.backgroundColor = color.realgold
            self.Confirm.layer.cornerRadius = 10
            self.Xlabel.isHidden = false
            self.leftLabel.isHidden = false
            self.leftLabel.text = "Car Spot Picked!"
            annotation.coordinate = touchCoordinate
            annotation.title = "My car is here"
            annotation.subtitle = ""
            self.RMap.addAnnotation(annotation) //drops the pin
            
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
        
        
        if (annotation.title! == "My car is here") {
            anView?.image = UIImage(named: "icons8-car_filled")
            anView!.canShowCallout = true
            anView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            anView?.image = UIImage(named: "icons8-parking")
            anView!.canShowCallout = true
            anView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return anView
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let selectedAnnotation = view.annotation
        
        let title = "Confirm"
        let message = "Click to confirm this is where your car is parked!"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        
        let accept = UIAlertAction(title: "Accept", style: .default, handler: {(alertAction: UIAlertAction) in
            
            self.garagetext = (selectedAnnotation?.title!)!
            self.performSegue(withIdentifier: "PickedCar", sender: self)
            
        })
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(accept)
        alert.addAction(cancel)
        
        present(alert, animated: true,completion: nil)
        
    }
}

extension RequestVC: CLLocationManagerDelegate{
    
    func getlocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        self.userLocation = locValue

        let region = MKCoordinateRegion(center: locValue, span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04))
        
            RMap.setRegion(region, animated: true)
            locationManager.stopUpdatingLocation()
    }
}

extension UILabel {
    func applydesign() {
        self.backgroundColor = UIColor.darkGray
        self.layer.cornerRadius = self.frame.height/2
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
}

