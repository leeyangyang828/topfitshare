//
//  SettingViewController.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/5/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase
import FBSDKLoginKit

class SettingViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var currentGoal: UILabel!
    @IBOutlet weak var aboutMe: UITextField!
    @IBOutlet weak var currentEmail: UILabel!
    @IBOutlet weak var currentUsername: UILabel!
    @IBOutlet weak var btnMyGym: UIButton!

    
    @IBOutlet weak var changeOldEmail: UITextField!
    @IBOutlet weak var changeOldPassword: UITextField!
    @IBOutlet weak var changeNewEmail: UITextField!
    
    @IBOutlet weak var chnageOldPwdforPV: UITextField!
    @IBOutlet weak var changeNewPwdforPv: UITextField!
    @IBOutlet weak var changeVerifyPwdForPv: UITextField!
    
    @IBOutlet weak var changeEmailView: UIView!
    @IBOutlet weak var changePasswordview: UIView!
    
    var arrayGoal:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentEmail.text = "Email: \(String(describing: appDelegate.userEmail))"
        currentUsername.text = "Username: \(String(describing: appDelegate.userName))"
        btnMyGym.setTitle("My Gym: \(String(describing: appDelegate.currentGym))", for: UIControlState.normal)
        
        changeEmailView.isHidden = true
        changePasswordview.isHidden = true
        
        
        
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTap))
        //gesture.delegate = self
        self.view.addGestureRecognizer(gesture)
        
        aboutMe.text = appDelegate.aboutMe
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleTap(){
        self.view.endEditing(true)
    }
    
    @IBAction func onCancelClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onChangeGoal(_ sender: UIButton) {
    }
    
    @IBAction func onResetPassword(_ sender: UIButton) {
        self.view.endEditing(true)
        changePasswordview.isHidden = false
    }
    @IBAction func onMyGymClick(_ sender: UIButton) {
        self.view.endEditing(true)
        appDelegate .goToGYMSelected()
    }
    @IBAction func onChangeEmail(_ sender: UIButton) {
        self.view .endEditing(true)
        changeEmailView.isHidden = false
    }
    @IBAction func onLogoutClick(_ sender: UIButton) {
        self.view.endEditing(true)
        let loginManager = FBSDKLoginManager.init()
        loginManager.logOut()
        FBSDKAccessToken.setCurrent(nil)
        
        //FIRAuth.auth()?.signOut()
        appDelegate.deleteLoginData()
        appDelegate.goToSplash()
    }
    
    @IBAction func onChangeEmailOfEmailView(_ sender: UIButton) {
        self.view.endEditing(true)
        let user = Auth.auth().currentUser!
        //user .updateEmail(changeNewEmail.text!, completion: ^(error :NSError))
    }
    
    @IBAction func onCancelOfEmailView(_ sender: UIButton) {
    }
    
    @IBAction func onChangePasswordForPv(_ sender: UIButton) {
    }
    @IBAction func onCancelForPv(_ sender: UIButton) {
    }
}
