//
//  request.swift
//  SchoolLift
//
//  Created by Adrian Rivacoba on 5/27/18.
//  Copyright © 2018 TBD. All rights reserved.
//

import Foundation


class request: NSObject {
    var request: String?
    var name: String?
    var longitude: String?
    var latitude: String?
    var time: String?
    var garage: String?
    
    init (dictionary: [String: Any]) {
        super.init()
        name = dictionary["name"] as? String
        longitude = dictionary["longitude"] as? String
        latitude = dictionary["latitude"] as? String
        time = dictionary["time"] as? String
        garage = dictionary["place"] as? String
    }
}

