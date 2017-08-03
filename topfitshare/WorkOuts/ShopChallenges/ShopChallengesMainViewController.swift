//
//  ShopChallengesMainViewController.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/7/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit
import MBProgressHUD
import Firebase
import DropDown
import FBSDKLoginKit

class ShopChallengesMainViewController: UIViewController ,LUExpandableTableViewDataSource, LUExpandableTableViewDelegate, UserInGymTableViewSectionHaderDelegate{
    @IBAction func onMenu(_ sender: Any) {
        menuDropDown.show()
    }
    @IBOutlet weak var whoesHereTableView: LUExpandableTableView!
    @IBOutlet weak var moveView: UIView!

    @IBOutlet weak var btnMenu: UIButton!
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet var navView: UIView!
    var parentNavigationController : UINavigationController?
    
    @IBOutlet weak var profileImg: UIImageView!
    
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblPointsNum: UILabel!
    @IBOutlet weak var lblAbout: UILabel!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var gym:[String] = []
    var allFoundUser:[NSDictionary] = []
    var myGym = ""
    let menuDropDown = DropDown()
    lazy var dropDowns: [DropDown] = {
        return[
        self.menuDropDown]
    }()
    
    var currentSetsCount = 0
    
    fileprivate let sectionHeaderReuseIdentifier = "UserAndGymHeader"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeDropDown(self)
        menuDropDown.anchorView = btnMenu
        menuDropDown.bottomOffset = CGPoint(x: -10, y: btnMenu.bounds.height)
        menuDropDown.dataSource = [
        "Logout"]
        
