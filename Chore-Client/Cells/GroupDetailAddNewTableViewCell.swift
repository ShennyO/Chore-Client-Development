//
//  GroupDetailAddNewTableViewCell.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 3/7/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit

protocol addNewDelegate {
    func newChore()
    func newUser()
}

class GroupDetailAddNewTableViewCell: UITableViewCell {
    @IBOutlet weak var newChoreButton: UIButton!
    @IBOutlet weak var newUserButton: UIButton!
    var delegate: addNewDelegate!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func newChoreTapped(_ sender: Any) {
        delegate.newChore()
    }
    
    @IBAction func newUserTapped(_ sender: Any) {
        delegate.newUser()
    }
    
}
