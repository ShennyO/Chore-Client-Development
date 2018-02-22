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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.newUserView.layer.cornerRadius = 10
        self.newUserView.layer.masksToBounds = true

        // Do any additional setup after loading the view.
    }

    @IBAction func addButtonTapped(_ sender: Any) {
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)
            
    }
    
}
