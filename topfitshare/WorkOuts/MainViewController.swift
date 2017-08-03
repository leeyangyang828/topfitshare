//
//  MainViewController.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/7/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit
import DropDown
import FBSDKLoginKit
import Firebase

class MainViewController: UIViewController , PageContentViewDelegate, PageTitleViewDelegate{

    var pageTitleView:PageTitleView?
    var pageContentView:PageContentView?
    
    @IBOutlet weak var welcomeView: UIView!
    
    @IBOutlet weak var btnCheckWelcomeView: UIButton!
    
    
    @IBOutlet var navView: UIView!
//    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var menuBtn: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let menuDropDown = DropDown()
    let gymDropDwon = DropDown()
    lazy var dropDowns: [DropDown] = {
        return [
            self.menuDropDown,
            self.gymDropDwon
        ]
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navView.backgroundColor = UIColor(red: 39.0/255, green: 54.0/255, blue: 183.0/255, alpha: 1.0)
        
        customizeDropDown(self)
        gymDropDwon.anchorView = menuBtn
        gymDropDwon.bottomOffset = CGPoint(x: 0, y: menuBtn.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        gymDropDwon.dataSource = [
            "Alico",
            "Boyscout",
            "Cape Coral",
            "Port Charlotte",
            "Sarasota",
            "Six Mile"
        ]
        
        // Action triggered on selection
        gymDropDwon.selectionAction = { [unowned self] (index, item) in
            //update gym in appDelegate then Firebase
            self.appDelegate.currentGym = item
            
            self.appDelegate.saveLoginData()
            let rootR = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com/")
            var userInfoForPost = [String: Any]()
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
            
            if self.appDelegate.userName != "" {
                let rootRForRegister = rootR.child("user info").child(self.appDelegate.userName)
                rootRForRegister.setValue(userInfoForPost)
            }
        }

        
        
        // MARK: - Scroll menu setup
        
        // Initialize view controllers to display and place in array
        var controllerArray : [UIViewController] = []
        
        let controller1 : WorkoutTypeViewController = WorkoutTypeViewController(nibName: "WorkoutTypeViewController", bundle: nil)
        controller1.parentNavigationController = self.navigationController
        controllerArray.append(controller1)
        
//        let controller2 : ShopChallengesMainViewController = ShopChallengesMainViewController(nibName: "ShopChallengesMainViewController", bundle: nil)
//        controllerArray.append(controller2)
        
        let controller3 : MyProfileSettingViewController = MyProfileSettingViewController(nibName: "MyProfileSettingViewController", bundle: nil)
        controllerArray.append(controller3)
        
        let contentFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 464)
        pageContentView = PageContentView(frame: contentFrame, childVcs: controllerArray, parentViewController: self)
        pageContentView?.delegate = self
        
        let titleFrame = CGRect(x: 0, y: 464, width: UIScreen.main.bounds.width, height: 40)
        //let titles = ["gym_icon.png", "events.png", "home.png"]
        let titles = ["home.png",  "me.png"]
        
        pageTitleView = PageTitleView(frame: titleFrame, titles: titles, type: "image")
        pageTitleView?.delegate = self
        
        self.view.insertSubview(pageContentView!, belowSubview: welcomeView)
        self.view.insertSubview(pageTitleView!, belowSubview: welcomeView)
        
        customizeDropDown(self)
        
        menuDropDown.anchorView = menuBtn
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        menuDropDown.bottomOffset = CGPoint(x: -10, y: menuBtn.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        menuDropDown.dataSource = [
            "Logout",
            "Change Location"
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
           else if index == 1 {
                self.gymDropDwon.show()
            }
        }
        
        if appDelegate.isShownWelcome == true {
            welcomeView.isHidden = true
        }else {
            welcomeView.isHidden = false
        }
        
    }
    
    func customizeDropDown(_ sender: AnyObject) {
        DropDown.setupDefaultAppearance()
        
        dropDowns.forEach {
            $0.cellNib = UINib(nibName: "DropDownCell", bundle: Bundle(for: DropDownCell.self))
            $0.cellHeight = 35
            $0.customCellConfiguration = nil
        }
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
    
    // MARK:PageTitleViewDelegate协议
    func pageTitltView(_ titleView: PageTitleView, selectedIndex index: Int) {
        pageContentView?.setCurrentIndex(index)
//        switch index {
//        case 0:
//            self.lblTitle.text = "Find"
//        case 1:
//            self.lblTitle.text = "Gym"
//        case 2:
//            self.lblTitle.text = "Home"
//        default:
//            break
//        }
    }
    
    // MARK:PageContentViewDelegate
    func pageContentView(_ contentView: PageContentView, progress: CGFloat, sourceIndex: Int, targetIndex: Int)
    { 
        pageTitleView?.setTitleWithProgress(progress, sourceIndex: sourceIndex, targetIndex: targetIndex)
    }

    @IBAction func onMenu(_ sender: UIButton) {
        menuDropDown.show()
    }
    @IBAction func onNotification(_ sender: UIButton) {
        let vc = NotificationViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onBarCode(_ sender: UIButton) {
        let vc = BarcodeViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onCheckWelcomeView(_ sender: UIButton) {
        btnCheckWelcomeView.isSelected = !btnCheckWelcomeView.isSelected
        if btnCheckWelcomeView.isSelected == true {
            appDelegate.isShownWelcome = true
        }else {
            appDelegate.isShownWelcome = false
        }
        appDelegate.saveLoginData()
    }
    @IBAction func onWelcomeViewclose(_ sender: UIButton) {
        welcomeView.isHidden = true
    }
}
