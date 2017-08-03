//
//  NotificationViewController.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/3/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit
import Firebase
import DropDown
import MBProgressHUD
import FBSDKLoginKit

class NotificationViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    @IBOutlet var navView: UIView!
    @IBOutlet weak var btnMenu: UIButton!
    
    @IBOutlet weak var NotificationTableView: UITableView!
    
    
    var arrNotifications:[DataSnapshot] = []

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let menuDropDown = DropDown()
    lazy var dropDowns: [DropDown] = {
        return [
            self.menuDropDown
        ]
    }()
    
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
        
        NotificationTableView.register(UITableViewCell.self, forCellReuseIdentifier: "NotificationItem")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.addSubview(navView)
        self.getNotificationsForOwn()
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
    func getNotificationsForOwn(){
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        
        let rootR = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com/notifications")
        
        rootR.child(appDelegate.userName).queryOrderedByKey().observe(DataEventType.value, with: {snapchat in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            self.arrNotifications.removeAll()
            
            for data in snapchat.children{
                let child = data as! DataSnapshot
                self.arrNotifications.append(child)
            }
            //newest first
            self.arrNotifications.reverse()
            if self.arrNotifications.count == 0{
                self.NotificationTableView.isHidden = true
            }
            self.NotificationTableView.reloadData()
        })
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onMenu(_ sender: UIButton) {
        menuDropDown.show()
    }
        
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrNotifications.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "NotificationItem") as UITableViewCell!
        // set the text from the data model
        let data = arrNotifications[indexPath.row]
        let notification = data.value as! NSDictionary
        cell.textLabel?.text = "\(notification["notifSender"] as! String) has liked your workout, \(notification["notifWorkout"] as! String)"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = arrNotifications[indexPath.row]
        let notification = data.value as! NSDictionary
        let vc = UserProfileViewController()
        vc.userName = notification["notifSender"] as? String
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
