//
//  MyExpandableTableViewSectionHeader.swift
//  LUExpandableTableViewExample
//
//  Created by Laurentiu Ungur on 24/11/2016.
//  Copyright © 2016 Laurentiu Ungur. All rights reserved.
//

import UIKit

protocol MyExpandableTableViewSectionHeaderDelegate: class {
    func commentPreViewAction(comment:String)
}

final class MyExpandableTableViewSectionHeader: LUExpandableTableViewSectionHeader {
    // MARK: - Properties
    
    @IBOutlet weak var expandCollapseButton: UIButton!
    @IBOutlet weak var lblExe: UILabel!
    @IBOutlet weak var lblSets: UILabel!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    weak var commentDelegate:MyExpandableTableViewSectionHeaderDelegate?
    var currentComent:String?
    var ischecked = true
    override var isExpanded: Bool {
        didSet {
            // Change the title of the button when section header expand/collapse
        }
    }
    
    // MARK: - Base Class Overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()
 
    }
    
    func setItem(str:String, isExpand:Bool){
        currentComent = str
        ischecked = isExpand
    }
    // MARK: - IBActions
    
    @IBAction func expandCollapse(_ sender: UIButton) {
        // Send the message to his delegate that shold expand or collapse
        if ischecked == true{
            delegate?.expandableSectionHeader(self, shouldExpandOrCollapseAtSection: section)
        }
    }
    @IBAction func onCommentPreView(_ sender: UIButton) {
        commentDelegate?.commentPreViewAction(comment: currentComent!)
    }
}
