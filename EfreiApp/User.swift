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


class mainUser {
    
    private let ref = FIRDatabase.database().reference()
    private var user = FIRAuth.auth()?.currentUser
    
    private var name: String!
    private var averageMark: Double!
    private var totalAsks: Double!
    private var totalHelps: Double!
    private var ratioHA: Double!
    private var profileCompletion: Int!
    
    let Location1: LocationManager = LocationManager()
    
    func initUserName(finished: @escaping () -> Void) {
        let userRef = ref.child("users").child((user?.uid)!).child("name")
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            let name: String = snapshot.value as! String
            self.name = name
            finished()
            print(self.name)
        }) { (error) in
            print(error.localizedDescription)
        }        
    }
    
    func initTotalAsks(finished: @escaping () -> Void) {
        let userRef = ref.child("users").child((user?.uid)!).child("asks")
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            let total: Double = Double(snapshot.childrenCount)
            self.forceEnd(data: total)
            self.totalAsks = total
            finished()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func initTotalHelps(finished: @escaping () -> Void) {
        let userRef = ref.child("users").child((user?.uid)!).child("totalHelps")
       
        userRef.observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            let total: Double = snapshot.value as! Double
            self.forceEnd(data: total)
            self.totalHelps = total
            finished()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func initAverageMark(finished: @escaping () -> Void) {
        let userRef = ref.child("users").child((user?.uid)!).child("mark")
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            let mark: Double = snapshot.value as! Double
            self.forceEnd(data: mark)
            self.averageMark = mark
            finished()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getName() -> String {
        return self.name
    }
    func getAverageMark() -> Double {
        return averageMark
    }
    func getTotalAsks() -> Double {
        return totalAsks
    }
    func getTotalHelps() -> Double {
        return totalHelps
    }
    func getRationHA() -> Double {
        ratioHA = totalHelps / totalAsks
        return ratioHA
    }
    func getProfileCompletion() -> Int {
        return profileCompletion
    }
    
    init() {
        name = ""
        totalAsks = 0
        totalHelps = 0
        ratioHA = 0.0
        profileCompletion = 0
    }
    
    func forceEnd(data: Any) {
        
    }
}
