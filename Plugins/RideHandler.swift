//
//  RideHandler.swift
//  SchoolLift
//
//  Created by Adrian Rivacoba on 5/11/18.
//  Copyright © 2018 TBD. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol RideController: class {
    
    func updateDriverLocation(latitude: Double, longitude: Double, driverKey: String)
    
}

class active {
    var active: String?
    var drivers: String?
    
    init (active: String?, drivers: String?){
        self.active = active
        self.drivers = drivers
    }
}

class RideHandler {
    private static  let _instance = RideHandler()
    
    weak var delegate: RideController?
    
    var rider = ""
    var driver = ""
    var rider_id = ""

    static var Instance: RideHandler {
        return _instance
    }
    
    
    func requestRide(time: String,date: String, longitude: Double, latitude: Double, garage: String, isActivated: String) {
        let data : Dictionary<String, Any> = [Constants.NAME: rider, Constants.TIME: time, Constants.DATE: date, Constants.LATITUDE: latitude, Constants.LONGITUDE: longitude, Constants.GARAGE: garage, Constants.isActivated: isActivated]
        
        DBProvider.Instance.RequestRef.childByAutoId().setValue(data)
    }

    
    func updateDriverLocation(latitude: Double, longitude: Double, driverKey: String) {
        let data : Dictionary<String, Any> = [Constants.DLATITUDE: latitude, Constants.DLONGITUDE: longitude]
        DBProvider.Instance.RequestRef.child(driverKey).setValue(data)
    }

}
