//
//  Location.swift
//  EfreiApp
//
//  Created by Paul Bénéteau on 11/02/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import Firebase
import CoreLocation
import SwiftLocation
import MapKit
import SwiftyJSON


class locationHelp {
    
    let Location1:LocationManager = LocationManager()
    
    let ref = FIRDatabase.database().reference()
    
    
    private var userHomeLocation: CLLocation!
    private var location: CLLocation!
    private var city: String!
    private var postalCode: String!
    private var countryCode: String!
    private var state: String!
    private var address: String!
    private var userHomeLocationAsk: CLLocation!
    
    
    // Location
    func setLocation(location: CLLocation) {
        self.location = location
        self.getLocationDetails(location: location)
    }
    
    
    // Get current user City, PostalCode and Country code
    func getLocationDetails(location: CLLocation) {
        _ = Location.reverse(coordinates: location.coordinate, onSuccess: { foundPlacemark in
            self.city = foundPlacemark.locality
            self.countryCode = foundPlacemark.isoCountryCode
            self.postalCode = foundPlacemark.postalCode
            self.state = foundPlacemark.administrativeArea
            print(self.state)
        }) { error in
            print("Error: \(error)")
        }
    }
    
    func updateUserLocation() {
        var r = Location.getLocation(withAccuracy: .block, frequency: .oneShot, timeout: nil, onSuccess: { (location) in
            
            self.setLocation(location: location)
            
        }) { (last, err) in
            print("err \(err)")
        }
        r.onAuthorizationDidChange = { newStatus in
            print("New status \(newStatus)")
        }
    }
    
    // Get coordinates from adress
    func coordinatesFromAdress() {
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(self.address!) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let locationFromAdress = placemarks.first?.location
                else {
                    print("location from address not found")
                    print("trying again...")
                    self.coordinatesFromAdress()
                    return
            }
            self.userHomeLocation = locationFromAdress
        }
    }
    
    func retrieveUserDatabaseAdress(userID: String) {
        
        let userRef = ref.child("users").child(userID)
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            let name = JSON(snapshot.value!)["address"].stringValue
            self.address = name
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getLocationsDistance(location1: CLLocation, location2: CLLocation) -> Double {
        
        let distanceMeters = location1.distance(from: location2)
        
        return distanceMeters
    }
    
    func getCity() -> String {
        
        return self.city
    }
    func getPostalCode() -> String {
        
        return self.postalCode
    }
    func getCountryCode() -> String {
        
        return self.countryCode
    }
    func getState() -> String {
        return state
    }
    func getLocation() -> CLLocation {
        return location
    }
    func getLat() -> CLLocationDegrees {
        
        return location.coordinate.latitude
    }
    func getLong() -> CLLocationDegrees{
 
        return location.coordinate.longitude
    }
    func getUserHomeLocation() -> CLLocation  {
        return userHomeLocation
    }
    func getUserDatabaseAdress() -> String {
        return address
    }
    
    init() {
        userHomeLocation = CLLocation(latitude: 0.0, longitude: 0.0)
        location = CLLocation(latitude: 0.0, longitude: 0.0)
        city = ""
        postalCode = ""
        countryCode = ""
        address = ""
        userHomeLocationAsk = CLLocation(latitude: 0.0, longitude: 0.0)
    }
}
