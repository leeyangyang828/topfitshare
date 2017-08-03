//
//  TrainerWorkoutsViewController.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/8/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit
import DropDown
import Firebase
import MBProgressHUD
import FBSDKLoginKit

class TrainerWorkoutsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var navView: UIView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var SharedExerciesTableView: UITableView!

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let menuDropDown = DropDown()
    lazy var dropDowns: [DropDown] = {
        return [
            self.menuDropDown
        ]
    }()
    
    var trainingWorkouts:[NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem .setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navView.backgroundColor = UIColor(red: 39.0/255, green: 54.0/255, blue: 183.0/255, alpha: 1.0)
        
        customizeDropDown(self)
        menuDropDown.anchorView = menuBtn
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
                self.appDelegate.deleteLoginData()
                self.appDelegate.goToSplash()
            }
        }
        
        SharedExerciesTableView.register(UINib.init(nibName: "WorkoutsOfUsersCell", bundle: nil), forCellReuseIdentifier: "WorkoutsOfUsersItem")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.addSubview(navView)
        self.getsharedExericesList()
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
    func getsharedExericesList(){
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        
        let rootR = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com/Trainer Workout")
        
        rootR.queryOrderedByKey().observe(DataEventType.value, with: {snapchat in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            self.trainingWorkouts.removeAll()
            for data in snapchat.children{
                let child = data as! DataSnapshot
                let dic = child.value as! NSDictionary
                self.trainingWorkouts.append(dic)
            }
            if self.trainingWorkouts.count == 0{
                self.SharedExerciesTableView.isHidden = true
            }
            
            self.SharedExerciesTableView.reloadData()
        })
    }
    @IBAction func onBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onMenu(_ sender: UIButton) {
        menuDropDown.show()
    }
    @IBAction func onRequestTrainer(_ sender: UIButton) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Request Trainer", message: "Would you like to be contacted about personal training opportunities?", preferredStyle: .alert)
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { [weak alert] (_) in
            var userInfoForPost = [String: Any]()
            userInfoForPost["email"] = self.appDelegate.userEmail
            userInfoForPost["firstName"] = self.appDelegate.userFirstName
            userInfoForPost["goal"] = "Training"
            userInfoForPost["lastName"] = self.appDelegate.userLastName
            let rootR = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com/")
            let rootRForRegister = rootR.child("Inquiries")
            rootRForRegister.setValue(userInfoForPost)
            
            let alertSub = UIAlertController(title: "Thank you", message: "We will contact you by email soon.", preferredStyle: .alert)
            alertSub.addAction(UIAlertAction(title: "NO", style: .default, handler: nil))
            self.present(alertSub, animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .default, handler: { [weak alert] (_) in
            
            
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return trainingWorkouts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutsOfUsersItem", for: indexPath) as! WorkoutsOfUsersCell
        
        let workout = trainingWorkouts[indexPath.row]
        
        cell.workoutName.text = workout["workout"] as? String
        cell.workoutUserName.text = workout["username"] as? String
        if workout["image"] != nil {
            cell.workoutProfile.setImageWith(NSURL(string: (workout["image"] as? String)!)! as URL)
        }else{
            cell.workoutProfile.image = UIImage.init(named: "workout_logo.png")
        }
        cell.lblLike.isHidden = true
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let workout = trainingWorkouts[indexPath.row]
        let vc = WorkOutsPreViewController()
        vc.mine = false
        vc.infoSelectedWorkOuts = workout as! [String : Any]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
