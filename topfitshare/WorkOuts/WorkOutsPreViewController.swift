//
//  WorkOutsPreViewController.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/11/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit
import DropDown
import CoreData
import Firebase
import MBProgressHUD
import FBSDKLoginKit

class WorkOutsPreViewController: UIViewController , LUExpandableTableViewDataSource, LUExpandableTableViewDelegate, MyExpandableTableViewSectionHeaderDelegate{
    
    @IBOutlet var ownNavView: UIView!
    @IBOutlet var btnShare: UIButton!

    @IBOutlet var navView: UIView!
    @IBOutlet weak var btnFitLove: UIButton!
    @IBOutlet weak var btnMenu: UIButton!
    
    @IBOutlet weak var PreWorkoutsTableView: LUExpandableTableView!
    @IBOutlet weak var lblWorkoutsName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var lblLoveCount: UILabel!
    @IBOutlet weak var selectedUserName: UIButton!
    
    @IBOutlet weak var currentCommentView: UIView!
    @IBOutlet weak var lblComments: UILabel!
    
    var infoSelectedWorkOuts:[String:Any] = [:]
    var madeExercies:[String] = []
    var madeSets:[String] = []
    var madeComments:[String] = []
    var madeReps:[String] = []
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let menuDropDown = DropDown()
    lazy var dropDowns: [DropDown] = {
        return [
            self.menuDropDown
        ]
    }()
    fileprivate let sectionHeaderReuseIdentifier = "MySectionHeader"
    
    var username = "" //workout maker username
    var isSelectedFitLove = false
    var isUpdate = false
    var mine = false //check if viewing own workout created
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        self.navigationItem .setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navView.backgroundColor = UIColor(red: 39.0/255, green: 54.0/255, blue: 183.0/255, alpha: 1.0)

        currentCommentView.isHidden = true
        
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
        
        // Do any additional setup after loading the view.
        
        madeExercies = stingToArrayForWorkout(str: infoSelectedWorkOuts["exercise"] as! String)
        madeSets = stingToArrayForWorkout(str: infoSelectedWorkOuts["sets"] as! String)
        madeReps = stingToArrayForWorkout(str: infoSelectedWorkOuts["reps"] as! String)
        madeComments = stingToArrayForWorkout(str: infoSelectedWorkOuts["comment"] as! String)
        
        lblWorkoutsName.text = infoSelectedWorkOuts["workout"] as? String
        if(!mine){
            let likes = infoSelectedWorkOuts["likes"] as! Int
            lblLoveCount.text = "Likes \(likes)"
            btnFitLove.isSelected = self.checkingFitLoveIs(username: (infoSelectedWorkOuts["username"] as? String)!, workoutName: (infoSelectedWorkOuts["workout"] as? String)!)
        }
        selectedUserName.setTitle(infoSelectedWorkOuts["username"] as? String, for: .normal)
        self.username = infoSelectedWorkOuts["username"] as! String
    
