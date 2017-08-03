//
//  SelectGYMViewController.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/5/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit
import Firebase

class SelectGYMViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var gymSearchBar: UISearchBar!
    @IBOutlet weak var gymTableView: UITableView!
    @IBOutlet var navView: UIView!
    
    var lstGym:[String] = []
    var searchedGyms:[String] = []
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lstGym = ["Gym not listed(can change later)","ATC Fitness Cape Coral Club","ATC Fitness Boyscout Club","ATC Fitness Six Mile Club","ATC Fitness Alico Club","ATC Fitness Port Charlotte Club","FGCU Fitness Center"];
        searchedGyms = lstGym
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar .addSubview(navView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navView.removeFromSuperview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (searchedGyms.count)
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let sortTableviewIdentifier = "GymTableItem"
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: sortTableviewIdentifier) as UITableViewCell!
        
        cell.textLabel?.text = searchedGyms[indexPath.row]
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        appDelegate.currentGym = searchedGyms[indexPath.row]
        let rootR = Database.database().reference(fromURL: "https://fitnectapp.firebaseio.com/") 
        let userInfoForPost = NSMutableDictionary.init()
        userInfoForPost .setValue(appDelegate.userEmail, forKey: "email")
        userInfoForPost .setValue(appDelegate.userFirstName, forKey: "firstName")
        userInfoForPost .setValue(appDelegate.userLastName, forKey: "lastName")
        userInfoForPost .setValue(appDelegate.userName, forKey: "username")
        userInfoForPost .setValue(appDelegate.curUserProfileImageUrl, forKey: "profileUrl")
        userInfoForPost .setValue(appDelegate.pointsNumber, forKey: "sharedNumber")
        userInfoForPost .setValue(appDelegate.currentGym, forKey: "gym")
        userInfoForPost .setValue(appDelegate.aboutMe, forKey: "aboutMe")
        
        if appDelegate.userName != "" {
            let rootRForRegister = rootR.child("user info").child(appDelegate.userName) 
            rootRForRegister.setValue(userInfoForPost)
        }
        appDelegate.goToMainContact()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        gymSearchBar.resignFirstResponder()
        if searchBar.text?.characters.count != 0 {
            searchedGyms.removeAll()
            for gyms in lstGym {
                if (gyms.lowercased() as NSString).range(of: (searchBar.text?.lowercased())!).location != NSNotFound {
                    searchedGyms.append(gyms)
                }
            }
        }else {
            searchedGyms.removeAll()
            searchedGyms = lstGym
        }
        
        gymTableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.characters.count != 0 {
            searchedGyms.removeAll()
            for gyms in lstGym {
                if (gyms.lowercased() as NSString).range(of: (searchBar.text?.lowercased())!).location != NSNotFound {
                    searchedGyms.append(gyms)
                }
            }
        }else {
            searchedGyms.removeAll()
            searchedGyms = lstGym
        }
    }
    
    @IBAction func onGYMMenuClick(_ sender: Any) {
        self.view.endEditing(true)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let settingAction = UIAlertAction(title: "Setting", style:UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        optionMenu.addAction(settingAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }

}
