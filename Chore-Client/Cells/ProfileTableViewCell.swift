//
//  ProfileTableViewCell.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/21/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit
import FSPagerView

class ProfileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: FSPagerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
        // Initialization code
    }
    
    
//    func setCollectionViewDataSourceDelegate
//        <D: UICollectionViewDataSource & UICollectionViewDelegate>
//        (dataSourceDelegate: D, forRow row: Int) {
//        profileCollectionView.delegate = dataSourceDelegate
//        profileCollectionView.dataSource = dataSourceDelegate
//        profileCollectionView.tag = row
//        profileCollectionView.reloadData()
//    }

    

}
