//
//  ChoreCompletionRequestTableViewCell.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 3/5/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit

protocol CompleteChoreCompletionDelegate {
    func completeChoreCompletionRequest(index: IndexPath, answer: Bool)
}

class ChoreCompletionRequestTableViewCell: UITableViewCell {
    
    @IBOutlet weak var choreCompletionLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var denyButton: UIButton!
    var delegate: CompleteChoreCompletionDelegate!
    var index: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }

    @IBAction func acceptButtonTapped(_ sender: Any) {
        delegate.completeChoreCompletionRequest(index: index, answer: true)
    }
    
    @IBAction func denyButtonTapped(_ sender: Any) {
        delegate.completeChoreCompletionRequest(index: index, answer: false)
    }
    
}


