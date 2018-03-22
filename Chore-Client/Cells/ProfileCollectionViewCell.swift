//
//  ProfileCollectionViewCell.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/21/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profilePicture.layer.borderWidth = 3
        profilePicture.layer.borderColor = UIColor(red: 45, green: 45, blue: 45).cgColor
    }
}
