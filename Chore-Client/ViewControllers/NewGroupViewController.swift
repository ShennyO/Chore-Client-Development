//
//  NewGroupViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/13/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit

class NewGroupViewController: UIViewController {

    //MARK: IBOUTLETS
    
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addNewGroupView: UIView!
    
    //MARK: VARIABLES
    
    var accepted = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.groupNameTextField.deactivateAutoCorrectAndCap()
        self.addNewGroupView.layer.cornerRadius = 10
        self.addNewGroupView.layer.masksToBounds = true
        addButton.configureButton()
        cancelButton.configureButton()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = segue.identifier {
            //if accepted, reset our groupVC's groups so it will be updated 
            if accepted {
                Network.instance.fetch(route: .getUserGroups, completion: { (data, resp) in
                    let jsonGroups = try? JSONDecoder().decode(Groups.self, from: data)
                    if let groups = jsonGroups?.groups {
                         let GroupsVC = segue.destination as! GroupsViewController
                        GroupsVC.groups = groups
                    }
                })
               
                
            }
        }
    }
    
    //MARK: IBACTIONS

    @IBAction func addButtonTapped(_ sender: Any) {
        
        //After this is tapped, we want to perform a POST request to create a new group
        ViewControllerUtils().showActivityIndicator(uiView: self.view)
        guard let groupName = self.groupNameTextField.text else {return}
        Network.instance.fetch(route: .createGroup(name: groupName)) { (data, resp) in
            print("group created")
            DispatchQueue.main.async {
                ViewControllerUtils().hideActivityIndicator(uiView: self.view)
                self.accepted = true
                self.performSegue(withIdentifier: "unwindToGroupsVC", sender: self)
            }
            
        }
        
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "unwindToGroupsVC", sender: self)
        }
    }
    
}
