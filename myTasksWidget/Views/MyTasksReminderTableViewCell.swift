//
//  MyTasksReminderTableViewCell.swift
//  myTasks
//
//  Created by Yveslym on 5/21/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit

class MyTasksReminderTableViewCell: UITableViewCell {

    @IBOutlet weak var groupProfileImage: UIImageView!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var numberOfDayLeft: UILabel!
    @IBOutlet weak var taskDueDateLabel: UILabel!
    @IBOutlet weak var animatedView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
//    override func layoutSubviews() {
//        animatedView.layer.masksToBounds = true
//        animatedView.layer.cornerRadius = animatedView.frame.width / 2
//    }
}

