//
//  GroupClassesGoogleCalendarViewController.swift
//  topfitshare
//
//  Created by stepanekdavid on 5/14/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit
import DropDown
import GoogleAPIClient
import GTMOAuth2
import FBSDKLoginKit
import GoogleSignIn
import CalendarKit
import DateToolsSwift
import MBProgressHUD

class GroupClassesGoogleCalendarViewController: UIViewController{

    @IBOutlet var navView: UIView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var locationBtn: UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var calID = "atccapecoral@gmail.com"
    
    let menuDropDown = DropDown()
    let locationDropDown = DropDown()
    lazy var dropDowns: [DropDown] = {
        return [
            self.menuDropDown,
            self.locationDropDown
        ]
    }()

    fileprivate let kKeychainItemName = "Google Calendar API"
    
    // Obtain Client ID from https://console.developers.google.com/start/api?id=calendar
    // Replace ClientID Below:
    fileprivate let kClientID = "657228808711-irf22kvh9e42ehj5q2objbg14pls35gd.apps.googleusercontent.com"
    //fileprivate let kClientID = "1l250v2badqv0r971n5fqtoq70@group.calendar.google.com"
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    fileprivate let scopes = [kGTLAuthScopeCalendarReadonly]
    
    fileprivate let service = GTLServiceCalendar()
    
    //calendarkit
    @IBOutlet weak var GroupCalendarView: DayView!
    var arryInfoOfCalendar:[[String:Any]] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem .setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navView.backgroundColor = UIColor(red: 39.0/255, green: 54.0/255, blue: 183.0/255, alpha: 1.0)
        customizeDropDown(self)
        
        menuDropDown.anchorView = menuBtn
        locationDropDown.anchorView = locationBtn
        
