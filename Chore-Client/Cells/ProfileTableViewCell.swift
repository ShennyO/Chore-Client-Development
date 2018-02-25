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
    
    
    func setCollectionViewDataSourceDelegate
        <D: UICollectionViewDataSource & UICollectionViewDelegate>
        (dataSourceDelegate: D, forRow row: Int) {
//        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.minimumInteritemSpacing = 10
//        profileCollectionView.collectionViewLayout = layout
        profileCollectionView.delegate = dataSourceDelegate
        profileCollectionView.dataSource = dataSourceDelegate
        profileCollectionView.tag = row
        profileCollectionView.reloadData()
    }

    

}
