//
//  UserCell.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/13/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    @IBOutlet weak var userProfileImg: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userProfileImg.contentMode = .scaleAspectFill
        userProfileImg.clipsToBounds = true
        userProfileImg.layer.cornerRadius = userProfileImg.frame.size.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
