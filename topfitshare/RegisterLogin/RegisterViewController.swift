//
//  RegisterViewController.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/3/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit
import MobileCoreServices
import Firebase
import GoogleSignIn
import FirebaseStorage
import DropDown
import MBProgressHUD

class RegisterViewController: UIViewController, UITextFieldDelegate , InviteDelegate, GIDSignInUIDelegate{

    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtMemberNum: UITextField!
    @IBOutlet weak var scrView: UIScrollView!
    @IBOutlet weak var lblAli: UILabel!
    
    @IBOutlet weak var alcButton: UIButton!
    
    var isFlag:Bool?
    var showKeyboard:Bool?
    var isRegisted:Bool?
    var isCheckUser:Bool?
    var profileImg:UIImage?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let alicDropDown = DropDown()
    lazy var dropDowns: [DropDown] = {
        return [
            self.alicDropDown
        ]
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self as! GIDSignInUIDelegate
        
        showKeyboard = false
        let gesture = UITapGestureRecognizer(target:self, action:#selector(self.handleTap));
        scrView.addGestureRecognizer(gesture)
        
        isRegisted = false
        isCheckUser = false
        
        self.setupUI()
        
        //fill in textfields with facebook info
        if appDelegate.isFaceBookLogin == true{
            txtFirstName.text = appDelegate.userFirstName
            txtLastName.text = appDelegate.userLastName
            txtEmail.text = appDelegate.userEmail
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupUI(){
        self.navigationItem.title = "Register"
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : Any]
        
        //self.navigationController?.navigationBar .titleTextAttributes = [NSForegroundColorAttributeName:[UIColor.white]]
        
        let btRegister = UIButton(type: UIButtonType.custom)
        btRegister.frame = CGRect(x: 0, y: 0, width:60, height:30)
        btRegister.setTitle("Signup", for: UIControlState.normal)
        btRegister.setTitleColor(UIColor.white, for: UIControlState.normal)
        btRegister.addTarget(self, action: #selector(self.onRegisterClick(_:)), for: UIControlEvents.touchUpInside)
        let btBarRegister = UIBarButtonItem.init(customView: btRegister)
        self.navigationItem.setRightBarButton(btBarRegister, animated: true)
        
        customizeDropDown(self)
        
        alicDropDown.anchorView = alcButton
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        alicDropDown.bottomOffset = CGPoint(x: 0, y: alcButton.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        alicDropDown.dataSource = [
            "Alico",
            "Boyscout",
            "Cape Coral",
            "Port Charlotte",
            "Sarasota",
            "Six Mile"
        ]
        
        // Action triggered on selection
        alicDropDown.selectionAction = { [unowned self] (index, item) in
            //self.alcButton.setTitle(item, for: .normal)
            self.lblAli.text = item
        }
    }
    
    func customizeDropDown(_ sender: AnyObject) {
        DropDown.setupDefaultAppearance()
        
        dropDowns.forEach {
            $0.cellNib = UINib(nibName: "DropDownCell", bundle: Bundle(for: DropDownCell.self))
            $0.customCellConfiguration = nil
        }
    }
    
    func handleTap(){
        if showKeyboard == true {
            self.view.endEditing(true)
            scrView.contentSize = CGSize(width:0, height:0)
            showKeyboard = false
        }
    }
    
    func keyboardWasShown(){
        if showKeyboard == false {
            showKeyboard = true
            scrView.contentSize = CGSize(width:320, height:scrView.frame.size.height)
            scrView.setContentOffset(CGPoint(x:0, y:0), animated: true)
        }
    }
    
    func keyboardWillBeHidden(){
        if showKeyboard == true {
            self.view.endEditing(true)
            scrView.contentSize = CGSize(width:0, height:0)
            showKeyboard = false
        }
    }
    
    //UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        scrView.contentSize = CGSize(width:320, height:scrView.frame.size.height)
        scrView.setContentOffset(CGPoint(x:0, y:0), animated: true)
        if  textField == txtFirstName {
            txtLastName.becomeFirstResponder()
            scrView.setContentOffset(CGPoint(x:0, y:40), animated: true)
        } else if  textField == txtLastName {
            txtEmail.becomeFirstResponder()
            scrView.setContentOffset(CGPoint(x:0, y:80), animated: true)
        } else if  textField == txtEmail {
            txtUsername.becomeFirstResponder()
            scrView.setContentOffset(CGPoint(x:0, y:120), animated: true)
        } else if  textField == txtUsername {
            txtMemberNum.becomeFirstResponder()
            scrView.setContentOffset(CGPoint(x:0, y:140), animated: true)
        } else if  textField == txtMemberNum {
            scrView.setContentOffset(CGPoint(x:0, y:170), animated: true)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrView.contentSize = CGSize(width:320, height:scrView.frame.size.height)
        scrView.setContentOffset(CGPoint(x:0, y:0), animated: true)
        if  textField == txtLastName {
            scrView.setContentOffset(CGPoint(x:0, y:40), animated: true)
        } else if  textField == txtEmail {
            scrView.setContentOffset(CGPoint(x:0, y:80), animated: true)
        } else if  textField == txtUsername {
            scrView.setContentOffset(CGPoint(x:0, y:120), animated: true)
        } else if  textField == txtMemberNum {
            scrView.setContentOffset(CGPoint(x:0, y:140), animated: true)
        }
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
    
    @IBAction func onRegisterClick(_ sender: UIButton?) {
        self.view.endEditing(true)
        if txtFirstName.text?.characters.count == 0 || txtLastName.text?.characters.count == 0{
            self.showAlert(msg: "Please input Name", titleStr: "Input Error", delegate: self)
            return
        }
        if txtEmail.text?.characters.count == 0 {
            self.showAlert(msg: "Please input your Email Address", titleStr: "Input Error", delegate: self)
            return
        }
        if ((txtEmail.text?.range(of: "@")) != nil) {
            if ((txtEmail.text?.range(of: " ")) != nil) {
                self.showAlert(msg: "Email field contains space. Please input again", titleStr: "Input Error", delegate: self)
                return
            }
        }
        if self.checkEmail(checkText: txtEmail) == false{
            self.showAlert(msg: "Please enter a valid email address.", titleStr: "Input Error", delegate: self)
            return
        }
        if txtUsername.text?.characters.count == 0 {
            self.showAlert(msg: "Please input User Name", titleStr: "Input Error", delegate: self)
            return
        }
        if txtUsername.text?.contains(".") == true {
            self.showAlert(msg: "Username must be a non-empty string and not contain '.', '#' ,'$' ,'[' or ']'", titleStr: "Input Error", delegate: self)
            return
        }else if txtUsername.text?.contains("#") == true {
            self.showAlert(msg: "Username must be a non-empty string and not contain '.', '#' ,'$' ,'[' or ']'", titleStr: "Input Error", delegate: self)
            return
        }else if txtUsername.text?.contains("$") == true {
            self.showAlert(msg: "Username must be a non-empty string and not contain '.', '#' ,'$' ,'[' or ']'", titleStr: "Input Error", delegate: self)
            return
        }else if txtUsername.text?.contains("[") == true {
            self.showAlert(msg: "Username must be a non-empty string and not contain '.', '#' ,'$' ,'[' or ']'", titleStr: "Input Error", delegate: self)
            return
        }else if txtUsername.text?.contains("]") == true {
            self.showAlert(msg: "Username must be a non-empty string and not contain '.', '#' ,'$' ,'[' or ']'", titleStr: "Input Error", delegate: self)
            return
        }
        if txtMemberNum.text?.characters.count == 0 {
            self.showAlert(msg: "Please input member Number", titleStr: "Input Error", delegate: self)
            return
        }
     
        if uniqueUser(username: txtUsername.text!) == false {
            self.showAlert(msg: "Username already taken.", titleStr: "Input Error", delegate: self)
            return
        }
        if uniqueEmail(email: txtEmail.text!) == false {
            self.showAlert(msg: "Email already taken.", titleStr: "Input Error", delegate: self)
            return
        }
        
        appDelegate.userEmail = txtEmail.text!
        appDelegate.userFirstName = txtFirstName.text!
        appDelegate.userLastName = txtLastName.text!
        appDelegate.curUserProfileImageUrl = ""
        appDelegate.sessionID = txtUsername.text!
        appDelegate.userName = txtUsername.text!
        appDelegate.pointsNumber = 0
        appDelegate.aboutMe = ""
        appDelegate.currentGym = lblAli.text!
        appDelegate.memberNum = txtMemberNum.text!
        
        appDelegate.saveLoginData()
        
        var userInfoForPost = [String: Any]()
        userInfoForPost["aboutMe"] = appDelegate.aboutMe
        userInfoForPost["email"] = appDelegate.userEmail
        userInfoForPost["firstName"] = appDelegate.userFirstName
        userInfoForPost["lastName"] = appDelegate.userLastName
        userInfoForPost["gym"] = appDelegate.currentGym
        userInfoForPost["memberNumber"] = appDelegate.memberNum
        userInfoForPost["pointsNumber"] = appDelegate.pointsNumber
        userInfoForPost["profileUrl"] = appDelegate.curUserProfileImageUrl
        userInfoForPost["username"] = appDelegate.userName
        userInfoForPost["token"] = self.appDelegate.strDeivceToken
        
        if appDelegate.userName != "" {
            let rootR = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com/")
            let rootRForRegister = rootR.child("user info").child(appDelegate.userName)
            rootRForRegister.setValue(userInfoForPost)
        }
        if(GIDSignIn.sharedInstance().currentUser != nil){
            let alert = UIAlertController(title: "Invite Friends", message: "Invite some of your friends and offer them a free 1 month pass", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                if let invite = Invites.inviteDialog() {
                    invite.setInviteDelegate(self as! InviteDelegate)
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
        else{
             self.appDelegate.goToMainContact()
        }
        
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
    @IBAction func onLogin(_ sender: UIButton) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Member ID", message: "Please enter your member number:", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
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
                        let memNumber = dic["memberNumber"]
                        if "\(memNumber ?? 0)" == textField?.text{
                            isExist = true
                            //self.appDelegate.completeNumber = (dic["completeNumber"] as? Int)!
                            self.appDelegate.userEmail = (dic["email"] as? String)!
                            self.appDelegate.userFirstName = (dic["firstName"] as? String)!
                            self.appDelegate.currentGym = (dic["gym"] as? String)!
                            self.appDelegate.userLastName = (dic["lastName"] as? String)!
                            self.appDelegate.memberNum = (dic["memberNumber"] as? String)!
                            self.appDelegate.pointsNumber = (dic["pointsNumber"] as? Int)!
                            self.appDelegate.userName = (dic["username"] as? String)!
                            self.appDelegate.sessionID = (dic["username"] as? String)!
                            self.appDelegate.aboutMe = (dic["aboutMe"] as? String)!
                            
                            if dic["profileUrl"] != nil && dic["profileUrl"] as? String != "" {
                                self.appDelegate.curUserProfileImageUrl = (dic["profileUrl"] as? String)!
                            }
                            if self.appDelegate.userName != "" {
                                var updateToken = [String: Any]()
                                updateToken["token"] = self.appDelegate.strDeivceToken
                                rootR.child(self.appDelegate.userName).updateChildValues(updateToken)
                            }
                            
                            self.appDelegate.saveLoginData()
                            self.appDelegate.goToMainContact()
                        }
                    }
                    if isExist == false {
                        self.showAlert(msg: "Please create a new profile", titleStr: "Not Found", delegate: self)
                        return
                    }
                }
                
                
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            
            
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func onAicSelect(_ sender: UIButton) {
        alicDropDown.show()
    }
    func uniqueUser(username: String) -> Bool{
        var unique = true
        let rootR = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com/user info")
        rootR.queryOrderedByKey().observe(DataEventType.value, with: {snapchat in
            MBProgressHUD.hide(for: self.view, animated: true)
            for data in snapchat.children{
                let child = data as! DataSnapshot
                let dic = child.value as! NSDictionary
                let user = dic["username"] as! String
                if(username == user){
                    unique = false
                }
            }
        })
        return unique
    }
        
    func uniqueEmail(email: String) -> Bool{
        var unique = true
        let rootR = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com/user info")
        rootR.queryOrderedByKey().observe(DataEventType.value, with: {snapchat in
            MBProgressHUD.hide(for: self.view, animated: true)
            for data in snapchat.children{
                let child = data as! DataSnapshot
                let dic = child.value as! NSDictionary
                let userEmail = dic["email"] as! String
                if(email == userEmail){
                    unique = false
                }
            }
        })
        return unique
    }
}
