//
//  SingletonAppDelegate.swift
//  SchoolLift
//
//  Created by Adrian Rivacoba on 1/18/19.
//  Copyright © 2019 TBD. All rights reserved.
//

import Foundation

class SingleAppDelegate: NSObject {
    
    var vcadcontroller = 0
    
    static let sharedInstance = SingleAppDelegate()

    
    private override init() {
        super.init()
    }
}
