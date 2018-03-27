//
//  GroupRequestTableViewCell.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/17/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit

protocol RequestDelegate {
    func completeRequest(indexPath: IndexPath, answer: Bool)
    
}

class GroupRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var requestLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    var delegate: RequestDelegate!
    var indexPath: IndexPath!
    override func awakeFromNib() {
        super.awakeFromNib()
        acceptButton.configureButton()
        declineButton.configureButton()
        // Initialization code
    }

    @IBAction func acceptButtonTapped(_ sender: Any) {
        self.delegate.completeRequest(indexPath: indexPath, answer: true)
    }
    
    @IBAction func declineButtonTapped(_ sender: Any) {
        self.delegate.completeRequest(indexPath: indexPath, answer: false)
    }
    
}
