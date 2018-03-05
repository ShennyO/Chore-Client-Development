//
//  UserChoreTableViewCell.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/13/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit
import KeychainSwift
class UserChoreTableViewCell: UITableViewCell {

    @IBOutlet weak var choreNameLabel: UILabel!
    @IBOutlet weak var chorePenaltyLabel: UILabel!
    @IBOutlet weak var choreDescriptionLabel: UILabel!
    @IBOutlet weak var dueDate: UILabel!
    @IBOutlet weak var completedButton: UIButton!
    
    var chore: Chore!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func completedButtonTapped(_ sender: Any) {
    }
    
    @objc func handleAssignButton() {
        let alertAssign = UIAlertController(title: "Get Chore", message: "Do you really want to get this chore? Don't fuck it up", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        let assign = UIAlertAction(title: "Assign", style: .default) { (assign) in
            self.didAssignChore(chore: self.chore, completion: {
                
                print("Assigned")
            })
        }
        alertAssign.addAction(cancel)
        alertAssign.addAction(assign)
        
        
        self.parentViewController?.present(alertAssign, animated: true, completion: nil)
        
    }
    func didAssignChore(chore: Chore, completion: @escaping()->()){
        
        let userId = KeychainSwift().get("id")
        
        // add chore completion request here
    }

}
