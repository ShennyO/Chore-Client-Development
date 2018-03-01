//
//  RequestTableViewCell.swift
//  Chore-Client
//
//  Created by Yveslym on 2/24/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import FoldingCell
import UIKit

class RequestTableViewCell: FoldingCell {
    
    @IBOutlet var closeNumberLabel: UILabel!
    @IBOutlet var openNumberLabel: UILabel!
    @IBOutlet var groupName: UILabel!
    
    var number: Int = 0 {
        didSet {
            //closeNumberLabel.text = String(number)
            //openNumberLabel.text = String(number)
        }
    }
    
    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }
    
    override func animationDuration(_ itemIndex: NSInteger, type _: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
}

// MARK: - Actions ⚡️

extension RequestTableViewCell {
    
    @IBAction func buttonHandler(_: AnyObject) {
        print("tap")
    }
}
