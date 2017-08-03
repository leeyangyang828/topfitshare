//
//  WorkoutsOfUsersCell.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/11/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit

class WorkoutsOfUsersCell: UITableViewCell {

    @IBOutlet weak var workoutName: UILabel!
    @IBOutlet weak var workoutUserName: UILabel!
    @IBOutlet weak var workoutProfile: UIImageView!
    @IBOutlet weak var lblLike: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        workoutProfile.contentMode = .scaleAspectFill
        workoutProfile.clipsToBounds = true
        workoutProfile.layer.cornerRadius = workoutProfile.frame.size.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
