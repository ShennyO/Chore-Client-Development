//
//  GroupChoreTableViewCell.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/14/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit
import KeychainSwift

protocol assignButtonDelegate {
    func sendIndex(indexPath: IndexPath)
}

class GroupChoreTableViewCell: UITableViewCell {
    @IBOutlet weak var choreNameLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
   // @IBOutlet weak var assignButton: UIButton!
    @IBOutlet weak var assignButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var assignButton: UIButton!
    
    @IBOutlet weak var assignedProfileStackView: UIStackView!
  
    @IBOutlet weak var assignedProfileImage: UIImageView!
    
    var chore: Chore!
    
    
    
    //var assignButton: UIButton!
    
    var delegate: assignButtonDelegate!
    var currentIndex: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.assignButton = UIButton(type: .roundedRect)
//       self.assignButton.titleLabel?.text = "Get Chore"
    }
    

    @IBAction func assignButtonTapped(_ sender: UIButton) {
        //delegate.sendIndex(indexPath: currentIndex)
//        self.assignButton.addTarget(self, action: #selector(handleAssignButton), for: UIControlEvents.touchUpInside)
        self.handleAssignButton()
    }
    
    @objc func handleAssignButton() {
        let alertAssign = UIAlertController(title: "Get Chore", message: "Do you really want to get this chore? Don't fuck it up", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        let assign = UIAlertAction(title: "Assign", style: .default) { (assign) in
            self.didAssignChore(chore: self.chore, group_id: self.chore.group_id, completion: {
                
                print("Assigned")
            })
        }
        alertAssign.addAction(cancel)
        alertAssign.addAction(assign)
        
        
        self.parentViewController?.present(alertAssign, animated: true, completion: nil)
        
    }
    
}

// - MARK: NTWORK
extension GroupChoreTableViewCell{
    
    func didAssignChore(chore: Chore,group_id: Int, completion: @escaping()->()){
        
        let userId = KeychainSwift().get("id")
        
        Network.instance.fetch(route: .takeChore(group_id: chore.group_id, chore_id: chore.id, user_id: Int(userId!)!)) { (data) in
            completion()
        }
    }
    
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if parentResponder is UIViewController {
                return parentResponder as! UIViewController!
            }
        }
        return nil
    }
}



