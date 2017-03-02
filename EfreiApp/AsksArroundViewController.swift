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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initLocationDetails()
        fetchAsks(countryCode: "FR", state: "Île-de-France", distanceMax: 1000)
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initLocationDetails() {
        locationClass.updateUserLocation()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
    
        let task: asksArround
        task = tasksList[indexPath.row]
        
        cell.textLabel?.text = task.type
        cell.detailTextLabel?.text = task.date
        
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
        fetchAsks(countryCode: "FR", state: "Île-de-France", distanceMax: 1000)
        refreshControl.endRefreshing()
    }

    func fetchAsks(countryCode: String, state: String, distanceMax: Double) {
        
        self.tasksList.removeAll()
        
        refHande = ref.child("asks").child(countryCode).child(state).observe(.childAdded, with: { (snapshot) in
            
            if let dict = snapshot.value as? [String : [String:Any]] {
                
                for (_, value) in dict {
                    if let task = value["task"] as? String {
                        if let date = value["date"] as? String {
                            if let location = value["location"] as? String {
                                let ss = location.components(separatedBy: CharacterSet(charactersIn: "<,>")).flatMap({
                                    Double($0)
                                })
                                
                                let c = CLLocation(latitude: ss[0], longitude: ss[1])
                                print(c)
                                let distance: Double = self.locationClass.getLocationsDistance(location1: c, location2: self.locationClass.getLocation())
                                if distance <= distanceMax {
                                    let taskArray = asksArround(date: date, type: task, distanceBetweenUser: distance)
                                    self.tasksList.append(taskArray)
                                }
                            }
                        }
                    }
                }
                print(self.tasksList)
                self.tableView.reloadData()
            }
        })
    }
    

}
