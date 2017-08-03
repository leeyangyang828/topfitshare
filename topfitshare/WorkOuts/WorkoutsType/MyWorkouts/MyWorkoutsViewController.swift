//
//  MyWorkoutsViewController.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/8/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit
import DropDown
import CoreData
import FBSDKLoginKit

class MyWorkoutsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , UIGestureRecognizerDelegate{

    @IBOutlet var navView: UIView!
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var emptyLblWorkouts: UILabel!
    @IBOutlet weak var MyWorkoutsTableview: UITableView!
    
    var arrayWorkouts:[Any] = []
    
    
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
        menuDropDown.anchorView = menuBtn
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
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
        
        MyWorkoutsTableview.register(UINib.init(nibName: "OwnWorkoutCell", bundle: nil), forCellReuseIdentifier: "OwnWorkoutItem")
        
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        longPressGesture.delegate = self
        MyWorkoutsTableview.addGestureRecognizer(longPressGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.addSubview(navView)
        
        self.getWorkouts()
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
    
    func getWorkouts(){
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Workouts")
        request.predicate = NSPredicate(format: "userId == %@", appDelegate.sessionID)
        do {
            arrayWorkouts.removeAll()
            let fetchedObjects = try context.fetch(request) as! [Workouts]
            for workouts in fetchedObjects{
                var oneWorkouts = [String: Any]()
                oneWorkouts["title"] = workouts.title
                let jsonString = workouts.data
                let data = jsonString?.data(using: .utf8)!
                let json = try? JSONSerialization.jsonObject(with: data!)
                oneWorkouts["data"] = json
                oneWorkouts["typeWorkouts"] = workouts.typeWorkouts
                
                arrayWorkouts.append(oneWorkouts)
            }
            
            if arrayWorkouts.count == 0 {
                emptyLblWorkouts.isHidden = false
                MyWorkoutsTableview.isHidden = true
            }else{
                emptyLblWorkouts.isHidden = true
                MyWorkoutsTableview.isHidden = false
            }
            
            MyWorkoutsTableview.delegate = self
            MyWorkoutsTableview.dataSource = self
            MyWorkoutsTableview.reloadData()
            
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }
    
    @IBAction func onMenu(_ sender: UIButton) {
        menuDropDown.show()
    }

    @IBAction func onBack(_ sender: UIButton) {
        appDelegate.goToMainContact()
    }
    @IBAction func onAddWorkouts(_ sender: UIButton) {
        let vc = CreateWorkoutsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrayWorkouts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OwnWorkoutItem", for: indexPath) as! OwnWorkoutCell
        var oneWork = [String: Any]()
        oneWork = arrayWorkouts[indexPath.row] as! [String : Any]
        cell.workoutsName.text = oneWork["title"] as? String
        
        var data = [String: Any]()
        data = oneWork["data"] as! [String : Any]
        if data["workoutImageUrl"] as? String != nil {
            if (data["workoutImageUrl"] as! NSString).range(of: "http").location != NSNotFound {
                let url = URL(string: data["workoutImageUrl"] as! String)
                cell.workoutsImage.setImageWithUrl(url!)
            }
            else {
                cell.workoutsImage.image = UIImage(named: "workout_logo.png")
            }
        }
        else {
            cell.workoutsImage.image = UIImage(named: "workout_logo.png")
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var oneWork = [String: Any]()
        oneWork = arrayWorkouts[indexPath.row] as! [String : Any]
        
        let currentworkoutInfo = oneWork["data"] as! [String : Any]
        
        var userInfoForShared = [String: Any]()
        
        var strComment = ""
        let arryComment:[String] = currentworkoutInfo["comment"] as! [String]
        for i in 0...arryComment.count - 1{
            let one = arryComment[i]
            if i == 0{
                strComment = "[\(one)"
            }else if i == arryComment.count - 1{
                strComment = "\(strComment), \(one)]"
            }else {
                strComment = "\(strComment), \(one)"
            }
            if arryComment.count == 1{
                strComment = "\(strComment)]"
            }
        }
        userInfoForShared["comment"] = strComment
        
        var strSets = ""
        let arrySets:[String] = currentworkoutInfo["sets"] as! [String]
        for i in 0...arrySets.count - 1{
            let one = arrySets[i]
            if i == 0{
                strSets = "[\(one)"
            }else if i == arrySets.count - 1{
                strSets = "\(strSets), \(one)]"
            }else {
                strSets = "\(strSets), \(one)"
            }
            if arrySets.count == 1{
                strSets = "\(strSets)]"
            }
        }
        userInfoForShared["sets"] = strSets
        
        var strExercise = ""
        let arryExercise:[String] = currentworkoutInfo["exercise"] as! [String]
        for i in 0...arryExercise.count - 1{
            let one = arryExercise[i]
            if i == 0{
                strExercise = "[\(one)"
            }else if i == arryExercise.count - 1{
                strExercise = "\(strExercise), \(one)]"
            }else {
                strExercise = "\(strExercise), \(one)"
            }
            if arryExercise.count == 1{
                strExercise = "\(strExercise)]"
            }
        }
        userInfoForShared["exercise"] = strExercise
        
        var strReps = ""
        let arryReps:[String] = currentworkoutInfo["reps"] as! [String]
        for i in 0...arryReps.count - 1{
            let one = arryReps[i]
            if i == 0{
                strReps = "[\(one)"
            }else if i == arryReps.count - 1{
                strReps = "\(strReps), \(one)]"
            }else {
                strReps = "\(strReps), \(one)"
            }
            if arryReps.count == 1{
                strReps = "\(strExercise)]"
            }
        }
        userInfoForShared["reps"] = strReps
        
        userInfoForShared["likes"] = 0
        userInfoForShared["username"] = self.appDelegate.userName
        userInfoForShared["goal"] = currentworkoutInfo["goal"]
        if currentworkoutInfo["workoutImageUrl"] != nil && currentworkoutInfo["workoutImageUrl"] as! String != "" {
            userInfoForShared["image"] = currentworkoutInfo["workoutImageUrl"]
        }
        userInfoForShared["workout"] = currentworkoutInfo["workoutname"]
        
        
        let vc = WorkOutsPreViewController()
        vc.infoSelectedWorkOuts = userInfoForShared
        vc.mine = true
        self.navigationController?.pushViewController(vc, animated: true)
        
        if (oneWork["typeWorkouts"] as! Bool == true) {
            
        }else{
        
        }
    }
    
    func handleLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let indexPath = MyWorkoutsTableview.indexPathForRow(at: touchPoint) {
                //1. Create the alert controller.
                let alert = UIAlertController(title: "Are you sure?", message: "Delete this workout?", preferredStyle: .alert)
                
                // 3. Grab the value from the text field, and print it when the user clicks OK.
                alert.addAction(UIAlertAction(title: "NO", style: .default, handler: { [weak alert] (_) in
                }))
                alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { [weak alert] (_) in
                    
                    let context = self.appDelegate.persistentContainer.viewContext
                    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Workouts")
                    request.predicate = NSPredicate(format: "userId == %@", self.appDelegate.sessionID)
                    do {
                        let fetchedObjects = try context.fetch(request) as! [Workouts]
                        for workouts in fetchedObjects{
                            context.delete(workouts)
                        }
                        try context.save()
                        
                        self.arrayWorkouts.remove(at: indexPath.row)
                        
                        for index in 0...self.arrayWorkouts.count
                        {
                            var dic  = [String: Any]()
                            dic = self.arrayWorkouts[index] as! [String : Any]
                            
                            let workoutsNew = NSEntityDescription.insertNewObject(forEntityName: "Workouts", into: context)
                            workoutsNew.setValue(dic["title"], forKey: "title")
                            workoutsNew.setValue(dic["typeWorkouts"], forKey: "typeWorkouts")
                            workoutsNew.setValue(self.appDelegate.sessionID, forKey: "userId")
                            workoutsNew.setValue(self.appDelegate.jsonToString(json: dic["data"] as AnyObject), forKey: "data")
                            
                            try context.save()
                        }
                        
                        
                        
                        if self.arrayWorkouts.count == 0 {
                            self.emptyLblWorkouts.isHidden = false
                            self.MyWorkoutsTableview.isHidden = true
                        }else{
                            self.emptyLblWorkouts.isHidden = true
                            self.MyWorkoutsTableview.isHidden = false
                        }
                        self.MyWorkoutsTableview.reloadData()
                        
                    } catch {
                        fatalError("Failed to fetch employees: \(error)")
                    }
                    
                }))
                
                // 4. Present the alert.
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
