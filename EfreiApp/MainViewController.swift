//
//  MainViewController.swift
//  EfreiApp
//
//  Created by Paul Bénéteau on 18/01/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import UIKit
import Firebase
import Hero
import Spring
import CoreLocation
import MapKit
import SwiftLocation
import PermissionScope
import Alamofire
import SystemConfiguration
import NVActivityIndicatorView


class MainViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var profileView: UIView!
    
    let ref = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    
    let locationManager = CLLocationManager()
    
    let User = MainUser()
    let locationClass = locationHelp()
    let askClass = askHelp()
    
    let pscope = PermissionScope()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isInternetAvailable() == false {
            print("No connexion detected")
        } else {
            print("Connexion detected")
            
            pscope.addPermission(LocationAlwaysPermission(), message: "We use this to track\r\nwhere you live :)")
            
            showLocationPermission(scope: pscope)
            
            initLocationDetails()
            
            initProfileView()
            
            if user == nil {
                transitionSegue.segue.switchToLoginview()
                disconnectButton(Any.self)
            }
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initLocationDetails() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        locationClass.updateUserLocation()
        locationClass.retrieveUserDatabaseAdress(userID: (user?.uid)!)
        locationClass.coordinatesFromAdress()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    @IBAction func disconnectButton(_ sender: Any) {
        
        if FIRAuth.auth()?.currentUser != nil {
            do {
                try FIRAuth.auth()?.signOut()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginView")
                present(vc, animated: true, completion: nil)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        print("user did logout")
    }
    
    @IBAction func profileButton(_ sender: Any) {
        if profileView.isHidden == false {
            profileView.isHidden = true
            
        } else {
            profileView.isHidden = false
        }
    }
    
    @IBAction func helpButtonAction(_ sender: Any) {
        
        startAnimating(CGSize(width: 30, height: 30), message: "Loading...", type: .ballScaleRippleMultiple)
    }
    
    func initProfileView() {
        
        let userName = User.getUserName()
        
        nameLabel.text = userName
        emailLabel.text = user?.email
    }
    
    func showLocationPermission(scope: PermissionScope!) {
        scope.show(
            { finished, results in
                print("got results \(results)")
        },
            cancelled: { results in
                print("thing was cancelled")
        }
        )
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}
