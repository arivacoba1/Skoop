//
//  FindTableViewController.swift
//  SchoolLift
//
//  Created by Adrian Rivacoba on 8/22/18.
//  Copyright © 2018 TBD. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAnalytics

class RidesRequested {
    var latitude: Double?
    var longitude: Double?
    var name: String?
    var garage: String?
    var time: String?
    var isactivated: String?
    var key: String?
    var date: String?
    var timeanddate: String?
    
    init (garage: String?, time: String?, latitude: Double?, longitude: Double?, isactivated: String?, key: String?, date: String?, timeanddate: String?) {
        self.garage = garage
        self.time = time
        self.latitude = latitude
        self.longitude = longitude
        self.isactivated = isactivated
        self.key = key
        self.date = date
        self.timeanddate = timeanddate
    }
    
}
class FindTableViewController: UITableViewController {

    @IBOutlet weak var FindTableView: UITableView!
    
    
    //var ref: DatabaseReference!
    var refHandle: UInt!
    var frequests = [RidesRequested]()
    var myIndex = 0
    var key: String?
    
    let cellid = "cellId"
    
    @IBAction func unwindtoFind (_ sender: UIStoryboardSegue) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchuser()
        
        
        FindTableView.dataSource = self
        FindTableView.delegate = self

    }
 


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        // print(frequests.count)
        return frequests.count
        
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellid)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! FindCell
        
        let test = frequests[indexPath.row]
        
      //  print(test)
        
        cell.garagename?.text = test.garage
        cell.timelabel?.text = test.time
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      //  print(key!)

      //  print("You selected cell #\(indexPath.row)!")
        myIndex = indexPath.row
        performSegue(withIdentifier: "segue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   

        if let indexPath = FindTableView.indexPathForSelectedRow{
            let selectedRow = indexPath.row
            let detailVC = segue.destination as! FindConfirmViewController
            detailVC.garagename = frequests[selectedRow].garage
            detailVC.timestamp = frequests[selectedRow].time
            detailVC.latitude = frequests[selectedRow].latitude!
            detailVC.longitude = frequests[selectedRow].longitude!
            detailVC.passengerKey = frequests[selectedRow].key!
            detailVC.timeanddate = frequests[selectedRow].timeanddate!
        }
    }
    func fetchuser() {
                
        Database.database().reference().child("Request").observeSingleEvent(of: .value, with: {(snapshot) in
        if let dictionary = snapshot.value as? [String:AnyObject] {
                    
            for (key, value) in dictionary {
                
                            let garage = value["garage"]
                            let time = value["time"]
                            let latitude = value["latitude"]
                            let longitude = value["longitude"]
                            let isactivated = value["isActivated"]
                            let date = value["date"]
                            let dateandtime = "\(date), \(time)"
            
                let myCalls = RidesRequested(garage: garage as! String?, time: time as! String?, latitude: latitude as! Double?, longitude: longitude as! Double?, isactivated: isactivated as! String?, key: key as String?, date: date as! String?, timeanddate: dateandtime as String?)
                
                self.frequests.append(myCalls)
                self.key = myCalls.key
            
                
                      DispatchQueue.main.async {
                          self.FindTableView.reloadData()
                    }
                }
            }
        })
    }
    
    //compares current time and date with requests time and date (right now set to only date)
    func checkTimeStamp(date: String!) -> Bool {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/dd/yyyy"
 // for when we compare time AND date      dateFormatter.dateFormat = "M/dd/yyyy, h:mm a"
        dateFormatter.locale = Locale(identifier:"en_US_POSIX")
        let datecomponents = dateFormatter.date(from: date)
        
        if NSCalendar.current.isDate(Date(), equalTo: datecomponents!, toGranularity: .day) {
            return true
        } else {
            return false
        }
    }
}
