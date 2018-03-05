//
//  GroupRequestTableViewCell.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/17/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit

protocol RequestDelegate: class {
    //func completeRequest(indexPath: IndexPath, answer: Bool)
    func reloadGroupViewController()
    
}

extension RequestDelegate where Self: GroupsViewController{
    
    func reloadGroupViewController(){
        DispatchQueue.main.async {
            self.groupsTableView.reloadData()
        }
    }
}

class GroupRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var requestLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    var request : Request!
    
    var delegate: RequestDelegate!
    var indexPath: IndexPath!
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.delegate = self
    }

    @IBAction func acceptButtonTapped(_ sender: Any) {
        //self.delegate.completeRequest(indexPath: indexPath, answer: true)
        
        self.requestResponse(response: true, group_id: request.group_id, request_id: request.id) {
            self.delegate.reloadGroupViewController()
        }
    }
    
    @IBAction func declineButtonTapped(_ sender: Any) {
        //self.delegate.completeRequest(indexPath: indexPath, answer: false)
        self.requestResponse(response: false, group_id: request.group_id, request_id: request.id) {
            self.delegate.reloadGroupViewController()
        }
    }
    
    func requestResponse(response: Bool, group_id: Int, request_id: Int,completion:@escaping()->()){
        
        Network.instance.fetch(route: .requestResponse(response: response, group_id: group_id, request_id: request_id)) { (data) in
            completion()
        }
    }
    
}





