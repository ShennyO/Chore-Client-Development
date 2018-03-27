//
//  GroupTableViewCell.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/8/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {

    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupProfileImage: UIImageView!
    @IBOutlet weak var choresCountLabel: UILabel!
    @IBOutlet weak var membersCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    
}
