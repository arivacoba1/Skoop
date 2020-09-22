//
//  DropOffViewController.swift
//  SchoolLift
//
//  Created by Adrian Rivacoba on 9/27/18.
//  Copyright © 2018 TBD. All rights reserved.
//

import UIKit
import Firebase

class DropOffViewController: UIViewController {
    
    let uid = Auth.auth().currentUser?.uid
    let ref = Database.database().reference()
    
    @IBAction func ConfrimDropOff(_ sender: Any) {
        //let firebase know drop off is confirmed AND finally able to remove request
        ref.child("Users").child(uid!).child("data").observeSingleEvent(of: .value, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                if let requestkey = dictionary["requestkey"] as? String {
                    self.ref.child("Request").child(requestkey).removeValue()
                }
            }
        })
        // make vcadcontroller = 0 or 3 when I finish the rating system
        SingleAppDelegate.sharedInstance.vcadcontroller = 0
        
        performSegue(withIdentifier: "driverdone", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
