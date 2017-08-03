//
//  WorkoutTypeViewController.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/6/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class WorkoutTypeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate ,FloatRatingViewDelegate {

    var locationManager: CLLocationManager! = nil
    var timer:Timer?
    var count = 0;
    
    var parentNavigationController : UINavigationController?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var WorkoutsTypeTableView: UITableView!
    @IBOutlet weak var rateView: FloatRatingView!
    @IBOutlet weak var maskView: UIView!
    
//    var typeText: [String] = ["My Workouts", "Group Classes",
//                              "Personal Training","Strength Training","Cardiovascular Training"]
    var typeText: [String] = ["My ATC", "Meet Your Coach", "Group Classes", "Tribe Teams", "Cross Fit", "Free Workouts"]
//    var typeImages: [String] = ["my_workouts_image.png", "group_image.PNG", "gym_image.png", "strength_train_image.png", "cardio_image.png"]
    var typeImages: [String] = ["my_atc.png", "group_image.png", "trainer_image.png", "tribe_training", "crossfit_image.png", "strength_train_image.png"]
    
    //GYM LOCATION
    
    //cape coral
    let latCapeCoral:Double = 26.643316;
    let lonCapeCoral:Double = -81.998012;
    
    //sixMile
    let latSixMile:Double = 26.6060674;
    let lonSixMile:Double = -81.8108639;
    
    //boyscout
    let latBoyscout:Double = 26.5829549;
    let lonBoyScout:Double = -81.8808054;
    
    //alico
    let latAlico:Double = 26.4930431;
    let lonAlico:Double = -81.8517909;
    
    //port charlotte
    let latPortCh:Double = 27.0200136;
    let lonPortCh:Double = -82.1547218;
    
    //sarasota
    let latSarasota:Double = 27.3430287;
    let lonSarasota:Double = -82.5019098;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //WorkoutsTypeTableView.register .register(WorkoutsTypeCell(), forCellReuseIdentifier: "typeCell")
        WorkoutsTypeTableView.register(UINib.init(nibName: "WorkoutsTypeCell", bundle: nil), forCellReuseIdentifier: "typeCell")
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        
        let status:CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        
        if status == .denied{
            let alert = UIAlertController(title: "Enable Location", message: "You Locations Settings is set to 'Off'. Please Enable Location to get the most from this app", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Enable Location", style: .default, handler: { [weak alert] (_) in
                
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            // 4. Present the alert.
            self.present(alert, animated: true, completion: nil)
        }
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(self.updateLocation), userInfo: nil, repeats: true)
        
        // Required float rating view params
        self.rateView.emptyImage = UIImage.init(named: "StarEmpty")
        self.rateView.fullImage = UIImage.init(named: "StarFull")
        // Optional params
        self.rateView.delegate = self
        self.rateView.contentMode = UIViewContentMode.scaleAspectFit
        self.rateView.maxRating = 5
        self.rateView.minRating = 0
        self.rateView.rating = 0
        self.rateView.editable = true
        self.rateView.halfRatings = false
        self.rateView.floatRatings = false
        
        self.maskView.isHidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateLocation() {
        locationManager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        
        var wasUpdatedLocation = false
        if(appDelegate.currentUserLat == coord.latitude && appDelegate.currentUserLon == coord.longitude || abs(appDelegate.currentUserLat-coord.latitude) <= 0.01
            && abs(abs(appDelegate.currentUserLon) - abs(coord.longitude)) <= 0.01){
            
            wasUpdatedLocation = true;
        }
        
        if wasUpdatedLocation == false{
            appDelegate.currentUserLat = coord.latitude
            appDelegate.currentUserLon = coord.longitude
            print("updated location: \(appDelegate.currentUserLat), \(appDelegate.currentUserLon)")
            
            let mRootForPush: DatabaseReference = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com/")
            if self.checkAtGym() == true {
                print("Welcome")
                appDelegate.isLift = true
                appDelegate.saveLoginData()
                if appDelegate.currentGym != "" {
                    let gymRef = mRootForPush.child(appDelegate.currentGym)
                    var userInfoForPost = [String: Any]()
                    if(self.appDelegate.curUserProfileImageUrl != "" && self.appDelegate.curUserProfileImageUrl != nil){
                        userInfoForPost["profileUrl"] = self.appDelegate.curUserProfileImageUrl
                    }
                    userInfoForPost["username"] = self.appDelegate.userName
                    gymRef.child(self.appDelegate.userName).setValue(userInfoForPost)
                }
            }
            
            if self.checkAtGym() == false && appDelegate.isLift == true && count < 1{
                if appDelegate.currentGym != "" {
                    let gymRef = mRootForPush.child(appDelegate.currentGym)
                    gymRef.child(self.appDelegate.userName).removeValue()
                    appDelegate.isLift = false
                    appDelegate.saveLoginData()
                    
                    if(count < 1){
                        self.count += 1
                        self.rateWorkouts()

                    }
                }
            }
            locationManager.stopUpdatingLocation()

        }
    }
    
    func checkAtGym() -> Bool{
        var lifting = false
        //check if location is at gym or within 1 km
        if(appDelegate.currentUserLat == latCapeCoral && appDelegate.currentUserLon == lonCapeCoral || abs(appDelegate.currentUserLat-latCapeCoral) <= 0.009
            && abs(abs(appDelegate.currentUserLon) - abs(lonCapeCoral)) <= 0.009){
            lifting = true;
            updateGym(gym: "Cape Coral")
        }
        if(appDelegate.currentUserLat == latSixMile && appDelegate.currentUserLon == lonSixMile || abs(appDelegate.currentUserLat-latSixMile) <= 0.009
            && abs(abs(appDelegate.currentUserLon) - abs(lonSixMile)) <= 0.009){
            lifting = true;
             updateGym(gym: "Six Mile")
        }
        if(appDelegate.currentUserLat == latBoyscout && appDelegate.currentUserLon == lonBoyScout || abs(appDelegate.currentUserLat-latBoyscout) <= 0.009
            && abs(abs(appDelegate.currentUserLon) - abs(lonBoyScout)) <= 0.009){
            lifting = true;
            updateGym(gym: "Boyscout")
        }
        if(appDelegate.currentUserLat == latAlico && appDelegate.currentUserLon == lonAlico || abs(appDelegate.currentUserLat-latAlico) <= 0.009
            && abs(abs(appDelegate.currentUserLon) - abs(lonAlico)) <= 0.009){
            lifting = true;
             updateGym(gym: "Alico")
        }
        if(appDelegate.currentUserLat == latPortCh && appDelegate.currentUserLon == lonPortCh || abs(appDelegate.currentUserLat-latPortCh) <= 0.009
            && abs(abs(appDelegate.currentUserLon) - abs(lonPortCh)) <= 0.009){
            lifting = true;
             updateGym(gym: "Port Charlotte")
        }
        if(appDelegate.currentUserLat == latSarasota && appDelegate.currentUserLon == lonSarasota || abs(appDelegate.currentUserLat-latSarasota) <= 0.009
            && abs(abs(appDelegate.currentUserLon) - abs(lonSarasota)) <= 0.009){
            lifting = true;
            updateGym(gym: "Sarasota")
        }
        return lifting;
    }
    
    //update gym according to location
    func updateGym(gym: String){
        self.appDelegate.currentGym = gym
        
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
    
    func rateWorkouts(){
        let alert = UIAlertController(title: "Great job today!", message: "How was your workout?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { [weak alert] (_) in
            self.maskView.isHidden = false
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 6
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "typeCell", for: indexPath) as! WorkoutsTypeCell
        
        cell.typeLabel.text = typeText[indexPath.row]
        cell.typeImage.image = UIImage.init(named: typeImages[indexPath.row])
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(indexPath.row == 0){
            let vc = ShopChallengesMainViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }else if(indexPath.row == 1){
            let vc = TrainerWorkoutsViewController()
            appDelegate.workoutSelectedType = 3
            self.navigationController?.pushViewController(vc, animated: true)
            

        }else if(indexPath.row == 2){
            let vc = GroupClassesGoogleCalendarViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if(indexPath.row == 3){
            let vc = TribeViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if(indexPath.row == 4){
              let vc = CrossfitViewController()
              self.navigationController?.pushViewController(vc, animated: true)
            
        }else if(indexPath.row == 5){
            let vc = StrengthTrainWorkoutsViewController()
            appDelegate.workoutSelectedType = 1
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    func sendFeedback(){
        self.maskView.isHidden = true
        if self.rateView.rating < 5.0 {
            //1. Create the alert controller.
            let alert = UIAlertController(title: "Let us help", message: "How could we have improved your workout today?", preferredStyle: .alert)
            
            //2. Add the text field. You can configure it however you need.
            alert.addTextField { (textField) in
                textField.text = ""
            }
            
            // 3. Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "Send feedback", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0]
                
                //send to firebase
                let rootR = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com/")
                let rootFeedback = rootR.child("Feedback")
                var feedbackForPost = [String: Any]()
                feedbackForPost["first name"] = self.appDelegate.userFirstName
                feedbackForPost["last name"] = self.appDelegate.userLastName
                feedbackForPost["email"] = self.appDelegate.userEmail
                feedbackForPost["feedback"] = textField?.text!
                rootFeedback.childByAutoId().setValue(feedbackForPost)
                
                let alert = UIAlertController(title: "", message: "Thank you. We will do our best to improve our services for you.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
                
                
            }))
            
            // 4. Present the alert.
            self.present(alert, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "", message: "Thank you for your feedback!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: FloatRatingViewDelegate
    
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating:Float) {
        
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
        self.perform(#selector(self.sendFeedback), with: nil, afterDelay: 1.0)
    }
    
    
}
