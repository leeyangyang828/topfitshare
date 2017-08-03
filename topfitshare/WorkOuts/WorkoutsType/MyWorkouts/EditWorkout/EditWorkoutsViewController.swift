//
//  EditWorkoutsViewController.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/9/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit
import DropDown
import CoreData
import Firebase

class EditWorkoutsViewController: UIViewController, UITextFieldDelegate, RepsAndCommentViewControllerDelegate , SelectExerciseViewControllerDelegate, LUExpandableTableViewDataSource, LUExpandableTableViewDelegate, MyExpandableTableViewSectionHeaderDelegate, UITableViewDelegate, UITableViewDataSource{

    var workoutsImageUrl:String?
    var workoutName:String?
    var arrAddWorkouts:[String: Any]?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var txtExercise: UITextField!
    @IBOutlet weak var txtSets: UITextField!
    @IBOutlet weak var workoutImage: UIImageView!
    
    @IBOutlet var navView: UIView!
    @IBOutlet weak var lblworkoutsName: UILabel!
    @IBOutlet weak var lblWorkoutsNameMain: UILabel!
    
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var commentPreView: UIView!
    @IBOutlet weak var lblSelectedComment: UILabel!
    @IBOutlet weak var selectedRepsSets: UISwitch!
    
    @IBOutlet weak var AddOfcurrentUserTableView: LUExpandableTableView!
    
    @IBOutlet weak var btnMenu: UIButton!
    
    @IBOutlet weak var ExerciseTableView: UITableView!
    @IBOutlet weak var tblMaskView: UIView!
    
    let menuDropDown = DropDown()
    lazy var dropDowns: [DropDown] = {
        return [
            self.menuDropDown
        ]
    }()
    
    var madeExercies:[String] = []
    var madeSets:[String] = []
    var madeComments:[String] = []
    var madeReps:[String] = []
    
    var arrAllWorkoutsForcurrentUser:[String:Any]?
    
    var isTapComments = false
    var isSavedOnLocal = false
    var test = false
    var isShared = false
    
    var currentSetCount = 0
    var searchHelpExercies:[String] = []
    var exerciesArray:[String] = ["Abs",
                                  "Back",
                                  "Biceps",
                                  "Cardio",
                                  "Chest",
                                  "Legs",
                                  "Shoulders",
                                  "Triceps"]
    
    
    fileprivate let sectionHeaderReuseIdentifier = "MySectionHeader"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem .setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navView.backgroundColor = UIColor(red: 39.0/255, green: 54.0/255, blue: 183.0/255, alpha: 1.0) //fitshare blue
        
        lblworkoutsName.text = workoutName
        lblWorkoutsNameMain.text = workoutName

        workoutImage.setImageWith(NSURL(string: workoutsImageUrl!)! as URL)
        
        workoutImage.contentMode = .scaleAspectFill
        workoutImage.clipsToBounds = true
        workoutImage.layer.cornerRadius = workoutImage.frame.size.width/2
        
