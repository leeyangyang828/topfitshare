//
//  UserProfileViewController.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/13/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit
import DropDown
import CoreData
import Firebase
import MBProgressHUD
import FBSDKLoginKit

class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var navView: UIView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var SelectedUsersWorkoutTableview: UITableView!
    @IBOutlet weak var useProfileImage: UIImageView!
    @IBOutlet weak var lblUserAbout: UILabel!
    @IBOutlet weak var lblUserGym: UILabel!
    @IBOutlet weak var lblUserPoints: UILabel!
    @IBOutlet weak var lblUserName: UILabel!

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let menuDropDown = DropDown()
    lazy var dropDowns: [DropDown] = {
        return [
            self.menuDropDown
        ]
    }()
    
    var userWorkouts:[NSDictionary] = []
    
    var userName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem .setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navView.backgroundColor = UIColor(red: 39.0/255, green: 54.0/255, blue: 183.0/255, alpha: 1.0)
        
        lblUserName.text = userName
        
        useProfileImage.contentMode = .scaleAspectFill
        useProfileImage.clipsToBounds = true
        useProfileImage.layer.cornerRadius = useProfileImage.frame.size.width/2
        
        customizeDropDown(self)
        menuDropDown.anchorView = btnMenu
        menuDropDown.bottomOffset = CGPoint(x: -10, y: btnMenu.bounds.height)
        
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
        SelectedUsersWorkoutTableview.register(UINib.init(nibName: "WorkoutsOfUsersCell", bundle: nil), forCellReuseIdentifier: "WorkoutsOfUsersItem")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.addSubview(navView)
        self.getAvailWorkout()
        
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
    func getAvailWorkout(){
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        
        let rootR = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com/user info")
        
        rootR.queryOrderedByKey().observe(DataEventType.value, with: {snapchat in
            MBProgressHUD.hide(for: self.view, animated: true)
            for data in snapchat.children{
                let child = data as! DataSnapshot
                if self.userName == child.key{
                    let dic = child.value as! NSDictionary
                    self.lblUserAbout.text = (dic["aboutMe"] as! String)
                    self.lblUserGym.text = (dic["gym"] as! String)
                    self.lblUserPoints.text = "\(dic["pointsNumber"] ?? "") points"
                    if(dic["profileUrl"] != nil){
                        self.useProfileImage.setImageWith(URL.init(string: dic["profileUrl"] as! String)!)
                    }
                }
            }
            for workouts in self.appDelegate.availWorkouts{
                if (workouts["username"] as! String) == self.userName{
                    self.userWorkouts.append(workouts)
                }
            }
            self.SelectedUsersWorkoutTableview.reloadData()
        })
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        self.view.endEditing(true);
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onManu(_ sender: UIButton) {
        menuDropDown.show()
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
        return userWorkouts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutsOfUsersItem", for: indexPath) as! WorkoutsOfUsersCell
        
        let workout = userWorkouts[indexPath.row]
        
        cell.workoutName.text = workout["workout"] as? String
        cell.workoutUserName.text = workout["username"] as? String
        if workout["image"] != nil {
            cell.workoutProfile.setImageWith(NSURL(string: (workout["image"] as? String)!)! as URL)
        }else{
            cell.workoutProfile.image = UIImage.init(named: "workout_logo.png")
        }
        let likes = workout["likes"] as! Int
        cell.lblLike.text = "\(likes)"
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let workout = userWorkouts[indexPath.row]
        let vc = WorkOutsPreViewController()
        if workout["username"] as? String == appDelegate.userName {
            vc.mine = true
        }else{
            vc.mine = false
        }
        vc.infoSelectedWorkOuts = workout as! [String : Any]
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