        if(appDelegate.currentGym != ""){
           self.setCalID(id: appDelegate.currentGym)
        }
        
        
        //calendarkit
        GroupCalendarView.delegate = self
        GroupCalendarView.dataSource = self
        GroupCalendarView.fillSuperview()
        var style: CalendarStyle!
        style = StyleGenerator.defaultStyle()
        GroupCalendarView.updateStyle(style)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().clientID = kClientID
        GIDSignIn.sharedInstance().scopes = scopes
        
        
        if GIDSignIn.sharedInstance().currentUser == nil {
            GIDSignIn.sharedInstance().signIn()
        } else {
            if let user = GIDSignIn.sharedInstance().currentUser {
                service.authorizer = user.authentication.fetcherAuthorizer()
                fetchEvents(gotDateMin: self.beginningOfDay(date:Date()), gotDateMax: self.endOfDay(date:Date()))
            } else {
                GIDSignIn.sharedInstance().signInSilently()
            }
        }

        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        menuDropDown.bottomOffset = CGPoint(x: -10, y: menuBtn.bounds.height)
        locationDropDown.bottomOffset = CGPoint(x: -10, y: locationBtn.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        menuDropDown.dataSource = [
            "Logout"
        ]
        
        locationDropDown.dataSource = [
            "Caps Coral",
            "BoyScout",
            "Alico",
            "Six Mile",
            "Port Charlotte",
            "Sarasota"
        ]
        
        // Action logout triggered on selection
        menuDropDown.selectionAction = { [unowned self] (index, item) in
            //self.alcButton.setTitle(item, for: .normal)
            if index == 0 {
                let loginManager = FBSDKLoginManager.init()
                loginManager.logOut()
                FBSDKAccessToken.setCurrent(nil)
                self.appDelegate.isFaceBookLogin = false
                self.appDelegate.deleteLoginData()
                self.appDelegate.goToSplash()
            }
        }
        locationBtn.setTitle(self.appDelegate.currentGym, for: .normal)
        locationDropDown.selectionAction = { [unowned self] (index, item) in
            self.locationBtn.setTitle(item, for: .normal)
            switch index {
            case 0:
                self.appDelegate.currentGym = item
                self.appDelegate.saveLoginData()
                self.setCalID(id: self.appDelegate.currentGym)
                self.fetchEvents(gotDateMin: self.beginningOfDay(date:Date()), gotDateMax: self.endOfDay(date:Date()))
                break
            case 1:
                self.appDelegate.currentGym = item
                self.appDelegate.saveLoginData()
                self.setCalID(id: self.appDelegate.currentGym)
                self.fetchEvents(gotDateMin: self.beginningOfDay(date:Date()), gotDateMax: self.endOfDay(date:Date()))
                break
            case 2:
                self.appDelegate.currentGym = item
                self.appDelegate.saveLoginData()
                self.setCalID(id: self.appDelegate.currentGym)
                self.fetchEvents(gotDateMin: self.beginningOfDay(date:Date()), gotDateMax: self.endOfDay(date:Date()))
                break
            case 3:
                self.appDelegate.currentGym = item
                self.appDelegate.saveLoginData()
                self.setCalID(id: self.appDelegate.currentGym)
                self.fetchEvents(gotDateMin: self.beginningOfDay(date:Date()), gotDateMax: self.endOfDay(date:Date()))
                break
            case 4:
                self.appDelegate.currentGym = item
                self.appDelegate.saveLoginData()
                self.setCalID(id: self.appDelegate.currentGym)
                self.fetchEvents(gotDateMin: self.beginningOfDay(date:Date()), gotDateMax: self.endOfDay(date:Date()))
                break
            case 5:
                self.appDelegate.currentGym = item
                self.appDelegate.saveLoginData()
                self.setCalID(id: self.appDelegate.currentGym)
                self.fetchEvents(gotDateMin: self.beginningOfDay(date:Date()), gotDateMax: self.endOfDay(date:Date()))
                break
            default:
                break
            }
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
    func customizeDropDown(_ sender: AnyObject) {
        DropDown.setupDefaultAppearance()
        
        dropDowns.forEach {
            $0.cellNib = UINib(nibName: "DropDownCell", bundle: Bundle(for: DropDownCell.self))
            $0.cellHeight = 35
            $0.customCellConfiguration = nil
        }
    }
    @IBAction func onBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onSelectedLocation(_ sender: UIButton) {
        locationDropDown.show()
    }
    @IBAction func onMenu(_ sender: UIButton) {
        menuDropDown.show()
    }
    
    func setCalID(id: String){
        if self.appDelegate.currentGym == "Port Charlotte" {
            calID = "atc6151@gmail.com"
        }
        else if self.appDelegate.currentGym == "Sarasota"{
            calID = "atcsota@gmail.com"
        }
        else if self.appDelegate.currentGym == "Alico" {
            calID = "atc6159@gmail.com"
        }
        else if self.appDelegate.currentGym == "Six Mile"{
            calID = "atcsixmile@gmail.com"
        }
        else if self.appDelegate.currentGym == "Boyscout"{
            calID = "atcboyscout@gmail.com"
        }
        else if self.appDelegate.currentGym == "Cape Coral"{
            calID = "atccapecoral@gmail.com"
        }
    }
    
    // When the view appears, ensure that the Google Calendar API service is authorized
    // and perform API calls
    // Construct a query and get a list of upcoming events from the user calendar
    func fetchEvents(gotDateMin: Date, gotDateMax: Date) {
        print("Fetching.....")
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading..."
        
        let query = GTLQueryCalendar.queryForEventsList(withCalendarId: calID)
        query?.maxResults = 50
        query?.timeMin = GTLDateTime(date: gotDateMin, timeZone: TimeZone.ReferenceType.system)
        query?.timeMax = GTLDateTime(date: gotDateMax, timeZone: TimeZone.ReferenceType.system)
        query?.singleEvents = true
        query?.orderBy = kGTLCalendarOrderByStartTime
        
        service.executeQuery(query!, delegate: self, didFinish: #selector(self.displayResultWithTicket(ticket:finishedWithObject: error:)))
    }
    
    func displayResultWithTicket(ticket: GTLServiceTicket, finishedWithObject response: GTLCalendarEvents, error: NSError?) {
        MBProgressHUD.hide(for: self.view, animated: true)
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        var eventString = ""
        
        if let events = response.items(), events.isEmpty == false {
            self.arryInfoOfCalendar.removeAll()
            for event in events as! [GTLCalendarEvent] {
                let start: GTLDateTime! = event.start.dateTime ?? event.start.date
                let startString = DateFormatter.localizedString(from: start.date, dateStyle: .short, timeStyle: .short)
                
                let end: GTLDateTime! = event.end.dateTime ?? event.start.date
                let endString = DateFormatter.localizedString(from: end.date, dateStyle: .short, timeStyle: .short)
                
                var postInfoOnCalendar = [String: Any]()
                postInfoOnCalendar["startTime"] = start
                postInfoOnCalendar["endTime"] = end
                postInfoOnCalendar["iCalUID"] = event.iCalUID
                postInfoOnCalendar["kind"] = event.kind
                postInfoOnCalendar["location"] = event.location
                postInfoOnCalendar["title"] = event.summary
                postInfoOnCalendar["visibility"] = event.visibility
                postInfoOnCalendar["status"] = event.status
                postInfoOnCalendar["description"] = event.descriptionProperty
                
                self.arryInfoOfCalendar.append(postInfoOnCalendar)
                
                eventString += "\(startString) - \(endString) - \(event.summary!)\n"
            }
        } else {
            eventString = "no upcoming events found"
        }
    
        print("Current event : \n\(eventString)")
        //calendarkit reloadData
        GroupCalendarView.reloadData()
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    
    func beginningOfDay(date: Date) -> Date{
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.ReferenceType.system
        return calendar.startOfDay(for: date)
    }
    func endOfDay(date: Date) -> Date{
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.ReferenceType.system
        //calendar.timeZone = TimeZone(abbreviation: "UTC")!
        var components = DateComponents()
        components.day = 1
        components.second = -1
        
        return calendar.date(byAdding: components, to: self.beginningOfDay(date: date))!
    }
    
    func dateDefference(startDate: Date, endDate: Date) -> Int {
        
        let calender:Calendar = Calendar.current
        let components: DateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: startDate, to: endDate)

        return components.minute!
    }

}

extension GroupClassesGoogleCalendarViewController: DayViewDelegate, DayViewDataSource {
    func dayViewDidLongPressTimelineAtHour(_ hour: Int) {
        
    }

    // MARK: DayViewDataSource
    
    func eventsForDate(_ date: Date) -> [EventDescriptor] {

        var events = [Event]()
    
        for i in 0...self.arryInfoOfCalendar.count-1 {
            let event = Event()
            var postInfoOnCalendar = [String: Any]()
            postInfoOnCalendar = self.arryInfoOfCalendar[i]
            let duration = (postInfoOnCalendar["endTime"] as! GTLDateTime).date.minutes(from: (postInfoOnCalendar["startTime"] as! GTLDateTime).date)
            let datePeriod = TimePeriod(beginning: (postInfoOnCalendar["startTime"] as! GTLDateTime).date,
                                        chunk: TimeChunk(seconds: 0,
                                                         minutes: duration,
                                                         hours: 0,
                                                         days: 0,
                                                         weeks: 0,
                                                         months: 0,
                                                         years: 0))
            event.datePeriod = datePeriod
            let title = postInfoOnCalendar["title"] as! String
            let start = postInfoOnCalendar["startTime"] as! GTLDateTime
            let end = postInfoOnCalendar["endTime"] as! GTLDateTime
            
            let eventTime = self.formatTime(start: start, end: end)
            event.text = "\(title)\n\(eventTime)"
  
            //set color of event and add to list
            event.color = UIColor.blue
            events.append(event)

            event.userInfo = postInfoOnCalendar
        }        
        return events
    }
    
    // MARK: DayViewDelegate
    
    func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let descriptor = eventView.descriptor as? Event else {
            return
        }

        var info = descriptor.userInfo as! [String: Any]
        
        let start = info["startTime"] as! GTLDateTime
        let end = info["endTime"] as! GTLDateTime
        let time = self.formatTime(start: start, end: end)
        
        let vc = ViewClassViewController()
        vc.className = info["title"]! as! String
        vc.classDescription = info["description"]! as! String
        vc.time = time
        vc.location = info["location"]! as! String
        vc.start = start.date! as NSDate
        vc.end = end.date! as NSDate
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    func dayViewDidLongPressEventView(_ eventView: EventView) {
        guard (eventView.descriptor as? Event) != nil else {
            return
        }
    }
    
    func dayView(dayView: DayView, willMoveTo date: Date) {
        print("DayView = \(dayView) will move to: \(date)")
   
        fetchEvents(gotDateMin: self.beginningOfDay(date:date),gotDateMax: self.endOfDay(date:date))
    }
    
    func dayView(dayView: DayView, didMoveTo date: Date) {
        print("DayView = \(dayView) did move to: \(date)")
    }
    
    func formatTime(start: GTLDateTime, end: GTLDateTime) -> String{
        var timeText = ""
        var startHr = start.date.hour
        if(startHr > 12){ //format
            startHr = startHr-12
        }
        let startMins = start.date.minute
        
        var endHr = end.date.hour
        if(endHr > 12){ //format
            endHr = endHr - 12
        }
        let endMins = end.date.minute
        
        //set formatted time text
        if(startMins == 0 || endMins == 0){
            timeText = "\(startHr):\(startMins)0 - \(endHr):\(endMins)0"
            
        }else{
            timeText = "\(startHr):\(startMins) - \(endHr):\(endMins)"
        }
        return timeText
    }

}

extension GroupClassesGoogleCalendarViewController: GIDSignInUIDelegate, GIDSignInDelegate {
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if user != nil {
            service.authorizer = user.authentication.fetcherAuthorizer()
            fetchEvents(gotDateMin: self.beginningOfDay(date:Date()), gotDateMax: self.endOfDay(date:Date()))
        }
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        DispatchQueue.main.async {
            self.present(viewController, animated: false, completion: nil)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        dismiss(animated: true, completion: nil)
        
    }
}
extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
       return ""
    }
}
