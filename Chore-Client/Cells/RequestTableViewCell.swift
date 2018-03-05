//
//  RequestTableViewCell.swift
//  Chore-Client
//
//  Created by Yveslym on 2/24/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import FoldingCell
import UIKit

class RequestTableViewCell: FoldingCell, RequestDelegate  {
    func reloadGroupViewController() {
        
    }
    
   
    
    
    @IBOutlet var closeNumberLabel: UILabel!
    @IBOutlet var openNumberLabel: UILabel!
    @IBOutlet var groupName: UILabel!
    @IBOutlet var participantLabel: UILabel!
    @IBOutlet var choresNumber: UILabel!
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    var request : Request!
    
    var delegate: RequestDelegate!
    //var indexPath: IndexPath!
    
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
        delegate = self
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
    
    @IBAction func acceptButtonTapped(_ sender: Any) {
        //self.delegate.completeRequest(indexPath: indexPath, answer: true)
        
        self.requestResponse(response: true, group_id: request.group_id, request_id: request.id) {
            //self.delegate.reloadGroupViewController()
        }
    }
    
    @IBAction func declineButtonTapped(_ sender: Any) {
        //self.delegate.completeRequest(indexPath: indexPath, answer: false)
        self.requestResponse(response: false, group_id: request.group_id, request_id: request.id) {
            //self.delegate.reloadGroupViewController()
        }
    }
    
    func requestResponse(response: Bool, group_id: Int, request_id: Int,completion:@escaping()->()){
        
        Network.instance.fetch(route: .requestResponse(response: response, group_id: group_id, request_id: request_id)) { (data) in
            completion()
        }
    
}
}








