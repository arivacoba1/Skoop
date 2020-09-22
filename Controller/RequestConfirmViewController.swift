//
//  RequestConfirmViewController.swift
//  SchoolLift
//
//  Created by Adrian Rivacoba on 8/20/18.
//  Copyright © 2018 TBD. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase
import FirebaseAuth

class RequestConfirmViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var requestbutton: UIButton!
    
    @IBOutlet weak var garagenamelabel: UILabel!
    @IBAction func back(_ segue: UIStoryboardSegue) {
    }
    
    var garagename = ""
    var fnamefinal: String?
    var pickuplocation = MKPointAnnotation()
    var garagelocation = MKPointAnnotation()

    let locationManager = CLLocationManager()
    
    let timePicker = UIDatePicker()
    let datePicker = UIDatePicker()
    

    @IBOutlet weak var tabbarbackground: UIImageView!
    

    @IBOutlet weak var customNavigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Sets up navigation bar
        self.customNavigationBar.barTintColor = .clear
        self.tabbarbackground.backgroundColor = color.realblue
        self.customNavigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.customNavigationBar.shadowImage = UIImage()
        self.customNavigationBar.isTranslucent = true
        self.customNavigationBar.clipsToBounds = true

        //loads date picker
        showDatePicker()
        
        //loads time picker
        showTimePicker()
        
        //check to see if you have an active request:
        checkUser()
        
        //convert request spot from coordinates to address:
        convertcoordinates()
        
        //set the garage name to the picked garage from last view controller
        garagenamelabel.text = garagename

    }
    
    @IBAction func RequestConfirmButton(_ sender: Any) {
        
        //check to see if time and date are not nil (eventually we need a better check than just "")
        if txtTimePicker.text != "" && txtDatePicker.text != "" {
            RideHandler.Instance.requestRide(time: String(txtTimePicker.text!),date: String(txtDatePicker.text!), longitude: Double(pickuplocation.coordinate.longitude), latitude: Double(pickuplocation.coordinate.latitude), garage: String(garagename), isActivated: String("false"))
            // segue exists in main storyboard to yourRidesviewcontroller

            } else {
            let alert = UIAlertController(title: "Pick a Time and Date", message: "", preferredStyle: .alert)
            let accept = UIAlertAction(title: "Accept", style: .default, handler: nil)

            alert.addAction(accept)

            present(alert, animated: true,completion: nil)

        }
    }
    
    func convertcoordinates() {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: pickuplocation.coordinate.latitude, longitude: pickuplocation.coordinate.longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Location name
            
            // Street address

            if let street = placeMark.thoroughfare {
                print(street)
                self.label1.text = "\(street)"
            }
            
            if let zip = placeMark.postalCode {
                self.label2.text = "\(zip)"
            }
            // City
            if let city = placeMark.subAdministrativeArea {
                print(city)
                self.label2.text = "\(city)"
            }
            
        })
    }
    
    @IBOutlet weak var txtTimePicker: UITextField!
    @IBOutlet weak var txtDatePicker: UITextField!
    
    func showDatePicker(){
        //Format Date
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        txtDatePicker.inputAccessoryView = toolbar
        txtDatePicker.inputView = datePicker
        
    }
    func showTimePicker(){
        //Format Time
        timePicker.datePickerMode = .time
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donetimePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        txtTimePicker.inputAccessoryView = toolbar
        txtTimePicker.inputView = timePicker
        
    }
    
    @objc func donetimePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        txtTimePicker.text = formatter.string(from: timePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M/dd/yyyy"
        txtDatePicker.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }

    
    func checkUser() {
        let uid = Auth.auth().currentUser?.uid
        
        Database.database().reference().child("Users").child(uid!).child("data").observeSingleEvent(of: .value, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                
                self.fnamefinal = dictionary["email"] as? String
                if self.fnamefinal != nil {
                    Database.database().reference().child("Request").observe(.childAdded, with: { (snapshot) in
                        let results = snapshot.value as? [String : AnyObject]
                        let name = results?["name"]
                        
                        if name as! String? == self.fnamefinal {
                            print("it worked homie")
                            let alert = UIAlertController(title: "You have Request", message: "You have an active request", preferredStyle: .alert )
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                                self.performSegue(withIdentifier: "YourRides2", sender: self)
                                })
                            )
                            self.present(alert, animated: true)
                        }
                    })
                }
            }
        })
    }
}