        profileImage.contentMode = UIViewContentMode.scaleAspectFill
        profileImage.clipsToBounds = true
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        
        self.profileImage.setImageWith(NSURL(string: (infoSelectedWorkOuts["image"] as? String)!)! as URL)
        
        
        //AddOfcurrentUserTableView.register(RepsEditCell.self, forCellReuseIdentifier: "RepsEditItem")
        PreWorkoutsTableView.register(UINib.init(nibName: "RepsEditCell", bundle: nil), forCellReuseIdentifier: "RepsEditItem")
        PreWorkoutsTableView.register(UINib(nibName: "MyExpandableTableViewSectionHeader", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: sectionHeaderReuseIdentifier)
        
        PreWorkoutsTableView.expandableTableViewDelegate = self
        PreWorkoutsTableView.expandableTableViewDataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(!mine){
            self.navigationController?.navigationBar.addSubview(navView)
        }else{
            self.navigationController?.navigationBar.addSubview(ownNavView)
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(!mine){
            navView.removeFromSuperview()

        }else{
            ownNavView.removeFromSuperview()

        }
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
    
    
    func checkingFitLoveIs(username:String, workoutName:String) -> Bool{
        let context = self.appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Fitlove")
        request.predicate = NSPredicate(format: "username == %@ AND workoutsName == %@", username, workoutName)
        do {
            let fetchedObjects = try context.fetch(request) as! [Fitlove]
            if fetchedObjects.count > 0 {
                return true;
            }else{
                return false;
            }
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }
    
    func stingToArrayForWorkout(str:String) -> [String] {
        var arrItems:[String] = []
        let strReplacedWithChar = str.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        arrItems = strReplacedWithChar.components(separatedBy: ", ")
        return arrItems
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func onShare(_ sender: UIButton) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Share now", message: "Would you like to share this workout?", preferredStyle: .alert)
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { [weak alert] (_) in
            
            let context = self.appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Fitlove")
            request.predicate = NSPredicate(format: "username == %@ AND workoutsName == %@", (self.infoSelectedWorkOuts["username"] as? String)!, (self.infoSelectedWorkOuts["workout"] as? String)!)
            do {
                let fetchedObjects = try context.fetch(request) as! [Fitlove]
                if fetchedObjects.count > 0 {
                    self.isSelectedFitLove = true
                }else{
                    let fitlove = NSEntityDescription.insertNewObject(forEntityName: "Fitlove", into: context) as! Fitlove
                    fitlove.username = self.infoSelectedWorkOuts["username"] as? String
                    fitlove.workoutsName = self.infoSelectedWorkOuts["workout"] as? String
                    fitlove.isFitLove = true
                    try context.save()
                    self.isSelectedFitLove = false
                }
                
            } catch {
                fatalError("Failed to fetch employees: \(error)")
            }
            
            if self.isSelectedFitLove == false{
                self.isSelectedFitLove = true
                let rootR = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com/")
                let rootRForHaveingSharedNum = rootR.child("user info")
                
                if self.appDelegate.userName != "" {
                    let rootRForAdding = rootRForHaveingSharedNum.child(self.appDelegate.userName)
                    
                    var userInfoForPost = [String: Any]()
                    
                    var num = self.appDelegate.pointsNumber
                    num = num + 1
                    self.appDelegate.pointsNumber = num
                    self.appDelegate.saveLoginData()
                    
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
                    rootRForAdding.setValue(userInfoForPost)
                }
                
                let rootRForSharedWorkouts = rootR.child("workouts")
                var userInfoForShared = [String: Any]()
                userInfoForShared["comment"] = self.infoSelectedWorkOuts["comment"] as? String
                userInfoForShared["sets"] = self.infoSelectedWorkOuts["sets"] as? String
                userInfoForShared["exercise"] = self.infoSelectedWorkOuts["exercise"] as? String
                userInfoForShared["reps"] = self.infoSelectedWorkOuts["reps"] as? String
                userInfoForShared["likes"] = 0
                userInfoForShared["username"] = self.appDelegate.userName
                userInfoForShared["goal"] = self.infoSelectedWorkOuts["goal"] as? String
                userInfoForShared["image"] = self.infoSelectedWorkOuts["image"] as? String
                userInfoForShared["workout"] = self.infoSelectedWorkOuts["workout"] as? String
                
                let postRef = rootRForSharedWorkouts.childByAutoId()
                postRef.setValue(userInfoForShared)
                
                if userInfoForShared["goal"] as? String == "Strength Training"{
                    self.appDelegate.workoutSelectedType = 1
                    let vc = StrengthTrainWorkoutsViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }else if userInfoForShared["goal"] as? String == "Cardio Training"{
                    self.appDelegate.workoutSelectedType = 2
                    let vc = StrengthTrainWorkoutsViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }else{
                let alert = UIAlertController(title: "", message: "You already shared this workout.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "NO", style: .default, handler: { [weak alert] (_) in
            
            
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onLove(_ sender: UIButton) {
        
        if checkingFitLoveIs(username: (self.infoSelectedWorkOuts["username"] as? String)!, workoutName: (self.infoSelectedWorkOuts["workout"] as? String)!) == false {
            
            btnFitLove.isSelected = true
         
            let context = self.appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Fitlove")
            request.predicate = NSPredicate(format: "username == %@ AND workoutsName == %@", (self.infoSelectedWorkOuts["username"] as? String)!, (self.infoSelectedWorkOuts["workout"] as? String)!)
            do {
                let fetchedObjects = try context.fetch(request) as! [Fitlove]
                if fetchedObjects.count > 0 {
                    let existedFitLove = fetchedObjects[0]
                    self.isSelectedFitLove = existedFitLove.isFitLove
                }else{
                    let fitlove = NSEntityDescription.insertNewObject(forEntityName: "Fitlove", into: context) as! Fitlove
                    fitlove.username = self.infoSelectedWorkOuts["username"] as? String
                    fitlove.workoutsName = self.infoSelectedWorkOuts["workout"] as? String
                    fitlove.isFitLove = true
                    try context.save()
                    self.isSelectedFitLove = false
                }
                
            } catch {
                fatalError("Failed to fetch employees: \(error)")
            }

            let mRootForPush: DatabaseReference = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com/")
            let notificationRef = mRootForPush.child("notifications")
            var userInfoForPost = [String: Any]()
            userInfoForPost["notifReceiver"] = self.username //username of workout maker
            userInfoForPost["notifSender"] = self.appDelegate.userName //username of workout liker
            userInfoForPost["notifWorkout"] = self.infoSelectedWorkOuts["workout"] as! String
            notificationRef.child(self.username).childByAutoId().setValue(userInfoForPost)
            
            //sending push notification by using http request post
            if !self.mine{
                self.sendPushNotificationToReceiver(receiver:self.username, workoutsName:self.infoSelectedWorkOuts["workout"] as! String)
            }
            

            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Loading"
            let myRootRef: DatabaseReference = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com/workouts")
            myRootRef.queryOrderedByKey().observe(DataEventType.value, with: {snapchat in
                
                MBProgressHUD.hide(for: self.view, animated: true)

                
                if self.isSelectedFitLove == false && self.isUpdate == false {
                    var keySaved = ""
                    for data in snapchat.children{
                        let child = data as! DataSnapshot
                        let dic = child.value as! NSDictionary
                        self.appDelegate.availWorkouts.append(dic)
                        
                        if dic["workout"] as! String == self.infoSelectedWorkOuts["workout"] as! String && dic["username"] as! String == self.infoSelectedWorkOuts["username"] as! String {
                            keySaved = child.key
                            
                            let postRef = myRootRef.child(keySaved)
                            var likes = self.infoSelectedWorkOuts["likes"] as! Int
                            likes = likes + 1
                            
                            var updateLikes = [String: Any]()
                            updateLikes["likes"] = likes
                            postRef.updateChildValues(updateLikes)
                            
                            self.lblLoveCount.text = "Likes \(likes)"
                            
                        }
                        self.isUpdate = true

                    }
                    self.isUpdate = true
                    let mRootForPush: DatabaseReference = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com/")
                    let notificationRef = mRootForPush.child("notifications")
                    var userInfoForPost = [String: Any]()
                    userInfoForPost["memberNumber"] = self.appDelegate.memberNum
                    userInfoForPost["notifReceiver"] = self.infoSelectedWorkOuts["username"] as! String
                    userInfoForPost["notifSender"] = self.appDelegate.userName
                    userInfoForPost["notifWorkout"] = self.infoSelectedWorkOuts["workout"] as! String
                    userInfoForPost["pointsNumber"] = self.appDelegate.pointsNumber
                    notificationRef.child(self.appDelegate.userName).childByAutoId().setValue(userInfoForPost)
                    
                    //sending push notification by using http request post
                    
                    self.sendPushNotificationToReceiver(receiver:self.infoSelectedWorkOuts["username"] as! String, workoutsName:self.infoSelectedWorkOuts["workout"] as! String)
                    self.isSelectedFitLove = true
                }
            })

        }else{
            let alert = UIAlertController(title: "", message: "You already liked this workout.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    func sendPushNotificationToReceiver(receiver:String, workoutsName:String){
        let rootR = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com")

        rootR.child("user info").child(receiver).queryOrderedByKey().observe(DataEventType.value, with: {snapchat in
            
            let dic = snapchat.value as! NSDictionary
            if dic["token"] != nil && dic["token"] as! String != ""{
                let url = NSURL(string: "https://fcm.googleapis.com/fcm/send")
                let postParams: [String : Any] = ["to": dic["token"] as! String, "notification": ["body": "\(self.appDelegate.userName) has liked your workout, \(workoutsName)", "title": ""]]
                
                let request = NSMutableURLRequest(url: url! as URL)
                request.httpMethod = "POST"
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.setValue("key=AAAAmQXjwgc:APA91bHp7g9wrv2FVWxYbvXYgCha4tiUKUTS1FhtlSV77ZTB0VDR17THp8BnIVkyAPb1gJBdaJ2COZtx-yA0_YMcvMHGCQzuMIYZB1kQEYTKLMTCzq5sRzs-1zP3kshrKSzIJlLLgtUu", forHTTPHeaderField: "Authorization")
                
                do
                {
                    request.httpBody = try JSONSerialization.data(withJSONObject: postParams, options: JSONSerialization.WritingOptions())
                    print("My paramaters: \(postParams)")
                }
                catch
                {
                    print("Caught an error: \(error)")
                }
                
                let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                    if let realResponse = response as? HTTPURLResponse
                    {
                        if realResponse.statusCode != 200
                        {
                            print("Not a 200 response")
                        }
                    }
                    if let postString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as String?
                    {
                        print("POST: \(postString)")
                    }
                }
                
                task.resume()
            }
        })
        
    }
    
    @IBAction func onMenu(_ sender: UIButton) {
        menuDropDown.show()
    }
    @IBAction func onCloseCommentView(_ sender: UIButton) {
        currentCommentView.isHidden = true
    }
    @IBAction func onselectedWorkUserName(_ sender: UIButton) {
        let vc = UserProfileViewController()
        vc.userName = infoSelectedWorkOuts["username"] as? String
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - LUExpandableTableViewDataSource
    func numberOfSections(in expandableTableView: LUExpandableTableView) -> Int {
        return madeExercies.count
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, numberOfRowsInSection section: Int) -> Int {
        let setsArray = madeSets[section].components(separatedBy: " ")
        let rows = Int(setsArray[0])
        return rows!
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: "RepsEditItem") as? RepsEditCell else {
            assertionFailure("Cell shouldn't be nil")
            return UITableViewCell()
        }
        
        cell.lblOneSet.text = "Set \(indexPath.row + 1)"
        
        var preS = 0
        if indexPath.section > 0 {
            for i in 0...indexPath.section-1{
                let arrySets = madeSets[i].components(separatedBy: " ")
                let value = Int(arrySets[0])
                preS = preS + value!
            }
        }
        cell.lblOneValue.text = madeReps[preS + indexPath.row]
        
        cell.txtOneSet.isHidden = true
        cell.lblOneValue.isHidden = false
        return cell
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, sectionHeaderOfSection section: Int) -> LUExpandableTableViewSectionHeader {
        guard let sectionHeader = expandableTableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeaderReuseIdentifier) as? MyExpandableTableViewSectionHeader else {
            assertionFailure("Section header shouldn't be nil")
            return LUExpandableTableViewSectionHeader()
        }
        
        var expandableStr = ""
        var isAvailable = true
        if section > 0 {
            for i in 0...section-1{
                let arrySets = madeSets[i].components(separatedBy: " ")
                expandableStr = arrySets[1] as String
            }
            if expandableStr == "Minutes" {
                sectionHeader.isExpanded = false
            }else{
                sectionHeader.isExpanded = true
            }
        }else if section == 0{
            let arrySets = madeSets[0].components(separatedBy: " ")
            expandableStr = arrySets[1] as String
            if expandableStr == "Minutes" {
                isAvailable = false
            }else{
                isAvailable = true
            }
        }
        sectionHeader.commentDelegate = self
        sectionHeader.lblExe.text = madeExercies[section]
        sectionHeader.lblSets.text = madeSets[section]
        sectionHeader.setItem(str: madeComments[section], isExpand:isAvailable)
        
        return sectionHeader
    }
    
    // MARK: - LUExpandableTableViewDelegate
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /// Returning `UITableViewAutomaticDimension` value on iOS 9 will cause reloading all cells due to an iOS 9 bug with automatic dimensions
        return 44
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForHeaderInSection section: Int) -> CGFloat {
        /// Returning `UITableViewAutomaticDimension` value on iOS 9 will cause reloading all cells due to an iOS 9 bug with automatic dimensions
        return 80
    }
    
    // MARK: - Optional
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, didSelectRowAt indexPath: IndexPath) {
        print("Did select cell at section \(indexPath.section) row \(indexPath.row)")
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
        currentCommentView.isHidden = false
        lblComments.text = comment
    }
   
}
