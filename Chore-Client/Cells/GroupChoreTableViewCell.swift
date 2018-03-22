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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        assignButton.imageView?.contentMode = .scaleAspectFill
        
        assignButton.layer.cornerRadius = assignButton.frame.size.width / 2
    }

    @IBAction func assignButtonTapped(_ sender: Any) {
        delegate.assignChore(indexPath: currentIndex)
    }
    
}
