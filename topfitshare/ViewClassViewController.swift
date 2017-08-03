//
//  ViewClassViewController.swift
//  topfitshare
//
//  Created by Alexander Hall on 5/16/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit
import EventKit

class ViewClassViewController: UIViewController {
    var className = ""
    var time = ""
    var location = ""
    var classDescription = ""
    var start: NSDate? = nil
    var end: NSDate? = nil
    
    @IBOutlet var classLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Class Details"
        classLabel.text = className
        timeLabel.text = time
        locationLabel.text = location
        descriptionLabel.text = classDescription
        print(classDescription)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func showAlert(msg:String, titleStr:String, delegate:Any){
        let alert = UIAlertController(title: titleStr, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func addToCalendar(_ sender: Any) {
        let eventStore : EKEventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { (granted, error) in
            
            if (granted) && (error == nil) {
                print("granted \(granted)")
        
                let event:EKEvent = EKEvent(eventStore: eventStore)
                
                event.title = self.className
                event.startDate = self.start! as Date
                event.endDate = self.end! as Date
                event.location = self.location
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let error as NSError {
                    print("failed to save event with error : \(error)")
                }
                let alert = UIAlertController(title: "Saved!", message: "Event added to calendar", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                
                print("failed to save event with error : \(String(describing: error)) or access not granted")
            }
        }
    }

}

