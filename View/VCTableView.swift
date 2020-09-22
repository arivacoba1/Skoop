//
//  VCTableView.swift
//  SchoolLift
//
//  Created by Adrian Rivacoba on 5/27/18.
//  Copyright © 2018 TBD. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class VCTableView: UITableView {

    var ref: Database
    
    let cellId = "cellId"
    
    func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        fetchUsers()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        return cellId
        
    }
    func fetchUsers(){
        
    }
}
