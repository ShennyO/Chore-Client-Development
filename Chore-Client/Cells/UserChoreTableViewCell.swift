//
//  UserChoreTableViewCell.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/13/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit

class UserChoreTableViewCell: UITableViewCell {

    @IBOutlet weak var choreNameLabel: UILabel!
    
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var choreDescriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func completeButtonTapped(_ sender: Any) {
    }
    

}
