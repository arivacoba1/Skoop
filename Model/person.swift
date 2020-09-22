//
//  person.swift
//  SchoolLift
//
//  Created by Dylan Dakil on 4/21/18.
//  Copyright © 2018 TBD. All rights reserved.
//

import Foundation

class person {
    
    private var _name = "Name"
    private var _lastName = "Last Name"
    
    var name: String {
        get {
            return _name
        }
        set {
            _name = newValue
        }
    }
    
    var lastName:String {
        get {
            return _lastName
        }
        set {
            _lastName = newValue
        }
    }
    
    func getwholeName() -> String {
        return "\(name) \(lastName)"
    }
    
    
}
