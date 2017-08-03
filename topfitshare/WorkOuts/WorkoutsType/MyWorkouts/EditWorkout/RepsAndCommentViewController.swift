//
//  RepsAndCommentViewController.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/10/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit

protocol RepsAndCommentViewControllerDelegate : class {
    func gotRepsAndComment(reps : [String], comment : String)
}

class RepsAndCommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    var workoutName:String?
    var sets:String?
    
    var currentSetsCount = 0
    var cardio = false
    var complete = true
    
    weak var delegate : RepsAndCommentViewControllerDelegate?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var RepsTableView: UITableView!
    @IBOutlet weak var txtComments: UITextView!
    @IBOutlet weak var commentView: UIView!
    
    var tmpReps:[String] = []
    var tmpComment:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        let leftButton = UIButton.init(type: .custom)
        leftButton.setImage(UIImage.init(named: "abc_ic_ab_back_mtrl_am_alpha"), for: .normal)
        leftButton.addTarget(self, action: #selector(self.onBackclick(_:)), for: UIControlEvents.touchUpInside)
        leftButton.frame = CGRect.init(x: 0, y: 0, width: 25, height: 25)
        
        let label = UILabel.init(frame: CGRect.init(x: 26, y: 3, width: 70, height: 20))
        label.font = UIFont.init(name: "Ariral-BoldMT", size: 17)
        label.text = workoutName
        label.textColor = UIColor.white
        leftButton.addSubview(label)
        
        let barButton = UIBarButtonItem.init(customView: leftButton)
        
        self.navigationItem.leftBarButtonItem = barButton
        
        RepsTableView.register(UINib.init(nibName: "RepsEditCell", bundle: nil), forCellReuseIdentifier: "RepsEditItem")
        
        if txtComments.isFocused == false {
            txtComments.text = "Add Comments...."
            txtComments.textColor = UIColor.gray
        }
        
        if appDelegate.isSelectedCar == true || cardio == true {
            RepsTableView.isHidden = true
        }else{
            RepsTableView.isHidden = false
            RepsTableView.reloadData()
        }
        
        currentSetsCount = Int(sets!)!
        
        updateTableViewAndViewPostion()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTableViewAndViewPostion(){
        if appDelegate.isSelectedCar == true {
            commentView.frame = CGRect.init(x: commentView.frame.origin.x, y: RepsTableView.frame.origin.y, width: commentView.frame.size.width, height: commentView.frame.size.height)
        }else {
            RepsTableView.frame = CGRect.init(x: RepsTableView.frame.origin.x, y: RepsTableView.frame.origin.y, width: RepsTableView.frame.size.width, height: CGFloat(currentSetsCount * 44))
            commentView.frame = CGRect.init(x: commentView.frame.origin.x, y: RepsTableView.frame.origin.y + CGFloat(currentSetsCount * 44), width: commentView.frame.size.width, height: commentView.frame.size.height)
            
            if currentSetsCount > 5 {
                RepsTableView.frame = CGRect.init(x: RepsTableView.frame.origin.x, y: RepsTableView.frame.origin.y, width: RepsTableView.frame.size.width, height: 200)
                commentView.frame = CGRect.init(x: commentView.frame.origin.x, y: RepsTableView.frame.origin.y + 200, width: commentView.frame.size.width, height: commentView.frame.size.height)
            }
        }
    }
    
    @IBAction func onSave(_ sender: UIButton) {
        if appDelegate.isSelectedCar == true || cardio == true{
            //put cardio in reps position
            for _ in 0...currentSetsCount-1{
                tmpReps.append("Cardio")
            }
            
            if txtComments.text! == "" || txtComments.text! == "Add Comments..." {
                delegate?.gotRepsAndComment(reps: tmpReps, comment: "No Comment Made")
            }else {
                delegate?.gotRepsAndComment(reps: tmpReps, comment: txtComments.text)
            }
            self.navigationController?.popViewController(animated: true)

        }else {
            for index in 0...currentSetsCount-1{
                let indexPath = NSIndexPath.init(row: index, section: 0)
                let cell = RepsTableView.cellForRow(at: indexPath as IndexPath)!
                for view in cell.contentView.subviews{
                    if view is UITextField {
                        let txtField = view as! UITextField
                        if txtField.text != ""{
                            self.tmpReps.append(txtField.text!)
                        }
                        else{
                            self.complete = false
                        }
                    }
                }
            } //end for loop

            if(!self.complete){
                //1. Create the alert controller.
                let alert = UIAlertController(title: "Wait", message: "Please fill in all fields", preferredStyle: .alert)
                // 3. Grab the value from the text field, and print it when the user clicks OK.
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    self.tmpReps.removeAll()
                    alert?.dismiss(animated: false, completion: nil)
                    
                }))
            }else{
                //send reps and comment to editworkout VC
                if txtComments.text! == "" || txtComments.text! == "Add Comments..." {
                    delegate?.gotRepsAndComment(reps: tmpReps, comment: "No Comment Made")
                }else {
                    delegate?.gotRepsAndComment(reps: tmpReps, comment: txtComments.text)
                }
                self.navigationController?.popViewController(animated: true)
 
            }
        }
    }
    
    func onBackclick(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentSetsCount
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepsEditItem", for: indexPath) as! RepsEditCell
        cell.txtOneSet.text = ""
        cell.lblOneSet.text = "Set \(indexPath.row + 1)"
        cell.lblOneValue.isHidden = true
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        txtComments.textColor = UIColor.black
        txtComments.text = ""
        return true
    }
    
}
