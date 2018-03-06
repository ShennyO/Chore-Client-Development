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

    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var choreDescriptionLabel: UILabel!
    @IBOutlet weak var dueDate: UILabel!
    @IBOutlet weak var completedButton: UIButton!

    var chore: Chore!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func completedButtonTapped(_ sender: Any) {
        self.handleCompletButton()

    @objc func handleCompletButton() {
        let alertAssign = UIAlertController(title: "Complet Chore", message: "Are you sure you really complet this chore? bitch ", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        let complet = UIAlertAction(title: "completed", style: .default) { (complet) in

            self.didCompletChore(chore: self.chore, completion: {

                print("completed")
            })
        }
        alertAssign.addAction(complet)
        alertAssign.addAction(cancel)



        self.parentViewController?.present(alertAssign, animated: true, completion: nil)

    }
    func didCompletChore(chore: Chore, completion: @escaping()->()){

        let userId = KeychainSwift().get("id")

        // add chore completion request here
    }

}
