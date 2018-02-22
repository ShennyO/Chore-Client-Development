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
            var runnable = true
            let jsonUser = try? JSONDecoder().decode(User.self, from: data)
            if let user = jsonUser {
                self.selectedGroup.members.forEach{
                    if $0.id == user.id {
                        runnable = false
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Error", message: "User already exists in the group", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Return", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                        return
                    }
                }
                print("Not supposed to run")
                if runnable {
                    self.userID = user.id
                    completion()
                } else {
                    return
                }
                
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "User doesn't exist", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Return", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
        }
    }
    
    func sendGroupRequest(completion: @escaping ()->()) {
        
        Network.instance.fetch(route: .sendGroupRequest(receiver_id: self.userID, group_id: self.selectedGroup.id, group_name: self.selectedGroup.name)) { (data) in
            completion()
        }
    }
}