        menuDropDown.selectionAction = { [unowned self] (index, item) in
            if index == 0{
                let loginManager = FBSDKLoginManager.init()
                loginManager.logOut()
                FBSDKAccessToken.setCurrent(nil)
                self.appDelegate.deleteLoginData()
                self.appDelegate.goToSplash()
            }
        }
        whoesHereTableView.register(UINib.init(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserItem")
        whoesHereTableView.register(UINib(nibName: "UserInGymTableViewSectionHader", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: sectionHeaderReuseIdentifier)
        
        profileImg.contentMode = .scaleAspectFill
        profileImg.clipsToBounds = true
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        
        if appDelegate.curUserProfileImageUrl != "" {
            profileImg.setImageWith(URL.init(string: appDelegate.curUserProfileImageUrl)!)
        }
        
        if appDelegate.aboutMe != "" {
            lblAbout.text = appDelegate.aboutMe
        }else{
            lblAbout.text = ""
        }
        
        if appDelegate.currentGym != "" {
            lblLocation.text = appDelegate.currentGym
        }else{
            lblLocation.text = "Alico"
        }
        lblPointsNum.text = "\(appDelegate.pointsNumber ) Points"
        
        
        myGym = appDelegate.currentGym
        
        gym.append(appDelegate.currentGym)
        getUsersWithGym(arrayGyms: gym)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationController?.navigationBar.addSubview(navView)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navView.removeFromSuperview()
    }
    
        func customizeDropDown(_ sender: AnyObject) {
            DropDown.setupDefaultAppearance()
            
            dropDowns.forEach {
                $0.cellNib = UINib(nibName: "DropDownCell", bundle: Bundle(for: DropDownCell.self))
                $0.cellHeight = 35
                $0.customCellConfiguration = nil
            }
        }
        
        
    func getUsersWithGym(arrayGyms:[String]){
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        
        let rootR = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com/")
        
        rootR.queryOrderedByKey().observe(DataEventType.value, with: {snapchat in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            self.allFoundUser.removeAll()
            
            for oneGym in arrayGyms {
                var gymAndUser:[String:Any] = [:]
                gymAndUser["gym"] = oneGym
                
                for section in snapchat.children{
                    let child = section as! DataSnapshot
                    if child.key == "user info" {
                        for data in child.children {
                            let parchild = data as! DataSnapshot
                            let dic = parchild.value as! NSDictionary
                            
                            if dic["username"] as? String == self.appDelegate.userName{
                                self.myGym = dic["gym"] as! String
                            }
                        }
                    }
                    
                    if child.key == self.myGym {
                        var users:[NSDictionary] = []
                        for data in child.children{
                            let parchild = data as! DataSnapshot
                            let dic = parchild.value as! NSDictionary
                            
                            var userInfo = [String: Any]()
                            userInfo["username"] = dic["username"]
                            userInfo["profileUrl"] = dic["profileUrl"]
                            
                            users.append(userInfo as NSDictionary)
                        }
                        gymAndUser["users"] = users
                        self.allFoundUser.append(gymAndUser as NSDictionary)
                    }
                }
            }
            
            
            self.whoesHereTableView.expandableTableViewDelegate = self
            self.whoesHereTableView.expandableTableViewDataSource = self
            self.currentSetsCount = self.gym.count
            self.updateTableViewAndViewPostion()
            self.whoesHereTableView.reloadData()
        })
    }
    
    
    func updateTableViewAndViewPostion(){
        whoesHereTableView.frame = CGRect.init(x: whoesHereTableView.frame.origin.x, y: whoesHereTableView.frame.origin.y, width: whoesHereTableView.frame.size.width, height: CGFloat(currentSetsCount * 44))
        moveView.frame = CGRect.init(x: moveView.frame.origin.x, y: whoesHereTableView.frame.origin.y + CGFloat(currentSetsCount * 44), width: moveView.frame.size.width, height: moveView.frame.size.height)
        
        if currentSetsCount > 4 {
            whoesHereTableView.frame = CGRect.init(x: whoesHereTableView.frame.origin.x, y: whoesHereTableView.frame.origin.y, width: whoesHereTableView.frame.size.width, height: 145)
            moveView.frame = CGRect.init(x: moveView.frame.origin.x, y: whoesHereTableView.frame.origin.y + 145, width: moveView.frame.size.width, height: moveView.frame.size.height)
        }
    }
    
//    @IBAction func onLeaveFeedback(_ sender: UIButton) {
//        let urlAddress = "https://www.facebook.com/pg/atc.boyscout/reviews/?ref=page_internal"
//        UIApplication.shared.open(URL(string: urlAddress)!, options: [:], completionHandler: nil)
//    }
    @IBAction func onMyZone(_ sender: UIButton) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "MYZONE", message: "You will be redirected to download MYZONE.", preferredStyle: .alert)
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { [weak alert] (_) in
            let urlAddress = "itms-apps://itunes.apple.com/us/app/myzone/id969938732?mt=8"
            UIApplication.shared.open(URL(string: urlAddress)!, options: [:], completionHandler: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .default, handler:nil))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
//    @IBAction func onShop(_ sender: UIButton) {
//        let vc = ShopMainViewController()
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//    @IBAction func onChallenges(_ sender: UIButton) {
//        let vc = ChallengesMainViewController()
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
    
    @IBAction func onRewards(_ sender: UIButton) {
        let vc = RewardsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    // MARK: - LUExpandableTableViewDataSource
    func numberOfSections(in expandableTableView: LUExpandableTableView) -> Int {
        return gym.count
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, numberOfRowsInSection section: Int) -> Int {
        
        if allFoundUser.count > section
        {
            let oneGymandUser = allFoundUser[section] as! [String:Any]
            if oneGymandUser["users"] != nil && (oneGymandUser["users"] as! [Dictionary<String, Any>]).count > 0 {
                self.currentSetsCount = self.gym.count + (oneGymandUser["users"] as! [Dictionary<String, Any>]).count
                self.updateTableViewAndViewPostion()
                return  (oneGymandUser["users"] as! [Dictionary<String, Any>]).count
            }else{
                return 0
            }
        }else {
            return 0
        }
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: "UserItem") as? UserCell else {
            assertionFailure("Cell shouldn't be nil")
            return UITableViewCell()
        }
        
        let oneGym = allFoundUser[indexPath.section] as! [String:Any]
        let oneUser = (oneGym["users"] as! [Dictionary<String, Any>])[indexPath.row] 
        if oneUser["profileUrl"] != nil {
            cell.userProfileImg.setImageWith(URL(string: oneUser["profileUrl"] as! String)!)
        }
        cell.lblUserName.text = oneUser["username"] as? String
        
        return cell
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, sectionHeaderOfSection section: Int) -> LUExpandableTableViewSectionHeader {
        guard let sectionHeader = expandableTableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeaderReuseIdentifier) as? UserInGymTableViewSectionHader else {
            assertionFailure("Section header shouldn't be nil")
            return LUExpandableTableViewSectionHeader()
        }
        
        sectionHeader.lblGymWith.text = "Who's here.. \(self.allFoundUser.count)"
        
        return sectionHeader
    }
    
    // MARK: - LUExpandableTableViewDelegate
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /// Returning `UITableViewAutomaticDimension` value on iOS 9 will cause reloading all cells due to an iOS 9 bug with automatic dimensions
        return 44
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForHeaderInSection section: Int) -> CGFloat {
        /// Returning `UITableViewAutomaticDimension` value on iOS 9 will cause reloading all cells due to an iOS 9 bug with automatic dimensions
        return 44
    }
    
    // MARK: - Optional
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, didSelectRowAt indexPath: IndexPath) {
        print("Did select cell at section \(indexPath.section) row \(indexPath.row)")
        
        let oneGym = allFoundUser[indexPath.section] as! [String:Any]
        let oneUser = (oneGym["users"] as! [Dictionary<String, Any>])[indexPath.row]

        let vc = UserProfileViewController()
        vc.userName = oneUser["username"] as? String
        self.navigationController?.pushViewController(vc, animated: true)
        
        self.view.endEditing(true);
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, didSelectSectionHeader sectionHeader: LUExpandableTableViewSectionHeader, atSection section: Int) {
        print("Did select section header at section \(section)")
        self.view.endEditing(true);
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("Will display cell at section \(indexPath.section) row \(indexPath.row)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, willDisplaySectionHeader sectionHeader: LUExpandableTableViewSectionHeader, forSection section: Int) {
        print("Will display section header for section \(section)")
    }
    
    func commentPreViewAction(comment: String) {
        
    }
    
}
