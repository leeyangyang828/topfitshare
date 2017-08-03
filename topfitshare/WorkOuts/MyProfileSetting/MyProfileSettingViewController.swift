//
//  MyProfileSettingViewController.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/13/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit
import DropDown
import CoreData
import Firebase
import GoogleSignIn
import MBProgressHUD
import FBSDKLoginKit

class MyProfileSettingViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate , InviteDelegate, GIDSignInUIDelegate{
    @IBOutlet weak var lblPointNum: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var lblGym: UILabel!
    @IBOutlet weak var lblAboutMe: UILabel!

    @IBOutlet weak var txtAboutMe: UITextField!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var txtCurrentUserName: UITextField!
    @IBOutlet weak var txtNewUserName: UITextField!
    @IBOutlet weak var userNameChangedView: UIView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let gymDropDwon = DropDown()
    lazy var dropDowns: [DropDown] = {
        return [
            self.gymDropDwon
        ]
    }()
    var changedImg:UIImage?
    var workoutImageUrl = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        userNameChangedView.isHidden = true
        
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTap))
        //gesture.delegate = self
        self.view.addGestureRecognizer(gesture)
        
        profileImage.contentMode = .scaleAspectFill
        profileImage.clipsToBounds = true
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        
        if appDelegate.curUserProfileImageUrl != "" {
            profileImage.setImageWith(URL.init(string: appDelegate.curUserProfileImageUrl)!)
        }
        
        if appDelegate.aboutMe != "" {
            lblAboutMe.text = appDelegate.aboutMe
        }else{
            lblAboutMe.text = ""
        }
        
        if appDelegate.currentGym != "" {
            lblGym.text = appDelegate.currentGym
        }else{
            appDelegate.currentGym = "Alico"
            lblGym.text = "Alico"
        }
        lblPointNum.text = "\(appDelegate.pointsNumber ) Points"
        
        lblUserName.text = "Username: \(appDelegate.userName )"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func customizeDropDown(_ sender: AnyObject) {
        DropDown.setupDefaultAppearance()
        
        dropDowns.forEach {
            $0.cellNib = UINib(nibName: "DropDownCell", bundle: Bundle(for: DropDownCell.self))
            $0.cellHeight = 35
            $0.customCellConfiguration = nil
        }
    }
    
    func handleTap(){
        self.view.endEditing(true)
    }
    
    @IBAction func onProfileImage(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    func openCamera()
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary()
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var  chosenImage = UIImage()
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        chosenImage = appDelegate.resizeImage(image: chosenImage, targetSize: CGSize.init(width: 100, height: 100))
        self.uploadPhoto(image: chosenImage)
        dismiss(animated:true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func uploadPhoto(image:UIImage){
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        
        changedImg = image
        let storageRef = Storage.storage().reference(forURL: "gs://atc-fitness.appspot.com") as StorageReference
        let imageData = UIImageJPEGRepresentation(changedImg!, 0.8)! as Data
        let imagePath = "profile/\(appDelegate.userName )_\(NSDate().timeIntervalSince1970).jpg"
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        storageRef.child(imagePath).putData(imageData as Data, metadata: metaData, completion: { metadata, error in
            MBProgressHUD.hide(for: self.view, animated: true)
            if error != nil {
                // Uh-oh, an error occurred!
            } else {
                //Metadata contains file metadata such as size, content-type, and download URL.
                self.workoutImageUrl = (metadata!.downloadURL()?.absoluteString)!
                self.profileImage.image = image
                
                self.appDelegate.curUserProfileImageUrl = self.workoutImageUrl
                self.appDelegate.saveLoginData()
                var userInfoForPost = [String: Any]()
                userInfoForPost["aboutMe"] = self.appDelegate.aboutMe
                userInfoForPost["email"] = self.appDelegate.userEmail
                userInfoForPost["firstName"] = self.appDelegate.userFirstName
                userInfoForPost["gym"] = self.appDelegate.currentGym
                userInfoForPost["lastName"] = self.appDelegate.userLastName
                userInfoForPost["memberNumber"] = self.appDelegate.memberNum
                userInfoForPost["pointsNumber"] = self.appDelegate.pointsNumber
                userInfoForPost["profileUrl"] = self.appDelegate.curUserProfileImageUrl
                userInfoForPost["username"] = self.appDelegate.userName
                userInfoForPost["token"] = self.appDelegate.strDeivceToken
                
                if self.appDelegate.userName != "" {
                    let rootR = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com/")
                    let rootRForRegister = rootR.child("user info").child(self.appDelegate.userName)
                    rootRForRegister.setValue(userInfoForPost)
                }
            }
        })

    }

    @IBAction func onChangeGym(_ sender: UIButton) {
        self.view.endEditing(true)
        gymDropDwon.show()
    }
    @IBAction func onRwards(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = RewardsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onUserName(_ sender: UIButton) {
        self.view.endEditing(true)
        userNameChangedView.isHidden = false
    }
    @IBAction func onChangeUserName(_ sender: UIButton) {
        if txtCurrentUserName.text?.characters.count == 0 {
            self.showAlert(msg: "Please fill in all fields to reset username.", titleStr: "Input Error", delegate: self)
            txtCurrentUserName.text = ""
            return
        }
        if txtNewUserName.text?.characters.count == 0 {
            self.showAlert(msg: "Please fill in all fields to reset username.", titleStr: "Input Error", delegate: self)
            txtNewUserName.text = ""
            return
        }
        self.view.endEditing(true)
        appDelegate.userName = txtNewUserName.text!
        appDelegate.saveLoginData()
        let rootR = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com/")
        
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        
        if userNameChangedView.isHidden == false {
            rootR.child("user info").queryOrderedByKey().observe(DataEventType.value, with: {snapchat in
                MBProgressHUD.hide(for: self.view, animated: true)
                var isExist = false
                for data in snapchat.children{
                    let child = data as! DataSnapshot
                    if self.txtCurrentUserName.text == child.key{
                        isExist = true
                    }
                }
                if isExist == true {
                    rootR.child("user info").child(self.txtCurrentUserName.text!).removeValue()
                    
                    var userInfoForPost = [String: Any]()
                    userInfoForPost["aboutMe"] = self.appDelegate.aboutMe
                    userInfoForPost["email"] = self.appDelegate.userEmail
                    userInfoForPost["firstName"] = self.appDelegate.userFirstName
                    userInfoForPost["gym"] = self.appDelegate.currentGym
                    userInfoForPost["lastName"] = self.appDelegate.userLastName
                    userInfoForPost["memberNumber"] = self.appDelegate.memberNum
                    userInfoForPost["pointsNumber"] = self.appDelegate.pointsNumber
                    userInfoForPost["profileUrl"] = self.appDelegate.curUserProfileImageUrl
                    userInfoForPost["username"] = self.appDelegate.userName
                    userInfoForPost["token"] = self.appDelegate.strDeivceToken
                    
                    if self.appDelegate.userName != "" {
                        let rootRForRegister = rootR.child("user info").child(self.appDelegate.userName)
                        rootRForRegister.setValue(userInfoForPost)
                    }
                    self.userNameChangedView.isHidden = true
                    self.showAlert(msg: "Username has been changed successfully", titleStr: "ATC Fitness", delegate: self)
                }else{
                    self.showAlert(msg: "Userame taken", titleStr: "Error", delegate: self)
                }
                
            })
        }else{
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        
        
    }
    
    func showAlert(msg:String, titleStr:String, delegate:Any){
        let alert = UIAlertController(title: titleStr, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func onCancelUserNameChage(_ sender: UIButton) {
        self.view.endEditing(true)
        userNameChangedView.isHidden = true
    }
    @IBAction func onReferFriend(_ sender: UIButton) {
        self.view.endEditing(true)
         if(GIDSignIn.sharedInstance().currentUser != nil){
            if let invite = Invites.inviteDialog() {
                invite.setInviteDelegate(self)
                invite.setMessage("You should check out ATC Fitness. Here is a free 1 month pass")
                invite.setTitle("ATC Fitnesss Invite")
                invite.setDeepLink("http://www.aroundtheclock.fitness/download-app")
                invite.open()
            }
        }
         else{
            self.GoogleRequest()
        }
    }
    func inviteFinished(withInvitations invitationIds: [String], error: Error?) {
        if let error = error {
            print("Failed: " + error.localizedDescription)
        } else {
            print("\(invitationIds.count) invites sent")
        }
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
    
    @IBAction func onMyAccount(_ sender: Any) {
        self.view.endEditing(true)
    }
    @IBAction func onLogout(_ sender: UIButton) {
        self.view.endEditing(true)
        let loginManager = FBSDKLoginManager.init()
        loginManager.logOut()
        FBSDKAccessToken.setCurrent(nil)
        self.appDelegate.deleteLoginData()
        self.appDelegate.goToSplash()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        lblAboutMe.text = "\(textField.text ?? "")\(string)"
        
        appDelegate.aboutMe = lblAboutMe.text!
        appDelegate.saveLoginData()
        
        var userInfoForPost = [String: Any]()
        userInfoForPost["aboutMe"] = appDelegate.aboutMe
        userInfoForPost["email"] = appDelegate.userEmail
        userInfoForPost["firstName"] = appDelegate.userFirstName
        userInfoForPost["gym"] = appDelegate.currentGym
        userInfoForPost["lastName"] = appDelegate.userLastName
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
        let maxLength = 48
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}
