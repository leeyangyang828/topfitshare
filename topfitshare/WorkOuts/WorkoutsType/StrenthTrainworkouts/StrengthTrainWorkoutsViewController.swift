//
//  StrengthTrainWorkoutsViewController.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/8/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit
import DropDown
import CoreData
import Firebase
import MBProgressHUD
import FBSDKLoginKit

class StrengthTrainWorkoutsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , UIGestureRecognizerDelegate, UISearchBarDelegate{
    
    @IBOutlet var navView: UIView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var btnSorting: UIButton!

    @IBOutlet weak var lblNoWorkouts: UILabel!
    
    @IBOutlet weak var StrengthWorkoutsTableView: UITableView!
    @IBOutlet weak var workoutsSearchBar: UISearchBar!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    let menuDropDown = DropDown()
    let sortDropDown = DropDown()
    lazy var dropDowns: [DropDown] = {
        return [
            self.menuDropDown,
            self.sortDropDown
        ]
    }()
    
    var strengthWorkouts:[DataSnapshot] = []
    
    var searchedWorkouts:[DataSnapshot] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem .setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navView.backgroundColor = UIColor(red: 39.0/255, green: 54.0/255, blue: 183.0/255, alpha: 1.0)        
        customizeDropDown(self)
        menuDropDown.anchorView = btnMenu
        sortDropDown.anchorView = btnSorting
        menuDropDown.bottomOffset = CGPoint(x: -10, y: btnMenu.bounds.height)
        sortDropDown.bottomOffset = CGPoint(x: -10, y: btnSorting.bounds.height)
        
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
        
        sortDropDown.dataSource = [
            "New Workouts",
            "Popular"
        ]
        
        // Action triggered on selection
        sortDropDown.selectionAction = { [unowned self] (index, item) in
            self.btnSorting.setTitle(item, for: .normal)
            switch index {
            case 0:
                //let sortedarray = self.searchedWorkouts.sort
                
                self.searchedWorkouts.sort {
                    item1, item2 in
                    let oneDic = item1.value as! NSDictionary
                    let twoDic = item2.value as! NSDictionary
                    let date1 = oneDic["likes"] as! Int
                    let date2 = twoDic["likes"] as! Int
                    return date1 < date2
                }
                self.StrengthWorkoutsTableView.reloadData()
                break
            case 1:
                self.searchedWorkouts.sort {
                    item1, item2 in
                    let oneDic = item1.value as! NSDictionary
                    let twoDic = item2.value as! NSDictionary
                    let date1 = oneDic["likes"] as! Int
                    let date2 = twoDic["likes"] as! Int
                    return date1 > date2
                }
                self.StrengthWorkoutsTableView.reloadData()
                break
            default:
                break
            }
        }
        
        StrengthWorkoutsTableView.register(UINib.init(nibName: "WorkoutsOfUsersCell", bundle: nil), forCellReuseIdentifier: "WorkoutsOfUsersItem")
        
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        longPressGesture.delegate = self
        StrengthWorkoutsTableView.addGestureRecognizer(longPressGesture)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.addSubview(navView)
        self.getFilteredWorkouts()
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
    
    func getFilteredWorkouts(){
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        
        let rootR = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com/workouts")
        
        rootR.queryOrderedByKey().observe(DataEventType.value, with: {snapchat in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            self.appDelegate.availWorkouts.removeAll()
            self.strengthWorkouts.removeAll()
            self.searchedWorkouts.removeAll()
            
            for data in snapchat.children{
                let child = data as! DataSnapshot
                let dic = child.value as! NSDictionary
                self.appDelegate.availWorkouts.append(dic)
                
                if self.appDelegate.workoutSelectedType == 1{
                    if dic["goal"] as! String == "Strength Training"{
                        self.strengthWorkouts.append(child)
                    }
                }else if self.appDelegate.workoutSelectedType == 2 {
                    if dic["goal"] as! String == "Cardio Training"{
                        self.strengthWorkouts.append(child)
                    }
                }
            }
            
            self.searchedWorkouts = self.strengthWorkouts
            
            if self.strengthWorkouts.count == 0{
                self.StrengthWorkoutsTableView.isHidden = true
            }
            self.searchedWorkouts.sort {
                item1, item2 in
                let oneDic = item1.value as! NSDictionary
                let twoDic = item2.value as! NSDictionary
                let date1 = oneDic["likes"] as! Int
                let date2 = twoDic["likes"] as! Int
                return date1 < date2
            }
            self.StrengthWorkoutsTableView.reloadData()
        })
        
    }
    
