//
//  ExerciseCell.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/10/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit

protocol ExerciseCellDelegate : class {
    func searchHelping(name : String)
}

class ExerciseCell: UITableViewCell {

    
    weak var exDelegate : ExerciseCellDelegate?
    
    @IBOutlet weak var lblExe: UILabel!
    var curExerciseName:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setItem(str:String){
        curExerciseName = str
    }
    
    @IBAction func onSearchHelping(_ sender: UIButton) {
        exDelegate?.searchHelping(name: curExerciseName!)
    }
    
}
