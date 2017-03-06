//
//  TaskDetailViewController.swift
//  EfreiApp
//
//  Created by Paul Bénéteau on 28/02/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import UIKit
import EventKit


class TaskDetailViewController: UIViewController {

    
    @IBOutlet weak var taskTypeLabel: UILabel!
    @IBOutlet weak var taskDateLabel: UILabel!
    @IBOutlet weak var taskDistanceLabel: UILabel!
    @IBOutlet weak var taskAddressLabel: UILabel!
    
    var address: String = ""
    var task: String = ""
    var date: String = ""
    var distance: Double = 0.0
    var nsDate: String = ""
    
    let df: DateFormatter = DateFormatter()
    
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
            nsDate = (detailTask.nsDate!)
        }
    }
    
    @IBAction func declineButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func acceptTaskButton(_ sender: Any) {
        /*let newString = address.replacingOccurrences(of: " ", with: "+")
        let URL = "http://maps.apple.com/?address=\(newString)"
        openMap(scheme: URL)
         */
        let calendar = NSCalendar.current
        
        let description = "Address: \(address)"
        let beginDateString = self.nsDate
        
        
        df.dateFormat = "yyyy-MM-dd hh:mm:ss Z"
        print(beginDateString)
        let beginDate = df.date(from: beginDateString)
        while beginDate == nil {
           print("nil")
        }
        
        let endDate = calendar.date(byAdding: .hour, value: 2, to: beginDate!)
        
        print("Adding to calendar")
        
        addEventToCalendar(title: task, description: description, startDate: beginDate!, endDate: endDate!)
    }
    
    func openMap(scheme: String) {        
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
    
    func addEventToCalendar(title: String, description: String?, startDate: Date, endDate: Date, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                let event = EKEvent(eventStore: eventStore)
                event.title = title
                event.startDate = startDate as Date
                event.endDate = endDate as Date
                event.notes = description
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let e as NSError {
                    completion?(false, e)
                    return
                }
                completion?(true, nil)
            } else {
                completion?(false, error as NSError?)
            }
        })
    }
}
