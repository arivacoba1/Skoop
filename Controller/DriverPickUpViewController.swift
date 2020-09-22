//
//  DriverPickUpViewController.swift
//  SchoolLift
//
//  Created by Adrian Rivacoba on 10/3/18.
//  Copyright © 2018 TBD. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class DriverPickUpViewController: UIViewController, MKMapViewDelegate {
    
    let uid = Auth.auth().currentUser?.uid
    let ref = Database.database().reference()
    var testbutton = 1
    @IBOutlet weak var ButtonLabel: UIButton!
    var garagename: String!
    var garageL = MKPointAnnotation()
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    @IBAction func ConfirmPickUp(_ sender: Any) {
        
        // testbutton = 1 means the user needs to pick up first
        // testbutton = 2 means the user has picked up and is going to start heading to garage
        
        if testbutton == 1 {
            //update global variable vcadcontroller
            SingleAppDelegate.sharedInstance.vcadcontroller = 2
            
            //let firebase know that user has been picked up

            ref.child("Users").child(uid!).child("data").observeSingleEvent(of: .value, with: {(snapshot) in
                if let dictionary = snapshot.value as? [String:AnyObject] {
                    if let requestkey = dictionary["requestkey"] as? String {
                        self.ref.child("Request").child(requestkey).updateChildValues([Constants.PICKED_UP: true])
                        
            //pull garage information from firebase
                        
                        self.ref.child("Request").child(requestkey).observeSingleEvent(of: .value, with: {(snapshot) in
                             if let dictionary = snapshot.value as? [String:AnyObject] {
                                if let garage = dictionary["garage"] as? String {
                                    self.garagename = garage
                                }
                            }
                        })
                    }
                }
            })
        
            alertUser()
            testbutton = 2
            self.ButtonLabel.setTitle("Directions to car spot", for: .normal)
        
        } else if testbutton == 2 {
            addPickedGarage()
        //seugue to garage with directions here (might not have to for testrun)
            let destinationName = (garagename ?? nil) ?? "Pick Up Location"
            openMapsAppWithDirections(to: garageL.coordinate, destinationName: destinationName)
        
        //segue to DropOffViewController in the background simultanous with directions
            performSegue(withIdentifier: "DropOffsegue", sender: self)
        } else {
            print("something went wrong with Pickupbutton")
        }
    }
    func alertUser() {
        let title = "You've picked them up"
        let message = "Now take them to their car spot to drop them off!"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        
        let accept = UIAlertAction(title: "OK!", style: .default, handler: nil)
        
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
    
    func addPickedGarage() {
        switch garagename {
        case "Speck Garage":
            garageL.title = "Speck Garage"
            garageL.coordinate = CLLocationCoordinate2D(latitude: 29.890803, longitude: -97.953118)

        case "Coliseum/Bobcat Stadium":
            
            garageL.title = "Coliseum/Bobcat Stadium"
            garageL.coordinate = CLLocationCoordinate2D(latitude: 29.889558, longitude: -97.930249)

        case "Sessom Lot":
            
            garageL.title = "Sessom Lot"
            garageL.coordinate = CLLocationCoordinate2D(latitude: 29.891028, longitude:  -97.937063)

        case "James Lot":
            
            garageL.title = "James Lot"
            garageL.coordinate = CLLocationCoordinate2D(latitude: 29.887928, longitude: -97.948513)

        case "Sewell North":
            
            garageL.title = "Sewell North"
            garageL.coordinate = CLLocationCoordinate2D(latitude: 29.889414, longitude: -97.933227)
            

        default:
            print("error")
        }
    }
}
