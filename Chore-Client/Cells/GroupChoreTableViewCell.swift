//
//  GroupChoreTableViewCell.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/14/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit

protocol assignButtonDelegate {
    func assignChore(indexPath: IndexPath)
}

class GroupChoreTableViewCell: UITableViewCell {
    @IBOutlet weak var choreNameLabel: UILabel!
    @IBOutlet weak var choreDescriptionLabel: UILabel!
    @IBOutlet weak var DescriptionLabelCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var assignButton: UIButton!
//    @IBOutlet weak var assignButtonHeight: NSLayoutConstraint!
    var delegate: assignButtonDelegate!
    var currentIndex: IndexPath!
    var chore: Chore!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        if chore.assigned {
            assignButton.frame.size.height = 45
            assignButton.imageView?.contentMode = .scaleAspectFill
            
            assignButton.layer.cornerRadius = assignButton.frame.size.width / 2
//         else {
//            assignButton.frame.size.height = 30
//            assignButton.imageView?.image = nil
//        }
        
    }

    @IBAction func assignButtonTapped(_ sender: Any) {
        delegate.assignChore(indexPath: currentIndex)
    }
    
}
