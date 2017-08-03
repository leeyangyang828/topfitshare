//
//  UserInGymTableViewSectionHader.swift
//  topfitshare
//
//  Created by stepanekdavid on 4/13/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit

protocol UserInGymTableViewSectionHaderDelegate: class {
    func commentPreViewAction(comment:String)
}

final class UserInGymTableViewSectionHader: LUExpandableTableViewSectionHeader {
    @IBOutlet weak var lblGymWith: UILabel!
    @IBOutlet weak var downUpImage: UIImageView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    weak var commentDelegate:MyExpandableTableViewSectionHeaderDelegate?
    
    override var isExpanded: Bool {
        didSet {
            // Change the title of the button when section header expand/collapse
            if isExpanded == true {
                downUpImage.image = UIImage.init(named: "up.png")
            }else {
                downUpImage.image = UIImage.init(named: "down.png")
            }
        }
    }
    
    // MARK: - Base Class Overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func expandCollapse(_ sender: UIButton) {
        // Send the message to his delegate that shold expand or collapse
        delegate?.expandableSectionHeader(self, shouldExpandOrCollapseAtSection: section)
    }
}
