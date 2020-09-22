//
//  YourRidesViewController.swift
//  SchoolLift
//
//  Created by Adrian Rivacoba on 8/30/18.
//  Copyright © 2018 TBD. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAnalytics
import MapKit

class RidesRequestedd {
    var latitude: Double?
    var longitude: Double?
    var name: String?
    var garage: String?
    var time: String?
    var key: String?
    
    init (name: String?, garage: String?, time: String?, latitude: Double?, longitude: Double?, key: String) {
        self.garage = garage
        self.time = time
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.key = key
    }
    
}

class  pickuprequested {

    var time: String?

    init (time: String?) {
        self.time = time
    }
}

class YourRidesViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var rideslabel: UILabel!
    @IBOutlet weak var timelabel: UILabel!
    @IBOutlet weak var customNavigationBar: UINavigationBar!
    
    
    var ref: DatabaseReference!
    var frequests1 = [RidesRequestedd]()
    


    @IBOutlet weak var gtr: UIButton!
    var fnamefinal: String?
    var cnamefinal: String?

    var name: String?
    var email: String?
    var latitude: Double?
    var longitude: Double?
    var userlocation = MKPointAnnotation()
    var test = 0
    var timeanddate: String?
    
    var passengerKey: String?

    let locationManager = CLLocationManager()
    var userLocationDriver:CLLocation!
    
    @IBAction func DeleteButton(_ sender: Any) {
        
        let uid = Auth.auth().currentUser?.uid
        
        Database.database().reference().child("Users").child(uid!).child("data").observeSingleEvent(of: .value, with: {(snapshot) in
        if let dictionary = snapshot.value as? [String:AnyObject] {
        
        self.fnamefinal = dictionary["email"] as? String
        if self.fnamefinal != nil {
            self.ref.child("Request").observe(.childAdded, with: { (snapshot) in
        
                let results = snapshot.value as? [String : AnyObject]
                let name = results?["name"]
                let key = snapshot.key
            
                if name as! String? == self.fnamefinal {
                    self.ref.child("Request").child(key).removeValue()
                
                        }
                    })
                }
            }
        })
        
        performSegue(withIdentifier: "seguehome", sender: self)
    }
    
    @IBAction func gotoride(_ sender: Any) {
        
        //this one is for the driver looking to pick up and within 30 minutes:
        if test == 2 && self.checkTimeStamp(date: timeanddate) == true {
            if passengerKey != nil {
        // give the SingletonAppDelegate variable a number to control from app delegate
                SingleAppDelegate.sharedInstance.vcadcontroller = 1

        //start location updates
            locationManager.delegate = self
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.requestAlwaysAuthorization()
                
        //start geofence for request pick up location
            let geofenceRegionCenter = CLLocationCoordinate2DMake(userlocation.coordinate.latitude, userlocation.coordinate.longitude)
            let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter,
                                                      radius: 50,
                                                      identifier: "UniqueIdentifier")
            geofenceRegion.notifyOnEntry = true
            geofenceRegion.notifyOnExit = true
            
            locationManager.startMonitoring(for: geofenceRegion)
        
                
        //segue to maps
            let destinationName = (userlocation.title ?? nil) ?? "Pick Up Location"
            openMapsAppWithDirections(to: userlocation.coordinate, destinationName: destinationName)
            } else {
               print("passengerKey is nil")
            }
        }
            
        //this next one is for the rider waiting for a ride and within 30 minutes:
        else if test == 1 && self.checkTimeStamp(date: timeanddate) == true {
                self.performSegue(withIdentifier: "Rider", sender: self)
            
            // give the SingletonAppDelegate variable a number to control from app delegate
            SingleAppDelegate.sharedInstance.vcadcontroller = 4
        }
            
        // no request or accepted requests:
        else if test == 0 {
            print("no request or accepted request")
        }
            
        // Not within 30 minutes:
        else {
            UserTimeAlert()
        }
    
    }
    
    func UserTimeAlert() {
        let title = "Not yet"
        let message = "You can start your trip up to 30 minutes before the request time"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        
        let accept = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(accept)
        
        present(alert, animated: true,completion: nil)
        
    }
    
    func openMapsAppWithDirections(to coordinate: CLLocationCoordinate2D, destinationName name: String) {
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name // Provide the name of the destination in the To: field
        mapItem.openInMaps(launchOptions: options)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //adds custom navigation bar
        self.customNavigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.customNavigationBar.shadowImage = UIImage()
        self.customNavigationBar.isTranslucent = true
        self.customNavigationBar.clipsToBounds = true
        
        ref = Database.database().reference()
        
        checkIfUserIsLoggedIn()

    }

    /*
     This next function does a couple things:
        - Checks to see if user is logged in
        - Checks to see if user is the driver or rider
    */
    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
        } else {
            let uid = Auth.auth().currentUser?.uid
        
            ref.child("Users").child(uid!).child("data").observeSingleEvent(of: .value, with: {(snapshot) in
                if let dictionary = snapshot.value as? [String:AnyObject] {
        
                    self.fnamefinal = dictionary["email"] as? String
                    if self.fnamefinal != nil {
                        self.ref.child("Request").observe(.childAdded, with: { (snapshot) in
                           
                            let results = snapshot.value as? [String : AnyObject]
                            let name = results?["name"]
                            let garage = results?["garage"]
                            let time = results?["time"] as! String
                            let latitude = results?["latitude"]
                            let longitude = results?["longitude"]
                            let key = snapshot.key
                            let driver = results?["drivers"]
                            let date = results?["date"] as! String
                            
                            let dateandtime = "\(date), \(time)"

                            //checks all requests for name to see if there is an active request
                            if name as! String? == self.fnamefinal {
                                
                                self.timeanddate = dateandtime
                                self.test = 1
                                let myCalls = pickuprequested(time: time)
                                self.rideslabel.text = "You are getting picked up"
                                self.timelabel.text = myCalls.time
                                

                            //this one checks to see if there is an active accepted request where you are the driver
                            } else if driver as! String? == uid {
                                
                                self.timeanddate = dateandtime
                                self.test = 2
                                let myCalls = RidesRequestedd(name: name as! String?, garage: garage as! String?, time: time as String?, latitude: latitude as! Double?, longitude: longitude as! Double?, key: (key as String?)!)
                                self.frequests1.append(myCalls)
                                self.rideslabel.text = myCalls.garage
                                self.timelabel.text = myCalls.time
                                self.latitude = myCalls.latitude
                                self.longitude = myCalls.longitude
                                self.passengerKey = myCalls.key
                                self.userlocation.coordinate = CLLocationCoordinate2D(latitude: latitude! as! CLLocationDegrees, longitude: longitude! as! CLLocationDegrees)
                            }
                        })
                    }
                }
            })
        }
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

extension YourRidesViewController: CLLocationManagerDelegate {
    
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
    
}

