//
//  AddNewGroupUserViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/21/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit

class AddNewGroupUserViewController: UIViewController {

    @IBOutlet weak var newUserView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    var userID: Int!
    var selectedGroup: Group!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.newUserView.layer.cornerRadius = 10
        self.newUserView.layer.masksToBounds = true

        // Do any additional setup after loading the view.
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        //In here, we first have to preform a find Request to get the User associated with the username, then we can affirm that the user exists, and get the User ID, and then perform the send Request route
        getUser {
            self.sendGroupRequest {
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        }
        
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)
            
    }
    
}

extension AddNewGroupUserViewController {
    func getUser(completion: @escaping ()->()) {
        Network.instance.fetch(route: .getUser(username: usernameTextField.text!)) { (data) in
            let jsonUser = try? JSONDecoder().decode(User.self, from: data)
            if let user = jsonUser {
                self.userID = user.id
                completion()
            }
        }
    }
    
    func sendGroupRequest(completion: @escaping ()->()) {
        
        Network.instance.fetch(route: .sendGroupRequest(receiver_id: self.userID, group_id: self.selectedGroup.id, group_name: self.selectedGroup.name)) { (data) in
            completion()
        }
    }
}