    @IBAction func onMenu(_ sender: UIButton) {
        menuDropDown.show()
    }
    @IBAction func onSort(_ sender: UIButton) {
        sortDropDown.show()
    }
    @IBAction func onBack(_ sender: UIButton) {
        self.view.endEditing(true);
        appDelegate.goToMainContact()
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
        return searchedWorkouts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutsOfUsersItem", for: indexPath) as! WorkoutsOfUsersCell
        
        let data = searchedWorkouts[indexPath.row] 
        let workout = data.value as! NSDictionary
        
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let data = searchedWorkouts[indexPath.row]
        let workout = data.value as! NSDictionary
        let vc = WorkOutsPreViewController()
        vc.mine = false
        vc.infoSelectedWorkOuts = workout as! [String : Any]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func handleLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let indexPath = StrengthWorkoutsTableView.indexPathForRow(at: touchPoint) {
                //1. Create the alert controller.
                let alert = UIAlertController(title: "Are you sure?", message: "Remove this workout from the share feed?", preferredStyle: .alert)
                
                // 3. Grab the value from the text field, and print it when the user clicks OK.
                alert.addAction(UIAlertAction(title: "NO", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { [weak alert] (_) in
                    let data = self.searchedWorkouts[indexPath.row]
                    let workout = data.value as! NSDictionary
                    if workout["username"] as? String == self.appDelegate.userName {
                        self.searchedWorkouts.remove(at: indexPath.row)
                        let rootR = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com/workouts")
                        rootR.child(data.key).removeValue()
                        self.StrengthWorkoutsTableView.reloadData()
                    }else{
                        
                        let alert = UIAlertController(title: "ATC Fitness", message: "Cannot remove other peeple's workouts.", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    
                }))
                
                // 4. Present the alert.
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        workoutsSearchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        searchedWorkouts.removeAll()
        searchedWorkouts = strengthWorkouts
        
        StrengthWorkoutsTableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        workoutsSearchBar.resignFirstResponder()
        if searchBar.text?.characters.count != 0 {
            searchedWorkouts.removeAll()
            for index in 0...strengthWorkouts.count - 1 {
                let data = strengthWorkouts[index]
                let one = data.value as! NSDictionary
                let workout = one["workout"] as! String
                if (workout.lowercased() as NSString).range(of: (searchBar.text?.lowercased())!).location != NSNotFound {
                    searchedWorkouts.append(data)
                }
            }
        }else {
            searchedWorkouts.removeAll()
            searchedWorkouts = strengthWorkouts
        }
        
        StrengthWorkoutsTableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.characters.count != 0 {
            searchedWorkouts.removeAll()
            for index in 0...strengthWorkouts.count - 1 {
                let data = strengthWorkouts[index]
                let one = data.value as! NSDictionary
                let workout = one["workout"] as! String
                if (workout.lowercased() as NSString).range(of: (searchBar.text?.lowercased())!).location != NSNotFound {
                    searchedWorkouts.append(data)
                }
            }
        }else {
            searchedWorkouts.removeAll()
            searchedWorkouts = strengthWorkouts
        }
        
        StrengthWorkoutsTableView.reloadData()
    }
    @IBAction func onAddWorkouts(_ sender: Any) {
        
        let vc = CreateWorkoutsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
