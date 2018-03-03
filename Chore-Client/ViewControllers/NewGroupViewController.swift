//
//  NewGroupViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/13/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit

class NewGroupViewController: UIViewController {

    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        
        //After this is tapped, we want to perform a POST request to create a new group
        guard let groupName = self.groupNameTextField.text else {return}
        Network.instance.fetch(route: .createGroup(name: groupName)) { (data) in
            print("group created")
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "unwindToGroupsVC", sender: self)
            }
            
        }
        
    }
    @IBAction func returnButton(_ sender: Any) {
   self.performSegue(withIdentifier: "unwindToGroupsVC", sender: self)
    }
}
