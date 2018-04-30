//
//  ProfileTableViewCell.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/21/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet private weak var profileCollectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //setting up the collection view data source and delegate to be the view controller
    func setCollectionViewDataSourceDelegate
        <D: UICollectionViewDataSource & UICollectionViewDelegate>
        (dataSourceDelegate: D, forRow row: Int) {
        profileCollectionView.delegate = dataSourceDelegate
        profileCollectionView.dataSource = dataSourceDelegate
        profileCollectionView.tag = row
        profileCollectionView.reloadData()
    }

    

}
