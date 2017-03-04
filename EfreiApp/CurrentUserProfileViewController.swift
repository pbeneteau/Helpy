//
//  CurrentUserProfileViewController.swift
//  
//
//  Created by Paul Bénéteau on 03/03/2017.
//
//

import UIKit
import Firebase

class CurrentUserProfileViewController: UIViewController {

    let ref = FIRDatabase.database().reference()
    var user = FIRAuth.auth()?.currentUser
    
    var userName: String = ""
    var userEmail: String = ""
    var userAddress: String = ""
    
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userAddressLabel: UILabel!
    
    @IBOutlet weak var editAddressView: UIView!
    @IBOutlet weak var editAddressField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        editAddressView.isHidden = true
        initUserInfos()
        initProfileView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func initProfileView() {
        
        userNameLabel.text = userName
        userEmailLabel.text = userEmail
        userAddressLabel.text = userAddress
    }
    
    func initUserInfos() {
        
        mainUser().initUserName(){}
        locationHelp().retrieveUserDatabaseAdress(userID: (user?.uid)!) {}
        
        userEmail = (user?.email)!
        userAddress = locationHelp().getUserDatabaseAdress()
        
    }
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editAddressButton(_ sender: Any) {
        editAddressView.isHidden = false
    }
    
    @IBAction func editAddressSubmit(_ sender: Any) {
        ref.child("users").child((user?.uid)!).child("email").setValue(editAddressField.text)
        editAddressView.isHidden = true
    }
    
    @IBAction func scoreButton(_ sender: Any) {
    }

}
