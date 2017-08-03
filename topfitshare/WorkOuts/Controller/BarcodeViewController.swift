//
//  BarcodeViewController.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/12/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit
import DropDown
import FacebookShare
import FBSDKLoginKit
import FBSDKShareKit
import Social
import Firebase
import MBProgressHUD

class BarcodeViewController: UIViewController {

    @IBOutlet var navView: UIView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var barcodeImage: UIImageView!
    @IBOutlet weak var lblBarcode: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let menuDropDown = DropDown()
    lazy var dropDowns: [DropDown] = {
        return [
            self.menuDropDown
        ]
    }()
    
    var isUpdated:Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem .setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navView.backgroundColor = UIColor(red: 39.0/255, green: 54.0/255, blue: 183.0/255, alpha: 1.0)
        
        customizeDropDown(self)
        menuDropDown.anchorView = btnMenu
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        menuDropDown.bottomOffset = CGPoint(x: -10, y: btnMenu.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        menuDropDown.dataSource = [
            "Logout",
            "Change Member Number"
        ]
        
        var barcodeStr = self.appDelegate.memberNum
        
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
            if index == 1{
                self.isUpdated = true;
                //1. Create the alert controller.
                let alert = UIAlertController(title: "Member Number", message: "Please enter your member number:", preferredStyle: .alert)
                
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
                        if self.isUpdated == true {
                            self.isUpdated = false
                            var updateToken = [String: Any]()
                            updateToken["memberNumber"] = textField?.text
                            rootR.child(self.appDelegate.userName).updateChildValues(updateToken)
                            self.lblBarcode.text = textField?.text
                            barcodeStr = self.lblBarcode.text!
                            let data = barcodeStr.data(using: .ascii)
                            let filter = CIFilter(name: "CICode128BarcodeGenerator")
                            filter?.setValue(data, forKey: "inputMessage")
                            
                            self.barcodeImage.image = UIImage(ciImage: (filter?.outputImage)!)
                        }
                        
                    })
                    
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
                    
                    
                }))
                
                // 4. Present the alert.
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        let data = barcodeStr.data(using: .ascii)
        let filter = CIFilter(name: "CICode128BarcodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        
        barcodeImage.image = UIImage(ciImage: (filter?.outputImage)!)
    }
    
    func showAlert(msg:String, titleStr:String, delegate:Any){
        let alert = UIAlertController(title: titleStr, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onMenu(_ sender: UIButton) {
        menuDropDown.show()
    }
    @IBAction func onFacebookCheckin(_ sender: UIButton) {
//        let photo = Photo(image: barcodeImage.image!, userGenerated: true)
//        let content = PhotoShareContent(photos: [photo])
//        do {
//            try ShareDialog.show(from: self, content: content)
//        }
//        catch let error {
//            print(error.localizedDescription)
//        }
        
        let composeSheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        composeSheet?.setInitialText("Hello, Facebook!")
        composeSheet?.add(barcodeImage.image!)
        
        present(composeSheet!, animated: true, completion: nil)
    }
}
