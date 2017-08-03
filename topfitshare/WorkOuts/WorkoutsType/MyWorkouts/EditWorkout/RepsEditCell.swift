//
//  RepsEditCell.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/10/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit

class RepsEditCell: UITableViewCell {

    @IBOutlet weak var lblOneSet: UILabel!
    @IBOutlet weak var lblOneValue: UILabel!
    @IBOutlet weak var txtOneSet: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
