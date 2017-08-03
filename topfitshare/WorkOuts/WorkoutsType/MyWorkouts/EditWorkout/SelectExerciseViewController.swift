//
//  SelectExerciseViewController.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/10/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit

protocol SelectExerciseViewControllerDelegate : class {
    func gotExerciesFromHelp(name : String)
}

class SelectExerciseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ExerciseCellDelegate {

    @IBOutlet weak var btnFreeWeight: UIButton!
    @IBOutlet weak var btnMachines: UIButton!
    @IBOutlet weak var exerciesTableView: UITableView!
    @IBOutlet weak var tabBtnsView: UIView!
    @IBOutlet weak var tabButtonWidth: NSLayoutConstraint!
    
    
    weak var delegate : SelectExerciseViewControllerDelegate?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indexSelectedExercies = 0
    
    var isSelectedFree = true
    var fwArray:[String] = []
    var mcnArray:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnFreeWeight.backgroundColor = UIColor.blue
        btnMachines.backgroundColor = UIColor.white
        
        btnFreeWeight.setTitleColor(UIColor.white, for: .normal)
        btnMachines.setTitleColor(UIColor.black, for: .normal)
        
        switch indexSelectedExercies {
        case 0:
            readRTFFromLocal(nameFW: "abs_fw", nameMCN: "abs_mcn")
            break
        case 1:
            readRTFFromLocal(nameFW: "back_fw", nameMCN: "back_mcn")
            break
        case 2:
            readRTFFromLocal(nameFW: "biceps_fw", nameMCN: "biceps_mcn")
            break
        case 3:
            readRTFFromLocal(nameFW: "cardio_fw", nameMCN: "cardio_mcn")
            break
        case 4:
            readRTFFromLocal(nameFW: "chest_fw", nameMCN: "chest_mcn")
            break
        case 5:
            readRTFFromLocal(nameFW: "legs_fw", nameMCN: "legs_mcn")
            break
        case 6:
            readRTFFromLocal(nameFW: "shoulders_fw", nameMCN: "shoulders_mcn")
            break
        case 7:
            readRTFFromLocal(nameFW: "triceps_fw", nameMCN: "triceps_mcn")
            break
        default:
            break
        }
        
        exerciesTableView.register(UINib.init(nibName: "ExerciseCell", bundle: nil), forCellReuseIdentifier: "ExerciseItem")
        exerciesTableView.delegate = self
        exerciesTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func readRTFFromLocal(nameFW:String, nameMCN:String){
        if let url = Bundle.main.url(forResource:nameFW, withExtension: "rtf") {
            do {
                let data = try Data(contentsOf:url)
                let attibutedString = try NSAttributedString(data: data, documentAttributes: nil)
                let fullText = attibutedString.string
                fwArray = fullText.components(separatedBy: ",")
                
                
            } catch {
                print(error)
            }
        }
        if let url = Bundle.main.url(forResource:nameMCN, withExtension: "rtf") {
            do {
                let data = try Data(contentsOf:url)
                let attibutedString = try NSAttributedString(data: data, documentAttributes: nil)
                let fullText = attibutedString.string
                mcnArray = fullText.components(separatedBy: ",")
                
                
            } catch {
                print(error)
            }
        }
        
        appDelegate.isSelectedCar = false
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onFreeWeightclick(_ sender: UIButton) {
        btnFreeWeight.backgroundColor = UIColor.blue
        btnMachines.backgroundColor = UIColor.white
        
        btnFreeWeight.setTitleColor(UIColor.white, for: .normal)
        btnMachines.setTitleColor(UIColor.black, for: .normal)
        
        isSelectedFree = true
        exerciesTableView.reloadData()
    }
    @IBAction func onMachinesClick(_ sender: UIButton) {
        btnFreeWeight.backgroundColor = UIColor.white
        btnMachines.backgroundColor = UIColor.blue
        
        
        btnFreeWeight.setTitleColor(UIColor.black, for: .normal)
        btnMachines.setTitleColor(UIColor.white, for: .normal)
        isSelectedFree = false
        exerciesTableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isSelectedFree == true {
            return fwArray.count
        }
        return mcnArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseItem", for: indexPath) as! ExerciseCell
        
        cell.exDelegate = self
        if isSelectedFree == true {
            cell.lblExe.text = fwArray[indexPath.row]
            cell.setItem(str: fwArray[indexPath.row])
        }else {
            cell.lblExe.text = mcnArray[indexPath.row]
            cell.setItem(str: mcnArray[indexPath.row])
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        tableView.deselectRow(at: indexPath, animated: true)
        if isSelectedFree == true {
            appDelegate.currentHelpforExercies = fwArray[indexPath.row]
            delegate?.gotExerciesFromHelp(name: fwArray[indexPath.row])
            self.dismiss(animated: true, completion: nil)
        }else {
            appDelegate.currentHelpforExercies = mcnArray[indexPath.row]
            delegate?.gotExerciesFromHelp(name: mcnArray[indexPath.row])
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //ExerciseCellDelegate
    func searchHelping(name: String) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Tutorial", message: "Would you like to search a tutorial for this exercise?", preferredStyle: .alert)
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { [weak alert] (_) in
            
            let urlAddress = "http://www.google.com/search?q=\(name.replacingOccurrences(of: " ", with: "+").replacingOccurrences(of: "\n", with: "+"))+Tutorial"
            UIApplication.shared.open(URL(string: urlAddress)!, options: [:], completionHandler: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .default, handler: { [weak alert] (_) in
            
            
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
}
