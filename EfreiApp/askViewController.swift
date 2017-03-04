//
//  askViewController.swift
//  EfreiApp
//
//  Created by Paul Bénéteau on 24/02/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Firebase
import SwiftLocation
import NVActivityIndicatorView
import DateTimePicker
import EventKit

class askViewController: keyboardUtils, UIPickerViewDelegate, UIPickerViewDataSource, NVActivityIndicatorViewable {
   
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var priceField: UITextField!
    
    @IBOutlet weak var taskPicker: UIPickerView!
    @IBOutlet weak var selection: UILabel!
    
    // Variables
    var userAddress: String!
    var countryCode: String!
    var state: String!
    var userLocation: CLLocation!
    var homeLocation: CLLocation!
    var price: String!
    var taskSelected: String = ""
    var pickerData: [String] = [String]()
    var dateSelected: Date!
    
    // Classes
    let locationClass = locationHelp()
    let askClass = askHelp()
    
    // Firebase
    let ref = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    
    let eventStore : EKEventStore = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        initLocationDetails()
        getTaskList()
        initMapView()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        // Keyboard init
        addObservers()
        setDelegates(priceField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.delegate = self
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)

    }
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        stopAnimating()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func initLocationDetails() {
        
        locationClass.updateUserLocation()
        locationClass.retrieveUserDatabaseAdress(userID: (user?.uid)!) {
            
        }
        locationClass.coordinatesFromAdress()
    }
    
    // Map view initialisation
    func initMapView() {
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    // Force data fetch to end
    func initTaskPicker() {
    }
    
    // Task picker initialisation
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selection.text = pickerData[row]
        self.taskSelected = pickerData[row]
    }
    
    // Retrieve all tasks type from database
    func getTaskList() {
        
        let tasksRef = ref.child("tasks")
        tasksRef.observe(.value, with: {
            (snapshot) in
            for tasks in snapshot.children {
                self.pickerData.append((tasks as AnyObject).key)
            }
            self.initTaskPicker()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // Submit task request
    func sumbitTaskRequest(price: String, task: String, date: Date, address : String, location: CLLocation, countryCode: String, state: String) {
        
        if (askClass.checkUserLocationHome(currentLocation: userLocation, homeLocation: homeLocation) == true) {
            
            askClass.sendData(price: price, task: task, date: date, address: address, location: location, countryCode: countryCode, state: state, userIsAtHome: true)
            
        } else {
            
            let alert = UIAlertController(title: "Wait!", message: "You are making a request but you are not at home!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: {(alert:
                UIAlertAction!) in
                self.askClass.sendData(price: price, task: task, date: date, address: address, location: location, countryCode: countryCode, state: state, userIsAtHome: false)
                let alert2 = UIAlertController(title: "Save to calendar?", message: "Wanna save this event to your calendar?", preferredStyle: UIAlertControllerStyle.alert)
                alert2.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(alert:
                    UIAlertAction!) in
                    print("Adding to calendar")
                    let calendar = NSCalendar.current
                    let hoursAddedDate = calendar.date(byAdding: .hour, value: 2, to: date)
                    self.addEventToCalendar(title: task, description: address, startDate: date, endDate: hoursAddedDate!)
                    
                }))
                self.present(alert2, animated: true, completion: nil)
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(alert:
                UIAlertAction!) in
                print("Cancel pressed")
            }))
            alert.addAction(UIAlertAction(title: "Add address", style: UIAlertActionStyle.default, handler: {(alert:
                UIAlertAction!) in
                print("New address")
            }))

            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func helpButton(_ sender: Any) {
      
        userAddress = locationClass.getUserDatabaseAdress()
        countryCode = locationClass.getCountryCode()
        state = locationClass.getState()
        userLocation = locationClass.getLocation()
        homeLocation = locationClass.getUserHomeLocation()
        price = priceField.text
        
        if checkNilValues() == true {
            sumbitTaskRequest(price: priceField.text!, task: taskSelected, date: dateSelected, address: userAddress, location: userLocation, countryCode: countryCode, state: state)
        }
    }
    
    // Exit button
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func checkNilValues() -> Bool{
        
        let array = [userAddress, countryCode, state, taskSelected, price]
        for object in array {
            if object == nil {
                print("fill out all values!")
                return false
        }}
        if userLocation == nil{
            print("userLocation is empty")
            return false
        } else if homeLocation == nil{
            print("homeLocation is empty")
            return false
        } else if taskSelected == "" {
            print("taskSelected is empty")
            return false
        }
        return true
    }
    
    ///////////////////////////////////////////////
    @IBAction func datePicker(_ sender: Any) {
        dismissKeyboard()
        let picker = DateTimePicker.show()
        picker.highlightColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
        picker.completionHandler = { date in
            self.dateSelected = picker.selectedDate
        }
    }
    
    func messageAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
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