        customizeDropDown(self)
        menuDropDown.anchorView = btnMenu
        menuDropDown.bottomOffset = CGPoint(x: -10, y: btnMenu.bounds.height)
        //execriesDropDown.bottomOffset = CGPoint(x: 0, y: txtExercise.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        menuDropDown.dataSource = [
            "Logout"
        ]
        
        // Action triggered on selection
        menuDropDown.selectionAction = { [unowned self] (index, item) in
            //self.alcButton.setTitle(item, for: .normal)
            if index == 0 {
                self.appDelegate.deleteLoginData()
                self.appDelegate.goToSplash()
            }
        }
        
        //init
        commentPreView.isHidden = true
  
        //AddOfcurrentUserTableView.register(RepsEditCell.self, forCellReuseIdentifier: "RepsEditItem")
        AddOfcurrentUserTableView.register(UINib.init(nibName: "RepsEditCell", bundle: nil), forCellReuseIdentifier: "RepsEditItem")
        AddOfcurrentUserTableView.register(UINib(nibName: "MyExpandableTableViewSectionHeader", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: sectionHeaderReuseIdentifier)
        
        AddOfcurrentUserTableView.expandableTableViewDelegate = self
        AddOfcurrentUserTableView.expandableTableViewDataSource = self
        
        tblMaskView.layer.shadowColor = UIColor.black.cgColor
        tblMaskView.layer.shadowOffset = CGSize.init(width: 0, height: 1)
        tblMaskView.layer.shadowOpacity = 0.7
        tblMaskView.layer.shadowRadius = 5.0
        tblMaskView.clipsToBounds = false
        tblMaskView.layer.masksToBounds = false
        
        searchHelpExercies = exerciesArray
        tblMaskView.isHidden = true
        ExerciseTableView.isHidden = true
        ExerciseTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ExerciesItem")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.addSubview(navView)
        
        if appDelegate.isSelectedCar == true {
            lblType.text = "How many minutes?"
            selectedRepsSets .setOn(true, animated: false)
        }else{
            lblType.text = "How many sets?"
            selectedRepsSets.setOn(false, animated: false)
        }
        
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
    
    @IBAction func onBack(_ sender: UIButton) {
        self.view.endEditing(true);
        //back up save in case user forgets
        self.saveWorkout()
        appDelegate.goToMyWorkouts()
    }
    
    func stingToArrayForWorkout(str:String) -> [String] {
        var arrItems:[String] = []
        let strReplacedWithChar = str.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        arrItems = strReplacedWithChar.components(separatedBy: ", ")
        return arrItems
    }
    
    
//    ////************ WORKOUT SAVE*******////
//    @IBAction func onSaveClick(_ sender: UIButton) {
//        self.view.endEditing(true)
//        if(madeExercies.count > 0){
//            saveWorkout()
//
//            //1. Create the alert controller.
//            let alert = UIAlertController(title: "Success!", message: "Workouts saved!", preferredStyle: .alert)
//            // 3. Grab the value from the text field, and print it when the user clicks OK.
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
//                
//                self.appDelegate.goToMyWorkouts()
//                
//            }))
//            // 4. Present the alert.
//            self.present(alert, animated: true, completion: nil)
//        }else{
//            self.showAlert(msg: "Add at least one exercise before saving", titleStr: "Save workout error", delegate: self)
//            return
//        }
//        
//
//    }
    
    func saveWorkout(){
        arrAllWorkoutsForcurrentUser = [
            "exercise":madeExercies,
            "sets":madeSets,
            "comment":madeComments,
            "reps":madeReps,
            "workoutname":workoutName ?? "",
            "workoutImageUrl":workoutsImageUrl ?? ""
        ]
        
        let context = self.appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Workouts")
        request.predicate = NSPredicate(format: "userId == %@", self.appDelegate.sessionID)
        do {
            //            let fetchedObjects = try context.fetch(request) as! [Workouts]
            //            for workouts in fetchedObjects{
            //                context.delete(workouts)
            //            }
            //            try context.save()
            
            let workoutsNew = NSEntityDescription.insertNewObject(forEntityName: "Workouts", into: context)
            workoutsNew.setValue(workoutName, forKey: "title")
            workoutsNew.setValue(true, forKey: "typeWorkouts")
            workoutsNew.setValue(self.appDelegate.sessionID, forKey: "userId")
            workoutsNew.setValue(appDelegate.jsonToString(json: arrAllWorkoutsForcurrentUser as AnyObject), forKey: "data")
            
            try context.save()
            
            isSavedOnLocal = true
            madeExercies.removeAll()
            madeSets.removeAll()
            madeComments.removeAll()
            madeReps.removeAll()
            txtExercise.text = ""
            txtSets.text = ""
            
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }
    
    
    ////************ WORKOUT SHARE*******////
    @IBAction func onLinkClick(_ sender: UIButton) {
        self.view.endEditing(true);
        if(madeExercies.count > 0){
            if isSavedOnLocal == false {
                saveWorkout()
                isSavedOnLocal = true
            }
            isShared = false
            
            //1. Create the alert controller.
            let alert = UIAlertController(title: "Share now", message: "Would you like to share this workout?", preferredStyle: .alert)
            // 3. Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { [weak alert] (_) in
                
                let rootR = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com/")
                let rootRForHaveingSharedNum = rootR.child("user info")
                
                if self.appDelegate.userName != "" {
                    let rootRForAdding = rootRForHaveingSharedNum.child(self.appDelegate.userName)
                    
                    var userInfoForPost = [String: Any]()
                    
                    //add points for sharing to be discussed
                    //                var num = self.appDelegate.pointsNumber
                    //                num = num + 1
                    //                self.appDelegate.pointsNumber = num
                    //                self.appDelegate.saveLoginData()
                    
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
                
                var strComment = ""
                let arryComment:[String] = self.arrAllWorkoutsForcurrentUser?["comment"] as! [String]
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
                let arrySets:[String] = self.arrAllWorkoutsForcurrentUser?["sets"] as! [String]
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
                let arryExercise:[String] = self.arrAllWorkoutsForcurrentUser?["exercise"] as! [String]
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
                let arryReps:[String] = self.arrAllWorkoutsForcurrentUser?["reps"] as! [String]
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
                if self.workoutsImageUrl != nil && self.workoutsImageUrl != "" {
                    userInfoForShared["image"] = self.workoutsImageUrl
                }
                userInfoForShared["workout"] = self.workoutName
                
                let postRef = rootRForSharedWorkouts.childByAutoId()
                postRef.setValue(userInfoForShared)
                
            
                self.isShared = true
                self.appDelegate.workoutSelectedType = 1
                let vc = StrengthTrainWorkoutsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            
            }))
            alert.addAction(UIAlertAction(title: "NO", style: .default, handler: { [weak alert] (_) in
                
            }))
            
            // 4. Present the alert.
            self.present(alert, animated: true, completion: nil)
        }
        else{
            self.showAlert(msg: "Add at least one exercise before saving", titleStr: "Save workout error", delegate: self)
            return
        }
    }
    
    
    @IBAction func onMenu(_ sender: UIButton) {
        self.view.endEditing(true);
        menuDropDown.show()
    }
    
    @IBAction func onSelectedRepsSets(_ sender: UISwitch) {
        self.view.endEditing(true);
        selectedRepsSets.isSelected = !selectedRepsSets.isSelected
        if selectedRepsSets.isSelected == true {
            lblType.text = "How many minutes?"
            appDelegate.isSelectedCar = true
        }else{
            lblType.text = "How many sets?"
            appDelegate.isSelectedCar = false
        }
    }
    
    @IBAction func onAdd(_ sender: UIButton) {
        self.view.endEditing(true);
        if txtExercise.text?.characters.count == 0 || txtSets.text?.characters.count == 0{
            self.showAlert(msg: "Fill in all spaces before adding to list!", titleStr: "Input Error", delegate: self)
            return
        }
        
        let vc = RepsAndCommentViewController()
        madeExercies.append(txtExercise.text!)
        
        if appDelegate.isSelectedCar == true || selectedRepsSets.isSelected == true {
            madeSets.append("\(txtSets.text ?? "") Minutes")
            vc.cardio = true
            for _:Int in 1...Int(txtSets.text!)!{
               madeReps.append("Cardio")
            }
        }else{
            madeSets.append("\(txtSets.text ?? "") Sets")
        }
        
        vc.workoutName = workoutName
        vc.sets = txtSets.text
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onCommentPreviewClose(_ sender: UIButton) {
        self.view.endEditing(true);
        commentPreView.isHidden = true
    }
    
    func showAlert(msg:String, titleStr:String, delegate:Any){
        let alert = UIAlertController(title: titleStr, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        if textField == txtExercise {
            textField.keyboardType = .default
        }else if textField == txtSets{
            textField.keyboardType = .numberPad
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtExercise {
            if textField.text?.characters.count != 0 {
                searchHelpExercies.removeAll()
                for index in 0...exerciesArray.count - 1 {
                    let one = exerciesArray[index]
                    if (one.lowercased() as NSString).range(of: (textField.text?.lowercased())!).location != NSNotFound {
                        searchHelpExercies.append(one)
                    }
                }
            }
            if searchHelpExercies.count == 0 {
                tblMaskView.isHidden = true
                ExerciseTableView.isHidden = true
            }else{
                tblMaskView.isHidden = false
                ExerciseTableView.isHidden = false
                self.updateTableViewAndViewPostion()
            }
            
            ExerciseTableView.reloadData()
            textField.keyboardType = .default
        }else{
            textField.keyboardType = .numberPad
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let checkStr = "\(textField.text ?? "")\(string)"
        if checkStr.characters.count == 1 && string.characters.count == 0{
            searchHelpExercies.removeAll()
            searchHelpExercies = exerciesArray
        }else if checkStr.characters.count != 0{
            searchHelpExercies.removeAll()
            for index in 0...exerciesArray.count - 1 {
                let one = exerciesArray[index]
                if (one.lowercased() as NSString).range(of: (checkStr.lowercased())).location != NSNotFound {
                    searchHelpExercies.append(one)
                }
            }
        }else {
            searchHelpExercies.removeAll()
            searchHelpExercies = exerciesArray
        }
        
        if searchHelpExercies.count == 0 {
            tblMaskView.isHidden = true
            ExerciseTableView.isHidden = true
        }else{
            tblMaskView.isHidden = false
            ExerciseTableView.isHidden = false
            self.updateTableViewAndViewPostion()
        }
        
        ExerciseTableView.reloadData()
        
        return true
    }
    func updateTableViewAndViewPostion(){
        ExerciseTableView.frame = CGRect.init(x: ExerciseTableView.frame.origin.x, y: ExerciseTableView.frame.origin.y, width: ExerciseTableView.frame.size.width, height: CGFloat(searchHelpExercies.count * 30))
        if searchHelpExercies.count > 5 {
            ExerciseTableView.frame = CGRect.init(x: ExerciseTableView.frame.origin.x, y: ExerciseTableView.frame.origin.y, width: ExerciseTableView.frame.size.width, height: 150)
        }
        
        tblMaskView.frame = ExerciseTableView.frame
    }
    //RepsandcommentViewControllerDelegate
    func gotRepsAndComment(reps: [String], comment: String) {
        for index in 0...reps.count-1{
            madeReps.append(reps[index])
        }
        madeComments.append(comment)
        
        AddOfcurrentUserTableView.reloadData()
        
        txtExercise.text = ""
        txtSets.text = ""
    }
    
    //SelectExerciesViewcontrollerDelegate
    func gotExerciesFromHelp(name : String){
        txtExercise.text = name
    }
    
    
    // MARK: - LUExpandableTableViewDataSource
    internal func numberOfSections(in expandableTableView: LUExpandableTableView) -> Int {
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
        var isAvable = true
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
                isAvable = false
            }else{
                isAvable = true
            }
        }
        sectionHeader.commentDelegate = self
        sectionHeader.lblExe.text = madeExercies[section]
        sectionHeader.lblSets.text = madeSets[section]
        sectionHeader.setItem(str: madeComments[section], isExpand: isAvable)
        
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
        commentPreView.isHidden = false
        lblSelectedComment.text = comment
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHelpExercies.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "ExerciesItem") as UITableViewCell!
        // set the text from the data model
        let exericese = searchHelpExercies[indexPath.row]
        cell.textLabel?.text = exericese
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        ExerciseTableView.isHidden = true
        tblMaskView.isHidden = true
        let vc = SelectExerciseViewController()
        vc.indexSelectedExercies = indexPath.row
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
}
