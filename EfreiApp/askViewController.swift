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

class askViewController: keyboardUtils, UIPickerViewDelegate, UIPickerViewDataSource, NVActivityIndicatorViewable {
   
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var priceField: UITextField!
    
    @IBOutlet weak var taskPicker: UIPickerView!
    @IBOutlet weak var selection: UILabel!
    
    var userAddress: String!
    var countryCode: String!
    var state: String!
    var userLocation: CLLocation!
    var homeLocation: CLLocation!
    var price: String!
    var taskSelected: String = ""
    
    // Classes
    let locationClass = locationHelp()
    let askClass = askHelp()
    
    // Firebase
    let ref = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    
    // Variables
    var pickerData: [String] = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        taskPicker.dataSource = self
        taskPicker.delegate = self
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        initLocationDetails()
        getTaskList()
        initMapView()
        initDatePicker()
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
        locationClass.retrieveUserDatabaseAdress(userID: (user?.uid)!)
        locationClass.coordinatesFromAdress()
    }
    
    // Map view initialisation
    func initMapView() {
        print("Initialising mapView...")
        mapView.setUserTrackingMode(.follow, animated: true)
        print("Done")
    }
    
    // Date picker initialiastion
    func initDatePicker() {
        
        print("Initialising datePicker...")
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let currentDate: NSDate = NSDate()
        let components: NSDateComponents = NSDateComponents()
        
        components.minute = -1
        let minDate: NSDate = gregorian.date(byAdding: components as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))! as NSDate
        
        self.datePicker.minimumDate = minDate as Date
        print("Done")
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
        print("Fetching tasks...")
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
    // sendData(price: String, task: String, date: Date, address: String, location: CLLocation, countryCode: String, state: String)
    // Submit button
    @IBAction func helpButton(_ sender: Any) {
      
        
        userAddress = locationClass.getUserDatabaseAdress()
        countryCode = locationClass.getCountryCode()
        state = locationClass.getState()
        userLocation = locationClass.getLocation()
        homeLocation = locationClass.getUserHomeLocation()
        price = priceField.text
        
        if checkNilValues() == true {
            sumbitTaskRequest(price: priceField.text!, task: taskSelected, date: datePicker.date, address: userAddress, location: userLocation, countryCode: countryCode, state: state)
        }
    }
    
    // Exit button
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func checkNilValues() -> Bool{
        
        if userAddress == nil {
            print("userAddress is empty")
            return false
        } else if countryCode == nil{
            print("countryCode is empty")
            return false
        } else if state == nil{
            print("state is empty")
            return false
        } else if userLocation == nil{
            print("userLocation is empty")
            return false
        } else if homeLocation == nil{
            print("homeLocation is empty")
            return false
        } else if taskSelected == "" {
            print("taskSelected is empty")
            return false
        } else if price == nil {
            print("price is empty")
            return false
        }
        return true
    }
    ///////////////////////////////////////////////
    

}
