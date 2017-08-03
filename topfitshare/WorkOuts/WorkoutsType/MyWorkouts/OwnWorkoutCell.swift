//
//  OwnWorkoutCell.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/8/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit

class OwnWorkoutCell: UITableViewCell {

    @IBOutlet weak var workoutsName: UILabel!
    @IBOutlet weak var workoutsImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        workoutsImage.contentMode = .scaleAspectFill
        workoutsImage.clipsToBounds = true
        workoutsImage.layer.cornerRadius = workoutsImage.frame.size.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
