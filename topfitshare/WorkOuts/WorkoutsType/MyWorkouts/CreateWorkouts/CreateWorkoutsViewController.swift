//
//  CreateWorkoutsViewController.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/8/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit
import DropDown
import CoreData
import Firebase
import FirebaseStorage
import MBProgressHUD
import AFNetworking
import FBSDKLoginKit

class CreateWorkoutsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var navView: UIView!
    @IBOutlet weak var txtWorkoutName: UITextField!
    @IBOutlet weak var typeWorkoutsBtn: UIButton!
    @IBOutlet weak var btnWorkoutProfileImage: UIButton!
    @IBOutlet weak var menuBtn: UIButton!

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var changedImg:UIImage?
    var typeForActionSheet = 0
    var workoutImageUrl = ""
    var isSetWorkoutsImage = false
    var admin = false
    var currentGoalPosition = 0
    
    
    
    let menuDropDown = DropDown()
    let workoutTypeDropDown = DropDown()
    lazy var dropDowns: [DropDown] = {
        return [
            self.menuDropDown,
            self.workoutTypeDropDown
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem .setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navView.backgroundColor = UIColor(red: 39.0/255, green: 54.0/255, blue: 183.0/255, alpha: 1.0)
        
        customizeDropDown(self)
        menuDropDown.anchorView = menuBtn
        workoutTypeDropDown.anchorView = typeWorkoutsBtn
        menuDropDown.bottomOffset = CGPoint(x: -10, y: menuBtn.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        menuDropDown.dataSource = [
            "Logout"
        ]
        
        // Action triggered on selection
        menuDropDown.selectionAction = { [unowned self] (index, item) in
            //self.alcButton.setTitle(item, for: .normal)
            if index == 0 {
                let loginManager = FBSDKLoginManager.init()
                loginManager.logOut()
                FBSDKAccessToken.setCurrent(nil)
                self.appDelegate.isFaceBookLogin = false
                self.appDelegate.deleteLoginData()
                self.appDelegate.goToSplash()
            }
        }
        

        
        let gesture = UITapGestureRecognizer(target:self, action:#selector(self.handeTap));
        self.view.addGestureRecognizer(gesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.addSubview(navView)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navView.removeFromSuperview()
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
    
    @IBAction func onBack(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onMenu(_ sender: UIButton) {
        self.view.endEditing(true)
        menuDropDown.show()
    }
    @IBAction func onWorkoutType(_ sender: UIButton) {
        self.view.endEditing(true)
        workoutTypeDropDown.show()
    }

    @IBAction func onLoadWorkoutImage(_ sender: UIButton) {
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
        let imagePath = "workout/\(appDelegate.userName )_\(NSDate().timeIntervalSince1970).jpg"
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        storageRef.child(imagePath).putData(imageData as Data, metadata: metaData, completion: { metadata, error in
            MBProgressHUD.hide(for: self.view, animated: true)
            if error != nil {
                // Uh-oh, an error occurred!
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                self.workoutImageUrl = (metadata!.downloadURL()?.absoluteString)!
                self.btnWorkoutProfileImage.setImage(image, for: UIControlState.normal)
                self.isSetWorkoutsImage = true
            }
        })

    }
    
    @IBAction func onUseProfile(_ sender: UIButton) {
        self.view.endEditing(true)
        if appDelegate.curUserProfileImageUrl != nil {
            btnWorkoutProfileImage .setImageFor(UIControlState.normal, with: NSURL(string: appDelegate.curUserProfileImageUrl)! as URL)
            workoutImageUrl = appDelegate.curUserProfileImageUrl
            isSetWorkoutsImage = true
        }else{
            self.showAlert(msg: "Workout must have a title.", titleStr: "Input Error", delegate: self)
        }
    }
    
    @IBAction func onStartAddingExercises(_ sender: UIButton) {
        self.view.endEditing(true)
        if txtWorkoutName.text?.characters.count == 0 || txtWorkoutName.text?.characters.count == 0{
            self.showAlert(msg: "Workout must have a title.", titleStr: "Input Error", delegate: self)
            return
        }
        
        if isSetWorkoutsImage == false{
            self.showAlert(msg: "Workout must include an image..", titleStr: "Input Error", delegate: self)
            return
        }
        let vc = EditWorkoutsViewController()
        vc.workoutsImageUrl = workoutImageUrl
        vc.workoutName = txtWorkoutName.text
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func handeTap(){
        self.view.endEditing(true)
    }
    
    func showAlert(msg:String, titleStr:String, delegate:Any){
        let alert = UIAlertController(title: titleStr, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
