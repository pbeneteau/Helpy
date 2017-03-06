//
//  Ask.swift
//  EfreiApp
//
//  Created by Paul Bénéteau on 24/02/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import SwiftLocation
import SwiftyJSON


class AskHelp: AnyObject {
    
    let locationClass = locationHelp()
    
    let ref: FIRDatabaseReference = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    
    private var userLocation: CLLocation!
    private var address: String!
    private var userHomeLocation: CLLocation!
    
    
    // Check if user is at home
    func checkUserLocationHome(currentLocation: CLLocation, homeLocation: CLLocation) -> Bool {
        
        let distance: Int = Int(locationClass.getLocationsDistance(location1: currentLocation, location2: homeLocation))
        
        if (distance <= 200) {
            print("You are at home")
            return true
        }
        print("Your are not at home!")
        return false
    }
    
    // Upload the request to database
    func sendData(price: String, task: String, date: Date, address: String, location: CLLocation, countryCode: String, state: String, userIsAtHome: Bool) {
       
        let taskKey: String = randomString(length: 25)
        let taskDate: String = convertDateToString(dateToConvert : date)
        
        print("Sending ask data...")
        
        ref.child("asks").child(countryCode).child(state).child(task).child(taskKey).setValue("")
        ref.child("asks").child(countryCode).child(state).child(task).child(taskKey).child("price").setValue(price)
        ref.child("asks").child(countryCode).child(state).child(task).child(taskKey).child("date").setValue(taskDate)
        ref.child("asks").child(countryCode).child(state).child(task).child(taskKey).child("location").setValue("\(location)")
        ref.child("asks").child(countryCode).child(state).child(task).child(taskKey).child("user").setValue((user?.uid)!)
        ref.child("asks").child(countryCode).child(state).child(task).child(taskKey).child("address").setValue(address)
        ref.child("asks").child(countryCode).child(state).child(task).child(taskKey).child("userIsAtHome").setValue(userIsAtHome)
        ref.child("asks").child(countryCode).child(state).child(task).child(taskKey).child("task").setValue(task)
        ref.child("asks").child(countryCode).child(state).child(task).child(taskKey).child("nsDate").setValue("\(date)")
        
        ref.child("users").child((user?.uid)!).child("asks").child(taskKey).child("price").setValue(price)
        ref.child("users").child((user?.uid)!).child("asks").child(taskKey).child("task").setValue(task)
        ref.child("users").child((user?.uid)!).child("asks").child(taskKey).child("address").setValue(address)
        ref.child("users").child((user?.uid)!).child("asks").child(taskKey).child("date").setValue(taskDate)
        ref.child("users").child((user?.uid)!).child("asks").child(taskKey).child("nsDate").setValue("\(date)")
        
        print("Done")
    }
    
    // Generate random key
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
    // Convert NSDate to String
    func convertDateToString(dateToConvert : Date) -> String{
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let comp = calendar.dateComponents([.hour, .minute], from: dateToConvert)
        let hour = comp.hour
        let minute = comp.minute
        let dateString = dateFormatter.string(from: dateToConvert)
        return "\(dateString) at \(hour!):\(minute!)"
    }
    
}
