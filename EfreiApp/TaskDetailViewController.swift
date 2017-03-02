//
//  TaskDetailViewController.swift
//  EfreiApp
//
//  Created by Paul Bénéteau on 28/02/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController {

    
    @IBOutlet weak var taskTypeLabel: UILabel!
    @IBOutlet weak var taskDateLabel: UILabel!
    @IBOutlet weak var taskDistanceLabel: UILabel!
    @IBOutlet weak var taskAddressLabel: UILabel!
    
    var address: String = ""
    var task: String = ""
    var date: String = ""
    var distance: Double = 0.0
    
    var detailTask: asksArround? {
        didSet {
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureView() {

        
        if let detailTask = detailTask {
            
            if let typeLabel = taskTypeLabel, let dateLabel = taskDateLabel, let distanceLabel = taskDistanceLabel, let addressLabel = taskAddressLabel {
                typeLabel.text = detailTask.type
                dateLabel.text = detailTask.date
                distanceLabel.text = "\(Int(detailTask.distance!))m"
                addressLabel.text = detailTask.address
            }
            address = (detailTask.address!)
            task = (detailTask.type!)
            date = (detailTask.date!)
            distance = (detailTask.distance!)
            print(address)
            print(task)
            print(date)
            print(distance)
        }
    }

    @IBAction func closeButton(_ sender: Any) {

        dismiss(animated: true, completion: nil)
    }

    @IBAction func routefromAdressButton(_ sender: Any) {
        let newString = address.replacingOccurrences(of: " ", with: "+")
        let URL = "http://maps.apple.com/?address=\(newString)"
        openMap(scheme: URL)
    }
    
    func openMap(scheme: String) {
        print(scheme)
        
        if let url = URL(string: scheme) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                                            print("Open \(scheme): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(scheme): \(success)")
            }
        }
    }
    
}
