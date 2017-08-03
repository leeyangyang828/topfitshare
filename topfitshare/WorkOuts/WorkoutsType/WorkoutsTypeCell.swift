//
//  WorkoutsTypeCell.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/8/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit

class WorkoutsTypeCell: UITableViewCell {

    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
