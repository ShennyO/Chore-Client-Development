//
//  UserChoreTableViewCell.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/13/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit

protocol ChoreCompletionDelegate {
    func createChoreCompletionRequests(index: IndexPath)
}


class UserChoreTableViewCell: UITableViewCell {

    @IBOutlet weak var choreNameLabel: UILabel!
    @IBOutlet weak var choreDateLabel: UILabel!
    @IBOutlet weak var completeButton: UIButton!
    
    var delegate: ChoreCompletionDelegate!
    var index: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func completeButtonTapped(_ sender: Any) {
        self.delegate.createChoreCompletionRequests(index: self.index)
    }
    

}
