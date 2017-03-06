//
//  MainViewController.swift
//  EfreiApp
//
//  Created by Paul Bénéteau on 18/01/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import UIKit
import Firebase
import Spring
import CoreLocation
import MapKit
import SwiftLocation
import SystemConfiguration
import NVActivityIndicatorView
import Sparrow


class MainViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    
    let ref = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    
    let locationManager = CLLocationManager()
    
    let User = mainUser()
    let locationClass = locationHelp()
    let askClass = AskHelp()
    
    var permissionAssistant = SPRequestPermissionAssistant.modules.dialog.interactive.create(with: [.Location, .PhotoLibrary, .Notification, .Calendar])

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if DeviceInfos().isInternetAvailable() == false {
            print("No connexion")
        } else {
            print("Connexion detected")
            

            initLocationDetails()
            
            if user == nil {
                transitionSegue.segue.switchToLoginview()
                disconnectButton(Any.self)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        _ = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(self.checkPermissionsState), userInfo: nil, repeats: false);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initLocationDetails() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        locationClass.setLocation { success in
            if success {
            }
        }
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
    
    @IBAction func helpButtonAction(_ sender: Any) {
        
        startAnimating(CGSize(width: 30, height: 30), message: "Loading...", type: .ballScaleRippleMultiple)
    }
    
    func checkPermissionsState() {
        let Location = permissionAssistant.isAllowPermission(.Location)
        let Camera = permissionAssistant.isAllowPermission(.PhotoLibrary)
        let Notification = permissionAssistant.isAllowPermission(.Notification)
        let Calendar = permissionAssistant.isAllowPermission(.Calendar)
        
        let array = [Camera, Location, Notification, Calendar]
        
        for object in array {
            if object == false {
                permissionAssistant.present(on: self)
                return
            }
        }
    }

}
