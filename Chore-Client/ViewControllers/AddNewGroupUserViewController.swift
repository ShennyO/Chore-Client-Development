//
//  AddNewGroupUserViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/21/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit

class AddNewGroupUserViewController: UIViewController {

    // - MARK: IBOUTLETS
    
    @IBOutlet weak var newUserView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // - MARK: VARIABLES
    var userID: Int!
    var selectedGroup: Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameTextField.deactivateAutoCorrectAndCap()
        self.newUserView.layer.cornerRadius = 10
        self.newUserView.layer.masksToBounds = true
        addButton.configureButton()
        cancelButton.configureButton()
        // Do any additional setup after loading the view.
    }
    

    // - MARK: IBACTIONS
    
    @IBAction func addButtonTapped(_ sender: Any) {
        //In here, we first have to preform a find Request to get the User associated with the username, then we can affirm that the user exists, and get the User ID, and then perform the send Request route
        ViewControllerUtils().showActivityIndicator(uiView: self.view)
        getUser {
            self.sendGroupRequest {
                DispatchQueue.main.async {
                    ViewControllerUtils().hideActivityIndicator(uiView: self.view)
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
    
    // - MARK: NETWORKING FUNCTIONS
    
    func getUser(completion: @escaping ()->()) {
        Network.instance.fetch(route: .getUser(username: usernameTextField.text!)) { (data, resp) in
            var runnable = true
            let jsonUser = try? JSONDecoder().decode(User.self, from: data)
            //check to see if the user we fetched exist
            if let user = jsonUser {
                //check to see if the user exists in our group
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
               
                if runnable {
                    self.userID = user.id
                    completion()
                } else {
                    return
                }
                
            } else { //if the user doesn't exist
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "User doesn't exist", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Return", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    ViewControllerUtils().hideActivityIndicator(uiView: self.view)
                }
                return
            }
        }
    }
    //This function will only be called if the getUser function will work
    func sendGroupRequest(completion: @escaping ()->()) {
        
        Network.instance.fetch(route: .sendGroupRequest(receiver_id: self.userID, group_id: self.selectedGroup.id, group_name: self.selectedGroup.name)) { (data, resp) in
            completion()
        }
    }
    
}



