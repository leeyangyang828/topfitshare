//
//  LoginViewController.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/1/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn
import AVKit
import AVFoundation
import FacebookCore
import MBProgressHUD

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate, InviteDelegate, GIDSignInUIDelegate{

    @IBOutlet weak var fbLoginBtn: FBSDKLoginButton!
    @IBOutlet weak var btnSignup: UIButton!
    @IBOutlet weak var loginView: UIView!
    
    var bgVideoPlayer:AVPlayerViewController?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginView.isHidden = true
        GIDSignIn.sharedInstance().uiDelegate = self as! GIDSignInUIDelegate
        
        let stringVideoName = "login_movie.mp4"
        let stringVideoPath = Bundle.main.path(forResource: stringVideoName, ofType: nil)
        let urlVideoFile = NSURL.fileURL(withPath: stringVideoPath!)
        let player = AVPlayer(url: urlVideoFile)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.view.frame = CGRect.init(x: UIScreen.main.bounds.origin.x-5, y: UIScreen.main.bounds.origin.y, width: UIScreen.main.bounds.size.width+40, height: UIScreen.main.bounds.size.height+20)
        playerViewController.showsPlaybackControls = false
        self.view.insertSubview(playerViewController.view, belowSubview: loginView)
        playerViewController.player!.play()
        fbLoginBtn.delegate = self as FBSDKLoginButtonDelegate
        fbLoginBtn.readPermissions = ["public_profile", "email", "user_friends"]

        
        appDelegate.isFaceBookLogin = false
        if FBSDKAccessToken.current() != nil {
            FBSDKProfile.enableUpdates(onAccessTokenChange: true)
            appDelegate.loadLoginData()
            appDelegate.isLoginOrRegister = true
            appDelegate.isLogin = false
            appDelegate.isFaceBookLogin = true
            self.navigationItem.title = ""
            
            if appDelegate.userName != "" {
                appDelegate.goToMainContact()
            }else{
                loginView.isHidden = false
                let loginManager = FBSDKLoginManager.init()
                loginManager.logOut()
                FBSDKAccessToken.setCurrent(nil)
                self.appDelegate.deleteLoginData()
                self.appDelegate.goToSplash()
                
                //request google sign in
                self.GoogleRequest()
            }
        } else {
            self.checkSessionID()
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        appDelegate.isRegister = false
        appDelegate.isLogin = true
        self.getUserInfos()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkSessionID(){
        let sessionId = UserDefaults.standard.string(forKey: "sessionId")
        if sessionId != nil && sessionId != "" {
            appDelegate.loadLoginData()
            var isCheckUserNameSpell:Bool?
            isCheckUserNameSpell = false
            if appDelegate.userName.contains(".") == true {
                isCheckUserNameSpell = true
            }else if appDelegate.userName.contains("#") == true {
                isCheckUserNameSpell = true
            }else if appDelegate.userName.contains("$") == true {
                isCheckUserNameSpell = true
            }else if appDelegate.userName.contains("[") == true {
                isCheckUserNameSpell = true
            }else if appDelegate.userName.contains("]") == true {
                isCheckUserNameSpell = true
            }else if appDelegate.userName == "" {
                isCheckUserNameSpell = true
            }
            
            if isCheckUserNameSpell == false {
                appDelegate.loadLoginData()
                appDelegate.goToMainContact()
            } else {
                appDelegate.deleteLoginData()
                loginView.isHidden = false
                
                //request google sign in
                self.GoogleRequest()
            }
            
        } else {
            appDelegate.deleteLoginData()
            loginView.isHidden = false
            
            //request google sign in
            self.GoogleRequest()
        }
    }
    
    func getUserInfos(){
        let ref: DatabaseReference = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com/user info")
        ref.child("user info").queryOrderedByKey().observe(DataEventType.value, with: {snapchat in
            self.appDelegate.arrUserInfo.removeAll()
            for data in snapchat.children{
                let child = data as! DataSnapshot
                let dic = child.value as! NSDictionary
                self.appDelegate.arrUserInfo.append(dic)
            }
        })
    }
    
    func showAlert(msg:String, titleStr:String, delegate:Any){
        let alert = UIAlertController(title: titleStr, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkEmail(checkText:UITextField) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: checkText.text)
    }
    
    
    @IBAction func OnSignup(_ sender: UIButton?) {
        let vc = RegisterViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onFBLogin(_ sender: Any) {
    }
    
    struct MyProfileRequest: GraphRequestProtocol {
        struct Response: GraphResponseProtocol {
            init(rawResponse: Any?) {
                // Decode JSON from rawResponse into other properties here.
            }
        }
        
        var graphPath = "/me"
        var parameters: [String : Any]? = ["fields": "picture, email, name"]
        var accessToken = AccessToken.current
        var httpMethod: GraphRequestHTTPMethod = .GET
        var apiVersion: GraphAPIVersion = .defaultVersion
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if ((error) != nil)
        {
            // Process error
            
            self.appDelegate.isFaceBookLogin = false
        }
        else if result.isCancelled {
            // Handle cancellations
            
            self.appDelegate.isFaceBookLogin = false
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
                self.appDelegate.isFaceBookLogin = true
                
                let connection = GraphRequestConnection()
                connection.add(GraphRequest(graphPath: "/me",parameters:["fields": "email, name"] )) { response, result in
                    switch result {
                    case .success(let responseOfMe):
                        print("Custom Graph Request Succeeded: \(responseOfMe)")
                        self.appDelegate.userEmail = responseOfMe.dictionaryValue?["email"] as! String
                        let fullName = responseOfMe.dictionaryValue?["name"] as! String
                        var nameArray:[String] = []
                        nameArray = fullName.components(separatedBy: " ")
                        if nameArray.count > 1 {
                            self.appDelegate.userFirstName = nameArray[0]
                            self.appDelegate.userLastName = nameArray[1]
                        }else{
                            self.appDelegate.userFirstName = nameArray[0]
                            self.appDelegate.userLastName = ""
                        }
                        
                        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
                        loadingNotification.mode = MBProgressHUDMode.indeterminate
                        loadingNotification.label.text = "Loading"
                        
                        let rootR = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com/user info")
                        
                        rootR.queryOrderedByKey().observe(DataEventType.value, with: {snapchat in
                            MBProgressHUD.hide(for: self.view, animated: true)
                            
                            if self.appDelegate.isLoginOrRegister == false{
                                var isExist = false
                                for data in snapchat.children{
                                    let child = data as! DataSnapshot
                                    let dic = child.value as! NSDictionary
                                    let userEmail = dic["email"] as! String
                                    if userEmail == self.appDelegate.userEmail{
                                        isExist = true
                                        self.appDelegate.currentGym = (dic["gym"] as? String)!
                                        self.appDelegate.memberNum = ("1234567")
                                        self.appDelegate.pointsNumber = (dic["pointsNumber"] as? Int)!
                                        self.appDelegate.userName = (dic["username"] as? String)!
                                        self.appDelegate.sessionID = (dic["username"] as? String)!
                                        self.appDelegate.aboutMe = (dic["aboutMe"] as? String)!
                                        self.appDelegate.curUserProfileImageUrl = (dic["profileUrl"] as? String)!
                                        
                                        if self.appDelegate.userName != "" {
                                            var updateToken = [String: Any]()
                                            updateToken["token"] = self.appDelegate.strDeivceToken
                                            rootR.child(self.appDelegate.userName).updateChildValues(updateToken)
                                        }
                                        
                                        self.appDelegate.saveLoginData()
                                        if(GIDSignIn.sharedInstance().currentUser != nil){
                                             self.inviteFriends()
                                        }
                                        else{
                                            self.appDelegate.goToMainContact()
                                        }
                                    }
                                }
                                if isExist == false {
                                    let vc = RegisterViewController()
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                        })

                        
                        break
                        
                    case .failed(let error):
                        print("Custom Graph Request Failed: \(error)")
                    }
                }
                connection.start()
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    

    func GoogleRequest(){
        let alert = UIAlertController(title: "Google Sign In", message: "Connect to Google to earn points and offer your friends special deals", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                GIDSignIn.sharedInstance().signIn()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func inviteFriends(){
        let alert = UIAlertController(title: "Invite Friends", message: "Invite some of your friends and offer them a free 1 month pass", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                if let invite = Invites.inviteDialog() {
                    invite.setInviteDelegate(self as InviteDelegate)
                    invite.setMessage("You should check out ATC Fitness. Here is a free 1 month pass")
                    // Title for the dialog, this is what the user sees before sending the invites.
                    invite.setTitle("ATC Fitnesss Invite")
                    invite.setDeepLink("http://www.aroundtheclock.fitness/download-app")
                    invite.open()
                }
        }))
        alert.addAction(UIAlertAction(title: "Skip", style: .default, handler: { [weak alert] (_) in
            self.appDelegate.goToMainContact()
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func inviteFinished(withInvitations invitationIds: [String], error: Error?) {
        if let error = error {
            print("Failed: " + error.localizedDescription)
            self.appDelegate.goToMainContact()
        } else {
            print("\(invitationIds.count) invites sent")
            self.appDelegate.goToMainContact()
        }
    }
}
