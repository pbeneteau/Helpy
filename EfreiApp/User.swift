//
//  User.swift
//  EfreiApp
//
//  Created by Paul Bénéteau on 20/01/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import Firebase
import SwiftLocation


class MainUser {
    
    private let ref = FIRDatabase.database().reference()
    private var user = FIRAuth.auth()?.currentUser
    
    private var name: String!
    private var userLocation: CLLocation!
    private var location: CLLocation!
    private var city: String!
    private var postalCode: String!
    private var countryCode: String!
    private var status: Bool
    
    
    let Location1:LocationManager = LocationManager()
    
    func getUserName() -> String {
        let userRef = ref.child("users").child(user!.uid).child("name")
        
        userRef.observe(FIRDataEventType.value, with: { (snapshot) in
            self.name = snapshot.value as? String
        })
        return name
    }
    
    func getName() -> String {
        return self.name
    }
    func getStatus() -> Bool {
        return self.status
    }
    
    init() {
        name = ""
        status = true
    }
}
