//
//  RewardsViewController.swift
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

class RewardsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var navView: UIView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var lblMyPoints: UILabel!
    @IBOutlet weak var RewardsTableView: UITableView!

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let menuDropDown = DropDown()
    lazy var dropDowns: [DropDown] = {
        return [
            self.menuDropDown
        ]
    }()
    
    let rewards:[String] = ["Small Crystal Water","Kid's Crafts","Key Tag","Protein Shake with Juice","Protein Shake","Large Towel","Small Towel","Lock","Free STC","Hat","T-Shirt","Bod Pod","Free Month of Membership","PNO","Free PT"]
    let points:[String] = ["50","80","100","150","150","200","200","200","600","700","800","1000","1200","1600","2500"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem .setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navView.backgroundColor = UIColor(red: 39.0/255, green: 54.0/255, blue: 183.0/255, alpha: 1.0)        
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
        RewardsTableView.register(UINib.init(nibName: "PointsCell", bundle: nil), forCellReuseIdentifier: "PointsItem")
        
        lblMyPoints.text = "You have \(appDelegate.pointsNumber) points"
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
    @IBAction func onBack(_ sender: Any) {
        self.view.endEditing(true);
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onMenu(_ sender: Any) {
        menuDropDown.show()
    }
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rewards.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PointsItem", for: indexPath) as! PointsCell
        
        cell.lblPointsName.text = rewards[indexPath.row]
        cell.lblPoints.text = points[indexPath.row]
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
