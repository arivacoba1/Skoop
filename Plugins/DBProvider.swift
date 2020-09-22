//
//  DBProvider.swift
//  SchoolLift
//
//  Created by Adrian Rivacoba on 5/10/18.
//  Copyright © 2018 TBD. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DBProvider {
    private static let _instance = DBProvider()
    
    static var Instance: DBProvider {
        return _instance
    }
    
    var dbRef: DatabaseReference {
        return Database.database().reference()
    }
    
    var RequestRef: DatabaseReference {
        return dbRef.child(Constants.REQUEST)
    }
    
//    var RequestAcceptedRef: DatabaseReference {
//        return dbRef.child(Constants.REQUEST_ACCEPTED)
//    }
   
    
    func saveUser(withID: String, email: String, password: String) {
        let data: Dictionary<String, Any> = [Constants.EMAIL: email, Constants.PASSWORD: password, Constants.isActive: true]
        
        dbRef.child(Constants.USERS).child(withID).child(Constants.DATA).setValue(data)
        
    }
    
    func acceptTrip(withPassengerKey passengerKey: String, andDriverKey driverKey: String) {
        dbRef.child("Request").child(passengerKey).child("isActivated").observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.value as! String == "true" {
                self.dbRef.child("Request").child(passengerKey).updateChildValues([Constants.FINDERS: driverKey, Constants.TRIP_IS_ACCEPTED: true])
                self.dbRef.child("Users").child(driverKey).child("data").updateChildValues([Constants.DRIVER_ON_TRIP: true])
                self.dbRef.child("Users").child(driverKey).child("data").updateChildValues([Constants.REQUEST_KEY:"\(passengerKey)"])

            }
        }
    }
    
    func startRide(withPassengerKey passengerKey: String, dlatitude: Double, dlongitude: Double) {
        dbRef.child("Request").child(passengerKey).child("isActivated").observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.value as! String == "true" {
                self.dbRef.child("Request").child(passengerKey).updateChildValues([Constants.DLATITUDE: dlatitude, Constants.DLONGITUDE: dlongitude])
                
            }
        }
        
    }
}
