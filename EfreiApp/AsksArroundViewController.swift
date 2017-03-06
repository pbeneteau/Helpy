//
//  AsksArroundViewController.swift
//  EfreiApp
//
//  Created by Paul Bénéteau on 25/02/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class AsksArroundViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let ref = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    
    let locationClass = locationHelp()
    
    let cellId = "cellId"
    var refHande: UInt!
    
    var tasksList = [asksArround]()
    
    private let refreshControl = UIRefreshControl()
    
    private var countryCode: String?
    private var state: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initLocationDetails()
        
        tableView.backgroundColor = UIColor(red:0.90, green:0.36, blue:0.33, alpha:1.0)
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
        
    }
    
    func initLocationDetails() {
        
        locationClass.setLocation { success in
            if success {
                print("Done")
                self.initInfos()
            }
        }
    }
    
    func initInfos() {
        self.countryCode =  self.locationClass.getCountryCode()
        self.state = self.locationClass.getState()
        fetchAsks()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        
        let task: asksArround
        task = tasksList[indexPath.row]
        
        cell.backgroundColor = UIColor(red:1.00, green:0.39, blue:0.36, alpha:1.0)
        cell.textLabel?.text = task.type
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.text = task.date
        cell.detailTextLabel?.textColor = UIColor.white
        
        return cell
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "showTaskDetail" {
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = segue.destination as! TaskDetailViewController
                let task: asksArround
                task = tasksList[indexPath.row]
                controller.detailTask = task
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showTaskDetail", sender: indexPath);
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
    }
    
    func refreshData(sender: UIRefreshControl) {
        fetchAsks()
        refreshControl.endRefreshing()
    }
    
    func fetchAsks() {
        if (state == nil) || (countryCode == nil) {
            _ = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(fetchAsks), userInfo: nil, repeats: false);
            
        } else {
            self.tasksList.removeAll()
            
            refHande = ref.child("asks").child(self.countryCode!).child(self.state!).observe(.childAdded, with: { (snapshot) in
                
                if let dict = snapshot.value as? [String : [String:Any]] {
                    
                    for (_, value) in dict {
                        if let task: String = value["task"] as? String {
                            if let taskDate: String = value["date"] as? String {
                                if let taskLocation: String = value["location"] as? String {
                                    if let taskAddress: String = value["address"] as? String {
                                        if let nsdate: String = value["nsDate"] as? String {
                                            let ss = taskLocation.components(separatedBy: CharacterSet(charactersIn: "<,>")).flatMap({
                                                Double($0)
                                            })
                                            let c = CLLocation(latitude: ss[0], longitude: ss[1])
                                            let taskDistance: Double = self.locationClass.getLocationsDistance(location1: c, location2: self.locationClass.getLocation())
                                            if taskDistance <= 1000 {
                                                let taskArray = asksArround(date: taskDate, type: task, distance: taskDistance, address: taskAddress, nsDate: nsdate)
                                                self.tasksList.append(taskArray)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    
}
